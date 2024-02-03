from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Define models
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(80), nullable=False)
    display_name = db.Column(db.String(120), nullable=True)
    is_admin = db.Column(db.Boolean, default=False)
    admin_code = db.Column(db.String(80), nullable=True)

    def __repr__(self):
        return f'<User {self.email}>'

# Create the database tables
@app.before_first_request
def create_tables():
    db.create_all()

# Route for creating an account
@app.route('/create_account', methods=['POST'])
def create_account():
    data = request.json
    user = User(email=data['email'], password=data['password'], display_name=data['displayName'],
                is_admin=data['isAdmin'], admin_code=data.get('adminCode'))
    db.session.add(user)
    db.session.commit()
    return jsonify({"message": "Account created successfully"}), 201

if __name__ == '__main__':
    app.run(debug=True)