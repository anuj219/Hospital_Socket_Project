import socket
import json
import database

HOST = '0.0.0.0'
PORT = 5000

def start_server():
    database.init_db()
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((HOST, PORT))
    server.listen(5)
    print(f"[*] VitalSync Server running on {PORT}...")

    while True:
        client_socket, addr = server.accept()
        try:
            raw_data = client_socket.recv(1024).decode('utf-8')
            if not raw_data: continue
            
            request = json.loads(raw_data)
            action = request.get("action")

            if action == "FETCH_PATIENTS":
                # Send the list of patients back to the app
                patients = database.get_all_patients()
                client_socket.send(json.dumps(patients).encode('utf-8'))
                print("[*] Sent patient list to app")

            elif action == "LOG_DATA":
                # Save vitals/emergency as before
                p_id = request.get("patient_id")
                hr = request.get("heart_rate")
                ox = request.get("spo2")
                status = request.get("is_emergency")
                msg = request.get("message")
                
                database.add_log(p_id, hr, ox, status, msg)
                client_socket.send(json.dumps({"status": "SUCCESS"}).encode('utf-8'))
                print(f"[*] Logged data for {p_id}")

        except Exception as e:
            print(f"[X] Error: {e}")
        finally:
            client_socket.close()

if __name__ == "__main__":
    start_server()