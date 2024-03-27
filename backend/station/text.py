import requests
import json

def send_test_post_request():
    # URL of the endpoint
    url = "http://127.0.0.1:8000/qr"  # Change the URL if needed

    # Test data to send
    data = {
        "message": "{1, 2}",  # Sample message
        "email": "test@example.com"  # Sample user email
    }

    # Convert data to JSON format

    # Set headers
    headers = {
        "Content-Type": "application/json"
    }

    try:
        # Send POST request
        response = requests.post(url, json=data, headers=headers)

        # Print response
        print("Response status code:", response.status_code)
        print("Response body:", response.json())

    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    send_test_post_request()