from typing import List
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
import models
from database import engine, Sessionlocal
from sqlalchemy.orm import Session
app = FastAPI()

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

@app.get("/")
def read_api(db: Session = Depends(get_db)):
    """
    A function to read the API with a database session as a parameter and return all stations.
    """
    return db.query(models.Stations).all()

@app.post("/")
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

@app.put("/{station_id}")
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

@app.delete("/{station_id}")
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
    uvicorn.run(app, host="0.0.0.0", port=8000)