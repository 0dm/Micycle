from typing import List
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Location(BaseModel):
    x: float
    y: float

class Station(BaseModel):
    name: str
    address: str
    x: float
    y: float

# Sample station coordinates with names and addresses
stations = [
    Station(name="Station A", address="123 Main St", x=1.0, y=2.0),
    Station(name="Station B", address="456 Oak St", x=3.0, y=4.0),
    Station(name="Station C", address="789 Pine St", x=5.0, y=6.0),
    # will add more
]
def euclidean_distance(x1, y1, x2, y2):
    return ((x1 - x2) ** 2 + (y1 - y2) ** 2) ** 0.5

@app.post("/nearest_stations/", response_model=List[Station])
def get_nearest_stations(location: Location):
    # Calculate distances to all stations using Euclidean distance
    distances = [
        euclidean_distance(location.x, location.y, station.x, station.y)
        for station in stations
    ]

    # Get the indices of the nearest stations
    nearest_indices = sorted(range(len(distances)), key=lambda i: distances[i])

    # Extract the nearest stations with names and addresses
    nearest_stations = [stations[i] for i in nearest_indices]

    return nearest_stations
