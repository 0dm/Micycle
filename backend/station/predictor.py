# Cache for predicted_num_bike for each station
predictions_cache = {}

import models
from database import engine, Sessionlocal
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import time
import threading
def calculate_predicted_num_bike(db: Session, station_id: int, current_time: datetime):
    global predictions_cache
    current_hour_start = current_time.replace(minute=0, second=0, microsecond=0)
    current_hour_end = current_hour_start + timedelta(hours=1)
    
    # Check if the prediction is already cached
    if station_id in predictions_cache and predictions_cache[station_id]["hour_start"] == current_hour_start:
        return predictions_cache[station_id]["predicted_num_bike"]
    
    total_bikes = 0
    total_weeks = 0

    for i in range(1, 5):
        hour_start = current_time - timedelta(weeks=i)
        hour_end = hour_start + timedelta(hours=1) # Predict up until the next hour

        
        # Get the num_bike and time of the latest rent for the current hour
        latest_rent_start = db.query(models.Rents.num_bike, models.Rents.start_time).filter(
            models.Rents.start == station_id,
            models.Rents.start_time >= hour_start,
            models.Rents.start_time <= hour_end,
            (models.Rents.start_time >= current_hour_start) & (models.Rents.start_time < current_hour_end)
        ).order_by(models.Rents.start_time.desc()).first()

        # Get the num_bike and time of the latest return for the current hour
        latest_rent_end = db.query(models.Rents.num_bike, models.Rents.end_time).filter(
            models.Rents.end == station_id,
            models.Rents.end_time >= hour_start,
            models.Rents.end_time <= hour_end,
            (models.Rents.end_time >= current_hour_start) & (models.Rents.end_time < current_hour_end)
        ).order_by(models.Rents.end_time.desc()).first()

        # Compare the times of the latest rent and return, and use the one with the greater time
        if latest_rent_start and latest_rent_end:
            if latest_rent_start[1] > latest_rent_end[1]:
                total_bikes += latest_rent_start[0]
            else:
                total_bikes += latest_rent_end[0]
            total_weeks += 1
        elif latest_rent_start:
            total_bikes += latest_rent_start[0]
            total_weeks += 1
        elif latest_rent_end:
            total_bikes += latest_rent_end[0]
            total_weeks += 1

    # Calculate the predicted number of bikes
    if total_weeks > 0:
        predicted_num_bike = total_bikes // total_weeks
    else:
        predicted_num_bike = 0
    # Cache the prediction
    predictions_cache[station_id] = {"hour_start": current_hour_start, "predicted_num_bike": predicted_num_bike}
    
    return predicted_num_bike

def update_predicted_num_bikes():
    global predictions_cache
    predictions_cache = {}  # Clear the cache
    db = Sessionlocal()
    for station in db.query(models.Stations).all():
        station_id = station.id
        current_time = datetime.now()
        predicted_num_bike = calculate_predicted_num_bike(db, station_id, current_time)
        db.query(models.Stations).filter(models.Stations.id == station_id).update({models.Stations.predicted_num_bike: predicted_num_bike})
    db.commit()
    db.close()

# Schedule the update of predicted_num_bike every hour
def update_predictions_scheduler():
    while True:
        current_time = datetime.now()
        if current_time.minute == 0 and current_time.second == 0:
            update_predicted_num_bikes()
        time.sleep(1)

# Start the scheduler in a separate thread
scheduler_thread = threading.Thread(target=update_predictions_scheduler)
print("Starting scheduler thread...")
scheduler_thread.start()