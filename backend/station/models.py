from sqlalchemy import Column, Integer, String, Float, ForeignKey, TIMESTAMP
from database import Base

class Stations(Base):
    __tablename__ = "stations"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    address = Column(String)
    x = Column(Float)
    y = Column(Float)
    num_bike = Column(Integer)

class User(Base):
    __tablename__ = "user"
    user_id = Column(Integer, primary_key=True)

class Bikes(Base):
    __tablename__ = "bikes"
    bike_id = Column(Integer, primary_key=True)
    station_id = Column(Integer, ForeignKey('stations.id'))

class Rents(Base):
    __tablename__ = "rents"
    bike_id = Column(Integer, ForeignKey('bikes.bike_id'), primary_key=True)
    start = Column(Integer, ForeignKey('stations.id'))
    end = Column(Integer, ForeignKey('stations.id'))
    user_id = Column(Integer, ForeignKey('user.user_id'))
    start_time = Column(TIMESTAMP)
    end_time = Column(TIMESTAMP)
