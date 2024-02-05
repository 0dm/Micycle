from typing import List
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
import models
from database import engine, Sessionlocal
from sqlalchemy.orm import Session
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    db = Sessionlocal()
    num_stations = db.query(models.Stations).count()
    if num_stations == 0:
        stations = [
            ("UTM Bus Station", "Mississauga, ON L5L 1C6", 43.547852, -79.663229),
            ("Student Centre Station", "3359 Mississauga Rd, Mississauga, ON L5L 1C6", 43.549030, -79.663554),
            ("CCT Station", "Mississauga, ON L5L 1J7", 43.549449, -79.663100),
            ("MN Station", "Mississauga, ON L5L 1J7", 43.550708, -79.663328),
            ("Dean Henderson Memorial Park Station", "Mississauga, ON L5K 2R1",43.533203, -79.659932),
            ("Sir Johns Homestead Station", "3061 Sir Johns Homestead #29, Mississauga, ON L5L 2N4", 43.541112, -79.662074),
            ("Erindale Park Station", "1560 Dundas St W, Mississauga, ON L5C 1E5", 43.545935, -79.652739),
            ("Woodchester Station", "2605 Woodchester Dr, Mississauga, ON", 43.526129, -79.675644),
            ("Collegeway Station", "2686 The Collegeway #101, Mississauga, ON L5L 2M9 ", 43.531145, -79.692270),
            ("Central Pkwy Station", "1132 Central Pkwy W, Mississauga, ON L5C 4E5 ",43.566689, -79.659101),
            ("Square One Station", "2800 Lawrences, Mississauga, ON L5L 2N5", 43.594678, -79.644202),
        ]
        for station_info in stations:
            station_model = models.Stations(
                name=station_info[0],
                address=station_info[1],
                x=station_info[2],
                y=station_info[3]
            )
            db.add(station_model)
            db.commit()
        yield()
    else:
        print(f"Found {num_stations} stations in the database. Skipping population.")
        yield()

app = FastAPI(lifespan=lifespan,root_path="/stations")

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
    bikes: int

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
    station_model = models.Stations(name=station.name, address=station.address, x=station.x, y=station.y)
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
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)