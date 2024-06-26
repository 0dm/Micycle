from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import hashlib
import os
from flask import redirect;

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
    if user and user.stripe_customer_id is None:  # Check if the user exists and doesn't already have a Stripe customer ID
        try:
            # Create a new Stripe Customer
            customer = stripe.Customer.create(
                email=data["email"],
                name=data.get("displayName", "")
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
        return jsonify({"error": "User already has a Stripe customer ID or does not exist"}), 409



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
        stripe_customer_id=customer.id  # Save the Stripe customer ID
    )
    db.session.add(new_user)
    db.session.commit()

    # Create a Stripe Checkout Session for payment
    checkout_session = stripe.checkout.Session.create(
        customer=customer.id,
        payment_method_types=['card'],
        mode='setup',
        success_url=request.host_url + 'success?session_id={CHECKOUT_SESSION_ID}',
        cancel_url=request.host_url + 'cancel',
    )

    return jsonify({'url': checkout_session.url}), 200



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
    if not session_id:
        return jsonify({"error": "Session ID not provided"}), 400

    try:
        # Retrieve the session
        session = stripe.checkout.Session.retrieve(session_id)

        # Retrieve the customer and set the default payment method
        customer = stripe.Customer.retrieve(session.customer)
        payment_method = stripe.PaymentMethod.list(customer=customer.id, type="card").data[0]
        stripe.Customer.modify(
            customer.id,
            invoice_settings={'default_payment_method': payment_method.id},
        )

        # Redirect to the login page or another success page
        return redirect('http://172.174.183.117:5000/#/login', code=302)
    except Exception as e:
        app.logger.error(f"Error processing payment success: {e}")
        return jsonify({"error": "Failed to process payment success"}), 500


@app.route('/charge_user', methods=['POST'])
def charge_user():
    data = request.get_json()
    email = data.get('email')  # Ensure 'email' is sent in your request body
    amount = data.get('amount')  # Amount in the smallest currency unit (e.g., cents for CAD)

    # Search for a Stripe customer by email
    customers = stripe.Customer.list(email=email).data

    # If no customer with that email was found, return an error
    if not customers:
        return jsonify({"error": "Stripe customer not found"}), 404

    # Assuming the first customer returned is the one we want
    customer = customers[0]

    # Retrieve the default payment method for the customer
    default_payment_method = None
    if customer.invoice_settings.default_payment_method:
        default_payment_method = customer.invoice_settings.default_payment_method
    else:
        # Handle case where there's no default payment method
        return jsonify({"error": "No default payment method found for customer"}), 404

    try:
        # Create a PaymentIntent with the customer's default payment method
        payment_intent = stripe.PaymentIntent.create(
            amount=amount,
            currency="cad",
            customer=customer.id,
            payment_method=default_payment_method,
            description="Charge for in-app purchase",
            confirm=True,  # Attempt to confirm the PaymentIntent immediately
            automatic_payment_methods={"enabled": True, "allow_redirects": "never"},
            # Optional: include a return_url for redirect-based payment methods
            # return_url="https://example.com/return",
        )
        return jsonify({"success": True, "payment_intent_id": payment_intent.id}), 200
    except stripe.error.CardError as e:
        # Handle card decline errors
        body = e.json_body
        err = body.get('error', {})
        return jsonify({"error": err.get('message')}), 400
    except stripe.error.StripeError as e:
        # Handle general Stripe errors
        return jsonify({"error": "Stripe error: {}".format(str(e))}), 500
    except Exception as e:
        # Handle other unexpected errors
        return jsonify({"error": "An unexpected error occurred: {}".format(str(e))}), 500


@app.route("/get_user_info/<email>", methods=["GET"])
def get_user_info(email):
    user = User.query.filter_by(email=email).first()
    if user:
        return jsonify({
            "id": user.id,
            "display_name": user.display_name,
            "is_admin": user.is_admin,
            "email": user.email
        }), 200
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

    if user and user.password == password:
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
    app.run(debug=True, port=5000, host="0.0.0.0")
