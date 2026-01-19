import 'package:flutter/material.dart';
import 'socket_service.dart';

class NurseHomeScreen extends StatefulWidget {
  final Map<dynamic, dynamic> patient;
  final String serverIp;
  const NurseHomeScreen({
    super.key,
    required this.patient,
    required this.serverIp,
  });

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  double _heartRate = 75;
  double _spo2 = 98;
  String _statusMessage = "System Ready";

  void _sendData(bool isEmergency) async {
    setState(() => _statusMessage = "Sending...");

    final response = await SocketService.sendMessage(widget.serverIp, {
      "action": "LOG_DATA",
      "patient_id": widget.patient['id'],
      "heart_rate": _heartRate.toInt(),
      "spo2": _spo2.toInt(),
      "is_emergency": isEmergency ? 1 : 0,
      "message":
          isEmergency
              ? "EMERGENCY: Room ${widget.patient['room']}"
              : "Routine Log",
    });

    setState(() {
      if (response.containsKey('error')) {
        _statusMessage = "Error: Server Offline";
      } else {
        // This is the Bi-directional part!
        // The UI changes based on what the SERVER decided.
        _statusMessage = response['msg'];

        if (response['status'] == "CRITICAL") {
          // Show a dialog that was triggered by the Server's response
          _showEmergencyDialog(response['doctor_assigned'], response['eta']);
        }
      }
    });
  }

  // helper func to show a popup
  void _showEmergencyDialog(String doctor, String eta) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Emergency Confirmed",
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              "The server has dispatched $doctor. Expected ETA: $eta.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isUnsafe = _heartRate > 120 || _heartRate < 50 || _spo2 < 90;

    return Scaffold(
      appBar: AppBar(title: Text("Monitoring: ${widget.patient['name']}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Patient Info Header
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isUnsafe ? Colors.red[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isUnsafe ? Colors.red : Colors.blue),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monitor_heart,
                    color: isUnsafe ? Colors.red : Colors.blue,
                    size: 40,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Room: ${widget.patient['room']} | ID: ${widget.patient['id']}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Heart Rate Slider
            Text(
              "Heart Rate: ${_heartRate.toInt()} BPM",
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: _heartRate,
              min: 40,
              max: 180,
              activeColor: _heartRate > 120 ? Colors.red : Colors.green,
              onChanged: (v) => setState(() => _heartRate = v),
            ),

            const SizedBox(height: 20),

            // SpO2 Slider
            Text(
              "Oxygen Level (SpO2): ${_spo2.toInt()}%",
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: _spo2,
              min: 70,
              max: 100,
              activeColor: _spo2 < 90 ? Colors.red : Colors.blue,
              onChanged: (v) => setState(() => _spo2 = v),
            ),

            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sendData(false),
                    icon: const Icon(Icons.history),
                    label: const Text("Log Vitals"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendData(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.warning),
                    label: const Text("EMERGENCY"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Status Monitor Area
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: Text(
                _statusMessage,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
