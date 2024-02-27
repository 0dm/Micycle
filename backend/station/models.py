from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from database import Base
from sqlalchemy import Boolean

class Stations(Base):
    __tablename__ = "stations"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    address = Column(String)
    x = Column(Float)
    y = Column(Float)
    num_bike = Column(Integer)
    predicted_num_bike = Column(Integer)
    bikes = relationship("Bikes", back_populates="stations")

class Bikes(Base):
    __tablename__ = "bikes"
    bike_id = Column(Integer, primary_key=True, index=True)
    station_id = Column(Integer, ForeignKey('stations.id'))
    stations = relationship("Stations", back_populates="bikes")
    rents = relationship("Rents", back_populates="bikes")
class Rents(Base):
    __tablename__ = "rents"
    id = Column(Integer, primary_key=True, index=True)
    bike_id = Column(Integer, ForeignKey('bikes.bike_id'))
    start = Column(Integer, ForeignKey('stations.id'))
    user_id = Column(Integer, ForeignKey('user.id'))
    start_time = Column(DateTime)
    end = Column(Integer, ForeignKey('stations.id'))
    end_time = Column(DateTime, nullable=True)
    num_bike = Column(Integer)  # New attribute to keep track of the number of bikes after renting/returning
    bikes = relationship("Bikes", back_populates="rents")
    start_station = relationship("Stations", foreign_keys=[start])
    end_station = relationship("Stations", foreign_keys=[end])
class User(Base):
    __tablename__ = "user"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(120), unique=True, index=True)
    password = Column(String(80))
    display_name = Column(String(120))
    is_admin = Column(Boolean, default=False)
    admin_code = Column(String(80))

