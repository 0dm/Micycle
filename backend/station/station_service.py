from typing import List
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
import models
from database import engine, Sessionlocal
from sqlalchemy.orm import Session
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta


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
        yield()
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
def create_station(station: Station, db: Session = Depends(get_db)):
    """
    Create a station in the database.

    Args:
        station (Station): The station object containing name, address, x, and y coordinates.
        db (Session, optional): The database session. Defaults to Depends(get_db).

    Returns:
        Station: The created station object.
    """
    station_model = models.Stations(name=station.name, address=station.address, x=station.x, y=station.y, num_bike=station.num_bike)
    db.add(station_model)
    db.commit()
    return station

@app.put("/stations")
def update_station(station_id:int, station: Station, db: Session = Depends(get_db)):
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
    station_model = db.query(models.Stations).filter(models.Stations.id == station_id).first()
    if not station_model:
        raise HTTPException(status_code=404, detail="Station not found")
    station_model.name = station.name
    station_model.address = station.address
    station_model.x = station.x
    station_model.y = station.y

    db.add(station_model)
    db.commit()
    return station

@app.delete("/stations")
def delete_station(station_id:int, db: Session = Depends(get_db)):
    """
    Deletes a station with the given station ID from the database.

    Parameters:
    - station_id: an integer representing the ID of the station to be deleted
    - db: a database session dependency

    Returns:
    None
    """
    station_model = db.query(models.Stations).filter(models.Stations.id == station_id).first()
    if not station_model:
        raise HTTPException(status_code=404, detail=f"Station ID {station_id}: not found")
    db.query(models.Stations).filter(models.Stations.id == station_id).delete()
    db.commit()

@app.post("/qr")
def qr(input:str, db: Session = Depends(get_db)):
    """
    Manages the data input from the QR scanner 
    Comes in json {body: "MESSASGE", user: "EMAIL"}
    
    If MESSAGE looks like NEW{i, j}, and the user is an admin, add bike_id i and station_id j into the bikes table.
    If MESSAGE looks like {i, j} and bike_id, start station_id and, user_id and start time into rents table. 
    If MESSAGE looks like {i, j} but bike_id = i is in the rents table with a null end time, update the end time and
    end station_id. 
    """
    message = input.get('body', '')
    user_email = input.get('user', '')

    # get the user
    user_info_response = requests.get(f"http://127.0.0.1:5000/get_user_info/{user_email}")
    if user_info_response.status_code != 200:
        raise HTTPException(status_code=400, detail="User not found or unauthorized")

    user_info = user_info_response.json()
    is_admin = user_info.get('is_admin', False)

    # break down message 
    if message.startswith("NEW") and is_admin:
        # get bike_id and station_id 
        try:
            _, bike_id, station_id = message.split(",")
            bike_id = int(bike_id.strip())
            station_id = int(station_id.strip())
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid message format")

        # add new bike 
        db.execute(models.Bikes.__table__.insert().values(bike_id=bike_id, station_id=station_id))
        db.commit()
        return {"message": "Bike added successfully"}

    elif message.startswith("{") and "," in message:
        try:
            data = message.strip("{}").split(",")
            bike_id, start_station_id, user_id = map(int, data)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid message format")

        # return a rental 
        existing_rent = db.query(models.Rents).filter(
            models.Rents.bike_id == bike_id,
            models.Rents.end_time == None
        ).first()

        if existing_rent:
            # record return time 
            existing_rent.end_station_id = start_station_id
            existing_rent.end_time = datetime.now() 
            db.commit()
            return {"message": "Rent updated successfully"}

        else:
            # take out a bike
            rent_data = {
                "bike_id": bike_id,
                "start_station_id": start_station_id,
                "user_id": user_id,
                "start_time": datetime.now()  
            }
            db.execute(models.Rents.__table__.insert().values(**rent_data))
            db.commit()
            return {"message": "Rent added successfully"}

    else:
        raise HTTPException(status_code=400, detail="Invalid message format")

@app.get("/average_bikes")
def get_average_bikes(db: Session = Depends(get_db)):
    current_date = datetime.now()
    current_hour_start = current_date.replace(minute=0, second=0, microsecond=0)

    # Calculate the start and end time for the current hour on the same day of the week for the past weeks
    past_weeks_data = []
    for i in range(1, 5):  # Assuming you want to calculate the average for the past 4 weeks
        start_time = current_hour_start - timedelta(weeks=i)
        end_time = start_time + timedelta(hours=1)
        average_bikes = db.query(models.Rent).filter(
            models.Rent.start_time >= start_time,
            models.Rent.start_time < end_time
        ).count() / len(db.query(models.Station).all())
        past_weeks_data.append(average_bikes)

    # Calculate the average number of bikes at each station for the current hour
    average_bikes = sum(past_weeks_data) / len(past_weeks_data)

    return {"average_bikes": average_bikes}   

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)