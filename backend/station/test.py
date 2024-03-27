import requests
import json

# Define the base URL
base_url = "http://localhost:8000"

# Sample data for testing
rent_data = {
    "id": 1,
    "email": "r@r.ca" 
}

return_data = {
    "id": 1,  
    "station": 13 
}

# Test the /qr endpoint
def test_qr():
    endpoint = "/qr"
    url = base_url + endpoint
    response = requests.post(url, json=rent_data)
    print("Response from /qr endpoint:", response.json())

# Test the /active endpoint
def test_active():
    email = "r@r.ca"  
    endpoint = f"/active/{email}"
    url = base_url + endpoint
    response = requests.get(url)
    print("Response from /active endpoint:", response.json())

# Test the /return endpoint
def test_return():
    endpoint = "/return"
    url = base_url + endpoint
    response = requests.post(url, json=return_data)
    print("Response from /return endpoint:", response.json())

# Execute the tests
if __name__ == "__main__":
    test_qr()
    test_active()
    test_return()
