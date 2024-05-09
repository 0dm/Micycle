#!/bin/bash

# Navigate to Flask backend directory
cd 'backend'
echo "Starting Flask backend..."
FLASK_APP=app.py FLASK_ENV=development flask run -host=0.0.0.0 &
cd 'station'
echo 'Starting station backend...'
uvicorn station_service:app --host 0.0.0.0 --reload
STATION_PID=$!
python3 predictor.py
cd '..'
# Save the PID of the Flask process
FLASK_PID=$!

# Wait a bit for Flask to initialize (optional)
sleep 5

# Navigate to Flutter frontend directory
cd '..'
echo "Starting Flutter frontend..."
flutter run -d chrome

# When you exit Flutter run, kill Flask server
kill $FLASK_PID $STATION_PID
