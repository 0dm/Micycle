import datetime
from typing import List
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
import models
import requests
from database import engine, Sessionlocal
from sqlalchemy.orm import Session
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta
from sqlalchemy import func
from predictor import get_average_num_bikes_per_hour

class Rent(BaseModel):
    id: int
    email: str

class Ret(BaseModel):
    id: int
    station: int

class Create(BaseModel):
    name: str
    address: str
    x: float
    y: float
    num_bike: int

class Update(BaseModel):
    id: int
    name: str
    address: str
    x: float
    y: float
    num_bike: int

class Delete(BaseModel):
    id: int


@asynccontextmanager
async def lifespan(app: FastAPI):
    db = Sessionlocal()


    num_stations = db.query(models.Stations).count()
    if num_stations == 0:
        stations = [
            ("UTM Bus Station", "Mississauga, ON L5L 1C6", 43.547852, -79.663229, 2),
            ("Student Centre Station", "3359 Mississauga Rd, Mississauga, ON L5L 1C6", 43.549030, -79.663554,5),
            ("CCT Station", "Mississauga, ON L5L 1J7", 43.549449, -79.663100,5),
            ("MN Station", "Mississauga, ON L5L 1J7", 43.550708, -79.663328,3),
            ("Dean Henderson Memorial Park Station", "Mississauga, ON L5K 2R1",43.533203, -79.659932,5),
            ("Sir Johns Homestead Station", "3061 Sir Johns Homestead #29, Mississauga, ON L5L 2N4", 43.541112, -79.662074,4),
            ("Erindale Park Station", "1560 Dundas St W, Mississauga, ON L5C 1E5", 43.545935, -79.652739,10),
            ("Woodchester Station", "2605 Woodchester Dr, Mississauga, ON", 43.526129, -79.675644,15),
            ("Collegeway Station", "2686 The Collegeway #101, Mississauga, ON L5L 2M9 ", 43.531145, -79.692270,12),
            ("Central Pkwy Station", "1132 Central Pkwy W, Mississauga, ON L5C 4E5 ",43.566689, -79.659101,15),
            ("Square One Station", "2800 Lawrences, Mississauga, ON L5L 2N5", 43.594678, -79.644202,11),
        ]
        for station_info in stations:
            station_model = models.Stations(
                name=station_info[0],
                address=station_info[1],
                x=station_info[2],
                y=station_info[3]
                ,num_bike=station_info[4]
            )
            db.add(station_model)
            db.commit()


        #Update the predicted number of bikes for each station
        for station_model in db.query(models.Stations).all():
            station_model.predicted_num_bike = get_average_num_bikes_per_hour(datetime.now(), station_model.id)
            db.commit()
        yield()
        print(f"Found {num_stations} stations in the database. station populated.")
    else:
        print(f"Found {num_stations} stations in the database. Skipping population.")
        yield()
 

app = FastAPI(lifespan=lifespan)

origins = ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
models.Base.metadata.create_all(bind=engine)

def get_db():
    try:
        db = Sessionlocal()
        yield db
    finally:
        db.close()
class Location(BaseModel):
    x: float
    y: float

class Station(BaseModel):
    name: str
    address: str
    x: float
    y: float
    num_bike: int
    predicted_num_bike: int

@app.get("/stations")
def read_api(db: Session = Depends(get_db)):
    """
    A function to read the API with a database session as a parameter and return all stations.
    """
    return db.query(models.Stations).all()

@app.get("/stations/{station_id}")
def get_station(station_id:int,db: Session = Depends(get_db)):
    """
    A function to get a station with a database session as a parameter and return the station with the given ID.
    """
    return db.query(models.Stations).filter(models.Stations.id == station_id).first()

@app.post("/stations")
def create_station(create: Create, db: Session = Depends(get_db)):
    """
    Create a station in the database.

    Args:
        station (Station): The station object containing name, address, x, and y coordinates.
        db (Session, optional): The database session. Defaults to Depends(get_db).

    Returns:
        Station: The created station object.
    """
    station_model = models.Stations(name=create.name, address=create.address, x=create.x, y=create.y, num_bike=create.num_bike)
    station_model.predicted_num_bike = get_average_num_bikes_per_hour(datetime.now(), station_model.id)
    db.add(station_model)
    db.commit()
    return create

@app.put("/stations")
def update_station(update: Update, db: Session = Depends(get_db)):
    """
    Update a station in the database with the given station_id. 
    Parameters:
    - station_id: int - The ID of the station to be updated.
    - station: Station - The updated station data.
    - db: Session - The database session.
    Returns:
    - Station - The updated station.
    Raises:
    - HTTPException - If the station with the given ID is not found in the database.
    """
    station_model = db.query(models.Stations).filter(models.Stations.id == update.id).first()
    if not station_model:
        raise HTTPException(status_code=404, detail="Station not found")
    station_model.name = update.name
    station_model.address = update.address
    station_model.x = update.x
    station_model.y = update.y

    db.add(station_model)
    db.commit()
    return update

