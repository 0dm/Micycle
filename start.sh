#!/bin/bash

# Navigate to Flask backend directory
cd 'MiCycle/AccountDatabase'
echo "Starting Flask backend..."
FLASK_APP=app.py FLASK_ENV=development flask run &

# Save the PID of the Flask process
FLASK_PID=$!

# Wait a bit for Flask to initialize (optional)
sleep 5

# Navigate to Flutter frontend directory
cd 'MiCycle/MiCycleApp'
echo "Starting Flutter frontend..."
flutter run -d chrome

# When you exit Flutter run, kill Flask server
kill $FLASK_PID