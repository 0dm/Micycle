import requests

# Define the input coordinates
input_coordinates = {"x": 2.0, "y": 3.0}

# Make a POST request to the FastAPI endpoint
response = requests.get("http://127.0.0.1:8000/stations", json=input_coordinates)

# Print the response
print(response.status_code)
print(response.json())
