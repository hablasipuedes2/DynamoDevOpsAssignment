from flask import Flask, request, jsonify
from db import get_connection, wait_for_db, create_table

app = Flask(__name__)
create_table()

@app.route("/users", methods=["POST"])
def create_user():
    data = request.json
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO users (name, email) VALUES (%s, %s) RETURNING id",
        (data.get("name"), data.get("email"))
    )
    user_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "User created", "id": user_id}), 201

@app.route("/users", methods=["GET"])
def read_users():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM users")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify([{"id": r[0], "name": r[1], "email": r[2]} for r in rows])

@app.route("/users/<int:user_id>", methods=["PUT"])
def update_user(user_id):
    data = request.json
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        "UPDATE users SET name=%s, email=%s WHERE id=%s",
        (data.get("name"), data.get("email"), user_id)
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "User updated"})

@app.route("/users/<int:user_id>", methods=["DELETE"])
def delete_user(user_id):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM users WHERE id=%s", (user_id,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "User deleted"})

@app.route("/ping", methods=["GET"])
def ping():
    wait_for_db()
    return "pong"

@app.route("/", methods=["GET"])
def index():
    return "Hello world!"

if __name__ == "__main__":
    app.run()