import sqlite3
from datetime import datetime

DB_PATH = "../database/hospital.db"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # 1. Enable Foreign Key support
    cursor.execute("PRAGMA foreign_keys = ON;")

    # 2. Patients Table (Master Table)
    cursor.execute('''CREATE TABLE IF NOT EXISTS patients (
                        patient_id TEXT PRIMARY KEY,
                        name TEXT NOT NULL,
                        age INTEGER,
                        room TEXT)''')

    # 3. Patient Logs Table (Linked via Foreign Key)
    cursor.execute('''CREATE TABLE IF NOT EXISTS patient_logs (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        patient_id TEXT,
                        heart_rate INTEGER,
                        spo2 INTEGER,
                        status INTEGER, 
                        message TEXT,
                        timestamp TEXT,
                        FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE)''')
    
    # 4. Insert dummy patients if table is empty (for testing)
    cursor.execute("SELECT COUNT(*) FROM patients")
    if cursor.fetchone()[0] == 0:
        cursor.execute("INSERT INTO patients VALUES ('P101', 'John Doe', 45, 'Room 302')")
        cursor.execute("INSERT INTO patients VALUES ('P102', 'Jane Smith', 30, 'Room 105')")
        cursor.execute("INSERT INTO patients VALUES ('P103', 'Robert Brown', 62, 'ICU-02')")
    
    conn.commit()
    conn.close()

def get_all_patients():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT patient_id, name, room FROM patients")
    rows = cursor.fetchall()
    conn.close()
    # Convert to list of dictionaries for JSON
    return [{"id": r[0], "name": r[1], "room": r[2]} for r in rows]

def add_log(patient_id, heart_rate, spo2, status, message=""):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    cursor.execute("INSERT INTO patient_logs (patient_id, heart_rate, spo2, status, message, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
                   (patient_id, heart_rate, spo2, status, message, now))
    conn.commit()
    conn.close()