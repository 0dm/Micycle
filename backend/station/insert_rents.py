import random
from datetime import datetime, timedelta
from database import Sessionlocal, engine, Base
from models import Stations, Bikes, Rents

# Create all tables in the database
Base.metadata.create_all(bind=engine) 
# Function to create random rent records for a day
def create_rent_records(day):
    with Sessionlocal() as session:
        for station in session.query(Stations).all():
            # Generate random number of bikes to rent/return
            for hour in range(24):
                start_time = datetime(day.year, day.month, day.day, hour)
                end_time = start_time + timedelta(hours=1)
                # Query available bikes at the station
                available_bikes = session.query(Bikes).filter_by(station_id=station.id).all()
                if not available_bikes:
                    continue
                num_rents = random.randint(1, 3)  # Generate a random number of rents per hour (between 1 and 3)
                for _ in range(num_rents):
                    start_num_bike = random.randint(0, 10)
                    end_num_bike = random.randint(0, 10)
                    bike = random.choice(available_bikes).bike_id
                    # Create rent record
                    rent = Rents(
                        bike_id=bike,
                        start=station.id,
                        start_time=start_time,
                        end=station.id,
                        end_time=end_time,
                        start_num_bike=start_num_bike,
                        end_num_bike=end_num_bike
                    )
                    session.add(rent)
        session.commit()


with Sessionlocal() as session:
    stations = [
                ("UTM Bus Station", "Mississauga, ON L5L 1C6", 43.547852, -79.663229, 2,2),
                ("Student Centre Station", "3359 Mississauga Rd, Mississauga, ON L5L 1C6", 43.549030, -79.663554,5,5),
                ("CCT Station", "Mississauga, ON L5L 1J7", 43.549449, -79.663100,5,5),
                ("MN Station", "Mississauga, ON L5L 1J7", 43.550708, -79.663328,3,3),
                ("Dean Henderson Memorial Park Station", "Mississauga, ON L5K 2R1",43.533203, -79.659932,5,5),
                ("Sir Johns Homestead Station", "3061 Sir Johns Homestead #29, Mississauga, ON L5L 2N4", 43.541112, -79.662074,4,4),
                ("Erindale Park Station", "1560 Dundas St W, Mississauga, ON L5C 1E5", 43.545935, -79.652739,10,10),
                ("Woodchester Station", "2605 Woodchester Dr, Mississauga, ON", 43.526129, -79.675644,15,15),
                ("Collegeway Station", "2686 The Collegeway #101, Mississauga, ON L5L 2M9 ", 43.531145, -79.692270,12,12),
                ("Central Pkwy Station", "1132 Central Pkwy W, Mississauga, ON L5C 4E5 ",43.566689, -79.659101,15,15),
                ("Square One Station", "2800 Lawrences, Mississauga, ON L5L 2N5", 43.594678, -79.644202,11,11),
            ]
    for station in stations:
        session.add(Stations(name=station[0], address=station[1], x=station[2], y=station[3], num_bike=station[4], predicted_num_bike=station[5]))
    session.commit()
    for station_info in session.query(Stations).all():
        if station_info:
            bike = Bikes(station_id=station_info.id)
            session.add(bike)
    session.commit()
# Generate rent records for each day until today
start_date = datetime(2024, 1, 1)  # Start date for generating rent records
end_date = datetime.today() + timedelta(days=1)  # End date for generating rent records
current_date = start_date
while current_date <= end_date:
    create_rent_records(current_date)
    current_date += timedelta(days=1)
