import socket
import json
import database

HOST = "0.0.0.0"
PORT = 5000

def start_server():
    database.init_db()
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((HOST, PORT))
    server.listen(5)
    print(f"[*] Hospital Server running on port {PORT} ...")

    while True:
        client_socket, addr = server.accept()
        try:
            data = client_socket.recv(1024).decode("utf-8")
            if not data:
                continue

            request = json.loads(data)
            action = request.get("action")

            if action == "FETCH_PATIENTS":
                patients = database.get_all_patients()
                client_socket.send(json.dumps(patients).encode("utf-8"))
                print("[*] Sent patient list to app")

            elif action == "LOG_DATA":
                database.add_log(
                    request.get("patient_id"),
                    request.get("heart_rate"),
                    request.get("spo2"),
                    request.get("is_emergency"),
                    request.get("message"),
                )

                client_socket.send(
                    json.dumps({"status": "SUCCESS"}).encode("utf-8")
                )
                print(f"[*] Logged data for {request.get('patient_id')}")

        except Exception as e:
            print("[X] Error:", e)

        finally:
            client_socket.close()


if __name__ == "__main__":
    start_server()
