#!/bin/bash

start_services() {
    # Start the Python server
    python3 server.py &

    # Start the Flutter app
    cd /Users/rahisharora/Desktop/301/MiCycle/camcodes
    flutter run -d chrome &
}



stop_service() {
    # Find the PID of the process using port 5000
    PID=$(lsof -t -i :5000)

    # If PID is not empty, kill the process
    if [ -n "$PID" ]; then
        kill $PID
        echo "Service on port 5000 stopped."
    else
        echo "No service found running on port 5000."
    fi
}

# Main script
case "$1" in
    -k | --kill)
        stop_service
        ;;
    -s | --start)
        start_services
        ;;
    *)
        echo "Usage: $0 {-k|--kill|-s|--start}"
        exit 1
        ;;
esac
