from sqlalchemy import Column, Integer, String, Float
from database import Base

class Stations(Base):
    __tablename__ = "stations"
    id = Column(Integer, primary_key=True,index=True)
    name = Column(String)
    address = Column(String)
    x = Column(Float)
    y= Column(Float)
    num_bike = Column(Integer)

class Bike(Base):
    __tablename__ = "bikes"
    bike_id = Column(Integer, primary_key=True, index=True)
    station_id = Column(Integer, ForeignKey('stations.id'))

class Rent(Base):
    __tablename__ = "rents"
    id = Column(Integer, primary_key=True, index=True)
    bike_id = Column(Integer, ForeignKey('bikes.bike_id'))
    start_station_id = Column(Integer, ForeignKey('stations.id'))
    user_id = Column(Integer, ForeignKey('users.id'))
    start_time = Column(DateTime)
    end_station_id = Column(Integer, ForeignKey('stations.id'))
    end_time = Column(DateTime, nullable=True)
    bike = relationship("Bike", back_populates="rents")
    user = relationship("User", back_populates="rents")