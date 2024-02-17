from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS  # Import CORS
import hashlib
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
basedir = os.path.abspath(os.path.dirname(__file__))
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///" + os.path.join(basedir, "app.db")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db = SQLAlchemy(app)

import stripe  # Ensure Stripe is imported
stripe.api_key = 'sk_test_51OkvTNGUL4Iok28JJullgn5bJ8PYSEXc2hSXBrEv8bmYgfuOyYWPs3bvG8pdFRMjPwOkEyzCDdG1xUi8eAmhWaHr00m1wTOair'

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(80), nullable=False)
    display_name = db.Column(db.String(120), nullable=True)
    is_admin = db.Column(db.Boolean, default=False)
    admin_code = db.Column(db.String(80), nullable=True)
    stripe_customer_id = db.Column(db.String(255), nullable=True)



@app.route("/create_stripe_customer", methods=["POST"])
def create_stripe_customer():
    data = request.get_json()
    user = User.query.filter_by(email=data["email"]).first()
    if user:
        try:
            # Create a new Stripe Customer
            customer = stripe.Customer.create(
                email=data["email"],
                name=data.get("displayName", ""),
                payment_method=data.get("paymentMethodId"),  # Assume this is passed from the frontend
                invoice_settings={
                    'default_payment_method': data.get("paymentMethodId"),
                },
            )
            
            # Here, you'd save the customer ID to your database
            user.stripe_customer_id = customer.id  # Assuming you have a stripe_customer_id field in your User model
            db.session.commit()

            return jsonify({"stripeCustomerId": customer.id}), 201
            
        except Exception as e:
            return jsonify({"error": str(e)}), 500
    else:
        return jsonify({"error": "User not found"}), 404




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


if __name__ == "__main__":
    with app.app_context():
        db.create_all()  # Initialize database within an application context
    app.run(debug=True)
