from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import hashlib
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
basedir = os.path.abspath(os.path.dirname(__file__))
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///" + os.path.join(basedir, "app.db")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db = SQLAlchemy(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(80), nullable=False)
    display_name = db.Column(db.String(120), nullable=True)
    is_admin = db.Column(db.Boolean, default=False)
    admin_code = db.Column(db.String(80), nullable=True)


@app.route("/create_account", methods=["POST"])
def create_account():
    data = request.get_json()
    existing_user = User.query.filter_by(email=data["email"]).first()
    if existing_user:
        return (
            jsonify({"error": "This email address already has an account"}),
            409,
        )  # 409 Conflict

    is_admin = data.get("isAdmin", False)
    admin_code = data.get("adminCode", "")

    if is_admin and admin_code != "admin":
        return jsonify({"error": "Invalid admin code"}), 400

    new_user = User(
        email=data["email"],
        password=data["password"],
        display_name=data["displayName"],
        is_admin=data["isAdmin"],
        admin_code=data.get("adminCode", ""),
    )
    db.session.add(new_user)
    try:
        db.session.commit()
        return jsonify({"message": "Account created successfully"}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# Flask login route example without password hashing
@app.route("/login", methods=["POST"])
def login():
    data = request.json
    user = User.query.filter_by(email=data["email"], password=data["password"]).first()
    if user:
        return (
            jsonify(
                {
                    "message": "Login successful",
                    "user": {"email": user.email, "display_name": user.display_name},
                }
            ),
            200,
        )
    else:
        return jsonify({"error": "Invalid email or password"}), 401


@app.route("/get_display_name/<email>", methods=["GET"])
def get_display_name(email):
    user = User.query.filter_by(email=email).first()
    if user:
        return jsonify({"display_name": user.display_name}), 200
    else:
        return jsonify({"error": "User not found"}), 404

@app.route('/update_email', methods=['POST'])
def update_email():
    data = request.json
    current_email = data.get("current_email")
    new_email = data.get("new_email")
    # Authenticate the request and validate new_email...
    user = User.query.filter_by(email=current_email).first()
    if user:
        user.email = new_email
        db.session.commit()
        return jsonify({"message": "Email updated successfully"}), 200
    else:
        return jsonify({"error": "User not found"}), 404

@app.route('/verify_password', methods=['POST'])
def verify_password():
    data = request.get_json()
    email = data.get('email')
    print(email)
    password = data.get('password')

    # Find the user by email
    user = User.query.filter_by(email=email).first()
    
    print(f"Received password attempt for {email}: {password}")  # This will print to your terminal
    
    if user and user.password == password:
        # Password is correct
        return jsonify({"message": "Password verification successful"}), 200
    else:
        # Either the user wasn't found, or the password is incorrect
        return jsonify({"error": "Invalid email or password"}), 401

@app.route('/update_username', methods=['POST'])
def update_username():
    data = request.get_json()
    user_email = data.get('email')
    new_username = data.get('new_username')
    
    user = User.query.filter_by(email=user_email).first()
    if user:
        user.display_name = new_username
        db.session.commit()
        return jsonify({"message": "Username updated successfully"}), 200
    else:
        return jsonify({"error": "User not found"}), 404

@app.route('/update_password', methods=['POST'])
def update_password():
    data = request.get_json()
    print("Received data:", data)  # Debugging print

    user_email = data.get('email')
    new_password = data.get('new_password')

    user = User.query.filter_by(email=user_email).first()
    
    if user:
        user.password = new_password
        db.session.commit()
        return jsonify({"message": "Password updated successfully"}), 200
    else:
        print("User not found for email:", user_email)  # Debugging print
        return jsonify({"error": "User not found"}), 404

@app.route('/delete_account', methods=['POST'])
def delete_account():
    data = request.get_json()
    user_email = data.get('email')
    password = data.get('password')  # Assuming password verification is required

    print("Received data:", data)  # Debugging print

    user = User.query.filter_by(email=user_email).first()

    if user:
        # Password matches, proceed with account deletion
        db.session.delete(user)
        db.session.commit()
        return jsonify({"message": "Account deleted successfully"}), 200
    elif user:
        # Password does not match
        return jsonify({"error": "Password verification failed"}), 403
    else:
        # User not found
        return jsonify({"error": "User not found"}), 404



if __name__ == "__main__":
    with app.app_context():
        db.create_all()  # Initialize database within an application context
    app.run(debug=True)
