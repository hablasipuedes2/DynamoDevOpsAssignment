from flask import Flask
from db import wait_for_db, create_table
from routes import routes

app = Flask(__name__)

# Wait for DB and ensure table exists
wait_for_db()
create_table()

# Register routes
app.register_blueprint(routes)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