@app.delete("/stations")
def delete_station(delete: Delete, db: Session = Depends(get_db)):
    """
    Deletes a station with the given station ID from the database.

    Parameters:
    - station_id: an integer representing the ID of the station to be deleted
    - db: a database session dependency

    Returns:
    None
    """
    station_model = db.query(models.Stations).filter(models.Stations.id == delete.id).first()
    if not station_model:
        raise HTTPException(status_code=404, detail=f"Station ID {delete.id}: not found")
    db.query(models.Stations).filter(models.Stations.id == delete.id).delete()
    db.commit()

@app.post("/qr")
def qr(rent: Rent, db: Session = Depends(get_db)):
    """
    Manages the data input from the QR scanner 
    Comes in json {body: "MESSASGE", user: "EMAIL"}
    """
    bike_id = rent.id 
    email = rent.email
   
    # response = requests.get(f"http://localhost:5000/get_user_info/{email}")
    # if response.status_code == 200:
    #     user_info = response.json()
    #     user_id = user_info.get("id")
    # else:
    #     print(response.status_code)

    #     raise HTTPException(status_code=404, detail="User not found")

    existing_rent = db.query(models.Rents).filter(
        models.Rents.bike_id == bike_id,
        models.Rents.end_time == None
    ).first()

    if existing_rent:
        raise HTTPException(status_code=409, detail="Bike currently taken out")


    bike = db.query(models.Bikes).filter(models.Bikes.bike_id == bike_id).first()
    if not bike:
        raise HTTPException(status_code=404, detail="Bike not found")
    

    start_station_id = bike.station_id
    
    # take out a bike
    rent_data = {
        "bike_id": bike_id,
        "start": start_station_id,
        "user_email": email,
        "start_time": datetime.now()  
    }

    db.execute(models.Rents.__table__.insert().values(**rent_data))
    db.commit()
    return {"message": "Rent added successfully"}



@app.get("/active/{email}")
def check_active_rental(email: str, db: Session = Depends(get_db)):

    # response = requests.get(f"http://localhost:5000/get_user_info/{email}")
    # if response.status_code == 200:
    #     user_info = response.json()
    #     user_id = user_info.get("id")
    # else:
    #     raise HTTPException(status_code=404, detail="User not found")
       


    # most recent entry with the given user_email
    recent_rental = db.query(models.Rents).filter(models.Rents.user_email == email).order_by(models.Rents.start_time.desc()).first()

    if recent_rental:
        if recent_rental.end_time is None:
            # Bike is rented
            rented = True
            current_time = datetime.now()
            start_time = recent_rental.start_time
            duration = current_time - start_time
        else:
            # Bike is not rented
            rented = False
            start_time = recent_rental.start_time
            end_time = recent_rental.end_time
            duration = end_time - start_time
    else:
        # No rental entry found
        raise HTTPException(status_code=404, detail="No rental entry found for your user")

    # Convert duration to hours:minutes:seconds format
    duration_str = str(duration).split('.')[0]

    # Return response
    return {
        "Rented": rented,
        "Time": duration_str
    }

@app.get("/test")
async def test():
    return {"message": "Test successful"}

@app.post("/return")
def return_bike(ret: Ret, db: Session = Depends(get_db)):
    bike_id = ret.id 
    station_id = ret.station 
    

    rental = db.query(models.Rents).filter(models.Rents.bike_id == bike_id,models.Rents.end_time == None).first()

    if not rental:
        raise HTTPException(status_code=404, detail="Bike not currently rented")
       

    # Update rental information
    rental.end_time = datetime.now()
    rental.end =  station_id

    # Update bike information
    bike = db.query(models.Bikes).filter(models.Bikes.bike_id == rental.bike_id).first()
    if not bike:
        raise HTTPException(status_code=404, detail="Bike not found")
    
    bike.station_id = station_id

    # Commit changes to the database
    db.commit()

    start_time = rental.start_time
    end_time = rental.end_time
    duration = (end_time - start_time).total_seconds() / 3600  # Convert seconds to hours

    # Calculate amount to charge the user
    amount = round(duration * 0.30, 2)  # Charge $0.30 for each hour

    # Make a request to charge_user endpoint
    charge_data = {
        "email": rental.user_email,
        "amount": amount
    }
    # charge_response = requests.post("http://localhost:5000/charge_user", json=charge_data)

    # # Handle charge_user response
    # if charge_response.status_code != 200:
    #     print(charge_response.status_code)
    #     raise HTTPException(status_code=charge_response.status_code, detail="Failed to charge user")

    return {"message": "Bike returned successfully"}

    

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)