from sqlalchemy import Column, Integer, String, Float
from database import Base

class Stations(Base):
    __tablename__ = "stations"
    id = Column(Integer, primary_key=True,index=True)
    name = Column(String)
    address = Column(String)
    x = Column(Float)
    y= Column(Float)