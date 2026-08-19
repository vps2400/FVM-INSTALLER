#!/bin/bash

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}[+] Installing FaiLive2 FVM Panel Dependencies...${NC}"
sudo apt update && sudo apt install -y python3-pip python3-venv git sqlite3 curl

echo -e "${CYAN}[+] Setting up application workspace at /opt/fvm_panel...${NC}"
sudo mkdir -p /opt/fvm_panel
cd /opt/fvm_panel

# Create Virtual Environment
python3 -m venv venv
source venv/bin/activate

# Install Python requirements
pip install --upgrade pip
pip install Flask==2.3.3 psutil==5.9.5 Werkzeug==2.3.7

echo -e "${CYAN}[+] Creating Database and Default Admin Account...${NC}"
mkdir -p instance
cat << 'EOF' > app.py
import os
import sqlite3
import psutil
from flask import Flask, render_template_string, request, redirect, url_for, session, g, flash
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = os.urandom(24)
DATABASE = 'instance/svm.db'

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        os.makedirs('instance', exist_ok=True)
        db = g._database = sqlite3.connect(DATABASE)
        db.row_factory = sqlite3.Row
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

def init_db():
    with app.app_context():
        db = get_db()
        db.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE NOT NULL,
                password TEXT NOT NULL,
                role TEXT NOT NULL
            )
        ''')
        cur = db.execute("SELECT * FROM users WHERE username = 'admin'")
        if not cur.fetchone():
            hashed_pw = generate_password_hash('admin')
            db.execute(
                "INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)",
                ('admin', 'admin@gmail.com', hashed_pw, 'admin')
            )
            db.commit()

@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        cur = db.execute("SELECT * FROM users WHERE username = ? OR email = ?", (username, username))
        user = cur.fetchone()
        
        if user and check_password_hash(user['password'], password):
            session['user_id'] = user['id']
            session['username'] = user['username']
            session['role'] = user['role']
            return redirect(url_for('dashboard'))
        flash('Invalid username or password!', 'danger')
    return render_template_string('''
    <!DOCTYPE html>
    <html lang="en">
    <head><title>Login - FVM Panel</title>
    <style>
        body { background: #0b0f19; color: #f3f4f6; font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: #111827; padding: 40px; border-radius: 12px; border: 1px solid #1f2937; width: 320px; box-shadow: 0 4px 20px rgba(0,0,0,0.5); }
        input { width: 100%; padding: 10px; margin: 10px 0; background: #1f2937; border: 1px solid #374151; color: #fff; border-radius: 6px; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #3b82f6; border: none; color: white; font-weight: bold; border-radius: 6px; cursor: pointer; }
        button:hover { background: #2563eb; }
        h2 { text-align: center; margin-top: 0; }
    </style>
    </head>
    <body>
        <div class="card">
            <h2>FaiLive2 FVM</h2>
            {% with messages = get_flashed_messages() %}
              {% if messages %}<p style="color:#ef4444;text-align:center;">{{ messages[0] }}</p>{% endif %}
            {% endwith %}
            <form method="POST">
                <label>Email or Username</label>
                <input type="text" name="username" placeholder="admin@gmail.com" required>
                <label>Password</label>
                <input type="password" name="password" placeholder="admin" required>
                <button type="submit">Login</button>
            </form>
        </div>
    </body>
    </html>
    ''')

@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    return render_template_string('''
    <!DOCTYPE html>
    <html lang="en">
    <head><title>Dashboard - FVM</title>
    <style>
        body { background: #0b0f19; color: #f3f4f6; font-family: sans-serif; margin: 0; display: flex; }
        .sidebar { width: 220px; background: #111827; height: 100vh; padding: 20px; border-right: 1px solid #1f2937; }
        .content { flex: 1; padding: 40px; }
        a { color: #3b82f6; text-decoration: none; display: block; margin: 15px 0; }
        .card { background: #111827; padding: 20px; border-radius: 8px; border: 1px solid #1f2937; }
    </style>
    </head>
    <body>
        <div class="sidebar">
            <h3>FaiLive2 FVM</h3>
            <a href="/dashboard">Dashboard</a>
            <a href="/system">System Info</a>
            <a href="/logout" style="color:#ef4444;">Logout</a>
        </div>
        <div class="content">
            <h2>Welcome, {{ username }}!</h2>
            <div class="card">
                <p>Your panel is fully active and running.</p>
                <p>Default Admin: <strong>admin@gmail.com</strong> | Password: <strong>admin</strong></p>
            </div>
        </div>
    </body>
    </html>
    ''', username=session['username'])

@app.route('/system')
def system():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    cpu = psutil.cpu_percent(interval=0.2)
    mem = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    return render_template_string('''
    <!DOCTYPE html>
    <html lang="en">
    <head><title>System - FVM</title>
    <style>
        body { background: #0b0f19; color: #f3f4f6; font-family: sans-serif; margin: 0; display: flex; }
        .sidebar { width: 220px; background: #111827; height: 100vh; padding: 20px; border-right: 1px solid #1f2937; }
        .content { flex: 1; padding: 40px; }
        a { color: #3b82f6; text-decoration: none; display: block; margin: 15px 0; }
        .card { background: #111827; padding: 20px; border-radius: 8px; border: 1px solid #1f2937; }
    </style>
    </head>
    <body>
        <div class="sidebar">
            <h3>FaiLive2 FVM</h3>
            <a href="/dashboard">Dashboard</a>
            <a href="/system">System Info</a>
            <a href="/logout" style="color:#ef4444;">Logout</a>
        </div>
        <div class="content">
            <h2>System Metrics</h2>
            <div class="card">
                <p>CPU Usage: {{ cpu }}%</p>
                <p>RAM Used: {{ mem.used // (1024**2) }} MB / {{ mem.total // (1024**2) }} MB ({{ mem.percent }}%)</p>
                <p>Disk Used: {{ disk.used // (1024**3) }} GB / {{ disk.total // (1024**3) }} GB ({{ disk.percent }}%)</p>
            </div>
        </div>
    </body>
    </html>
    ''', cpu=cpu, mem=mem, disk=disk)

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=3000)
EOF

python3 -m pip install --no-cache-dir -r <(echo -e "Flask==2.3.3\npsutil==5.9.5\nWerkzeug==2.3.7")

echo -e "${GREEN}[✓] FaiLive2 FVM Panel successfully set up! Starting application on port 3000...${NC}"
nohup python3 app.py > panel.log 2>&1 &
echo -e "${GREEN}[✓] Access your panel via browser using port 3000 with login: admin@gmail.com / admin${NC}"
