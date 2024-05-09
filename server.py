from flask import Flask, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app) 

data_from_post = None

@app.route('/post_endpoint', methods=['POST'])
def handle_post():
    global data_from_post
    data_from_post = request.data.decode("utf-8")
    print("Received data from POST request:", data_from_post)
    return "Data received from POST request"

@app.route('/get_endpoint', methods=['GET'])
def handle_get():
    global data_from_post
    while data_from_post is None:
        pass  
    print("Sent GET response:", data_from_post)
    return data_from_post

if __name__ == '__main__':
    app.run(port=5000)
