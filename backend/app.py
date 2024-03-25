"""
    The code sets up a Flask server with CORS enabled to handle POST and GET requests, storing data from
    a POST request and returning it in response to a GET request.
    :return: The code provided is a simple Flask application that sets up two endpoints:
    `/post_endpoint` for handling POST requests and `/get_endpoint` for handling GET requests.
"""

from flask import Flask, request, jsonify, redirect
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
basedir = os.path.abspath(os.path.dirname(__file__))
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///" + os.path.join(basedir, "app.db")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db = SQLAlchemy(app)

import stripe  # Ensure Stripe is imported

stripe.api_key = "sk_test_51OkvTNGUL4Iok28JJullgn5bJ8PYSEXc2hSXBrEv8bmYgfuOyYWPs3bvG8pdFRMjPwOkEyzCDdG1xUi8eAmhWaHr00m1wTOair"


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
    if (
        user and user.stripe_customer_id is None
    ):  # Check if the user exists and doesn't already have a Stripe customer ID
        try:
            # Create a new Stripe Customer
            customer = stripe.Customer.create(
                email=data["email"],
                name=data.get("displayName", ""),
                # You can add more fields as needed
            )

            # Save the customer ID to your database
            user.stripe_customer_id = customer.id
            db.session.commit()

            return jsonify({"stripeCustomerId": customer.id}), 201

        except stripe.error.StripeError as e:
            # Handle Stripe errors (e.g., network issues)
            return jsonify({"error": str(e)}), 500
        except Exception as e:
            # Handle other unexpected errors
            return jsonify({"error": "An error occurred"}), 500
    else:
        return (
            jsonify(
                {"error": "User already has a Stripe customer ID or does not exist"}
            ),
            409,
        )


@app.route("/create_account", methods=["POST"])
def create_account():
    data = request.get_json()
    existing_user = User.query.filter_by(email=data["email"]).first()
    if existing_user:
        return jsonify({"error": "This email address already has an account"}), 409

    # Create a Stripe Customer if one doesn't exist
    customer = stripe.Customer.create(
        email=data["email"],
        name=data.get("displayName", ""),
    )

    # Create a new user in your database with the Stripe customer ID
    new_user = User(
        email=data["email"],
        password=data["password"],  # Hash this password before storing
        display_name=data["displayName"],
        is_admin=data["isAdmin"],
        admin_code=data.get("admin_code", ""),
        stripe_customer_id=customer.id,  # Save the Stripe customer ID
    )
    db.session.add(new_user)
    db.session.commit()

    # Create a Stripe Checkout Session for payment
    checkout_session = stripe.checkout.Session.create(
        customer=customer.id,
        payment_method_types=["card"],
        mode="setup",
        success_url=request.host_url + "success?session_id={CHECKOUT_SESSION_ID}",
        cancel_url=request.host_url + "cancel",
    )

    return jsonify({"url": checkout_session.url}), 200


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


@app.route("/success", methods=["GET"])
def payment_success():
    session_id = request.args.get("session_id")
    if not session_id:
        return jsonify({"error": "Session ID not provided"}), 400

    try:
        # Retrieve the session
        session = stripe.checkout.Session.retrieve(session_id)

        # Retrieve the customer and set the default payment method
        customer = stripe.Customer.retrieve(session.customer)
        payment_method = stripe.PaymentMethod.list(
            customer=customer.id, type="card"
        ).data[0]
        stripe.Customer.modify(
            customer.id,
            invoice_settings={"default_payment_method": payment_method.id},
        )

        # Redirect to the login page or another success page
        return redirect("http://172.174.183.117:5000/#/login", code=302)
    except Exception as e:
        app.logger.error(f"Error processing payment success: {e}")
        return jsonify({"error": "Failed to process payment success"}), 500


@app.route("/charge_user", methods=["POST"])
def charge_user():
    data = request.get_json()
    email = data.get("email")  # Make sure to send 'email' in your request body
    amount = data.get("amount")  # Amount in cents

    # Search for a Stripe customer by email
    customers = stripe.Customer.list(email=email).data
    print(customers)

    # If no customer with that email was found, return an error
    if not customers:
        return jsonify({"error": "Stripe customer not found"}), 404

    # Assuming the first customer returned is the one we want
    customer = customers[0]

    try:
        # Create a charge for the customer
        charge = stripe.Charge.create(
            amount=amount,
            currency="cad",  # Change to your currency if necessary
            customer=customer.id,  # Use the Stripe customer ID
            description="Charge for in-app purchase",
        )
        return jsonify({"success": True, "charge_id": charge.id}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/get_user_info/<email>", methods=["GET"])
def get_user_info(email):
    user = User.query.filter_by(email=email).first()
    if user:
        return (
            jsonify(
                {
                    "id": user.id,
                    "display_name": user.display_name,
                    "is_admin": user.is_admin,
                    "email": user.email,
                }
            ),
            200,
        )
    else:
        return jsonify({"error": "User not found"}), 404


if __name__ == "__main__":
    with app.app_context():
        db.create_all()  # Initialize database within an application context
    app.run(debug=True, port=5000, host="0.0.0.0")
