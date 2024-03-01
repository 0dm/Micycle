from datetime import datetime, timedelta
from sqlalchemy import func
from database import Sessionlocal, engine, Base
from models import Stations, Bikes, Rents
from collections import defaultdict
cache = defaultdict(lambda: defaultdict(list))

def get_average_num_bikes_per_hour(day,station_id):
    if day in cache and station_id in cache[day] and sum(cache[day][station_id]) != 0:
        print("cached")
        return cache[day][station_id]
    result = [0] * 24
    for i in range(4):  # Loop over the past four weeks
        start_week = day - timedelta(weeks=i+1)
        for hour in range(24):
            start_hour = datetime(start_week.year, start_week.month, start_week.day, hour)
            end_hour = start_hour + timedelta(hours=1)

            with Sessionlocal() as session:
                # Get records from previous weeks at the same hour, ordered by start time
                records_start_time = session.query(Rents).filter(
                    Rents.start_time >= start_hour,
                    Rents.start_time < end_hour, Rents.start == station_id
                ).order_by(Rents.start_time).all()

                # Get records from previous weeks at the same hour, ordered by end time descending
                records_end_time = session.query(Rents).filter(
                    Rents.end_time >= start_hour,
                    Rents.end_time < end_hour, Rents.end == station_id
                ).order_by(Rents.end_time.desc()).all()

                if records_end_time and records_start_time:
                    if records_start_time[0].start_time > records_end_time[0].end_time:
                        num_bike_hour = records_start_time[0].start_num_bike
                    else:
                        num_bike_hour = records_start_time[0].end_num_bike
                else:
                    num_bike_hour = 0

                # Cache the result
                cache[start_week][station_id].append(num_bike_hour)
                result[hour] += num_bike_hour

    # Calculate the average for each hour

    result = [round(num/4) for num in result]

    return result

def update_predicted_bikes(day):
    with Sessionlocal() as session:
        for station in session.query(Stations).all():
            # Calculate the average number of bikes per hour for the station
            average_bikes_per_hour = get_average_num_bikes_per_hour(day, station.id)
            # Update the station's num_predicted_bike attribute with the calculated average
            session.query(Stations).filter_by(id=station.id).update({"predicted_num_bike": average_bikes_per_hour})

        session.commit()
# Example usage
day = datetime(2024, 2, 29)
average_bikes_per_hour = get_average_num_bikes_per_hour(day,3)
print(average_bikes_per_hour)
print(len(average_bikes_per_hour))
# update_predicted_bikes(day)