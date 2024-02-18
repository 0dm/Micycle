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



# @app.route("/create_stripe_customer", methods=["POST"])
# def create_stripe_customer():
#     data = request.get_json()
#     user = User.query.filter_by(email=data["email"]).first()
#     if user:
#         try:
#             # Create a new Stripe Customer
#             customer = stripe.Customer.create(
#                 email=data["email"],
#                 name=data.get("displayName", ""),
#                 payment_method=data.get("paymentMethodId"),  # Assume this is passed from the frontend
#                 invoice_settings={
#                     'default_payment_method': data.get("paymentMethodId"),
#                 },
#             )
            
#             # Here, you'd save the customer ID to your database
#             user.stripe_customer_id = customer.id  # Assuming you have a stripe_customer_id field in your User model
#             db.session.commit()

#             return jsonify({"stripeCustomerId": customer.id}), 201
            
#         except Exception as e:
#             return jsonify({"error": str(e)}), 500
#     else:
#         return jsonify({"error": "User not found"}), 404




@app.route("/create_account", methods=["POST"])
def create_account():
    data = request.get_json()
    existing_user = User.query.filter_by(email=data["email"]).first()
    if existing_user:
        return jsonify({"error": "This email address already has an account"}), 409

    # Create a Stripe Checkout session
    try:
        checkout_session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=[{
                'price_data': {
                    'currency': 'usd',
                    'product_data': {
                        'name': 'Account Creation Fee',
                    },
                    'unit_amount': 500,  # Set this to the account creation fee
                },
                'quantity': 1,
            }],
            mode='payment',
            success_url=request.host_url + 'success?session_id={CHECKOUT_SESSION_ID}',
            cancel_url=request.host_url + 'cancel',
            metadata={
                'email': data["email"],
                'password': data["password"],  # Storing the password directly for this example
                'display_name': data["displayName"],
                'is_admin': str(data["isAdmin"]),
                'admin_code': data.get("admin_code", ""),
            }
        )
        app.logger.info(f"Checkout session created successfully. Session ID: {checkout_session['id']}")
        return jsonify({'url': checkout_session.url}), 200
    except Exception as e:
        app.logger.error(f"Failed to create account: {e}")  # Log the error
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

@app.route("/success", methods=["GET"])
def payment_success():
    session_id = request.args.get('session_id')
    if session_id:
        try:
            session = stripe.checkout.Session.retrieve(session_id)
            metadata = session.metadata

            new_user = User(
                email=metadata["email"],
                password=metadata["password"],  # Directly using the stored password
                display_name=metadata["display_name"],
                is_admin=metadata["is_admin"] == 'True',
                admin_code=metadata.get("admin_code", ""),
                stripe_customer_id=session.customer  # Save the Stripe customer ID
            )
            db.session.add(new_user)
            db.session.commit()
            # Redirect or respond as needed, e.g., to a login page
            return jsonify({"message": "Account created successfully"}), 201
        except Exception as e:
            return jsonify({"error": "Failed to retrieve session information"}), 500
    else:
        return jsonify({"error": "Session ID not provided"}), 400
    

if __name__ == "__main__":
    with app.app_context():
        db.create_all()  # Initialize database within an application context
    app.run(debug=True)
