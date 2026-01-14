import 'package:flutter/material.dart';
import 'socket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _heartRate = 75;
  double _spo2 = 98;
  String _patientId = "Room 302";
  String _serverStatus = "Disconnected";

  // Function to send data
  void _sendUpdate({required bool isEmergency, String? msg}) async {
    Map<String, dynamic> payload = {
      "patient_id": _patientId,
      "heart_rate": _heartRate.toInt(),
      "spo2": _spo2.toInt(),
      "is_emergency": isEmergency ? 1 : 0,
      "message": msg ?? (isEmergency ? "Manual Emergency Triggered" : "Routine Check")
    };

    String response = await SocketService.sendData(payload);
    setState(() {
      _serverStatus = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isUnsafe = _heartRate > 120 || _heartRate < 50 || _spo2 < 90;

    return Scaffold(
      appBar: AppBar(
        title: Text("VitalSync Nurse Terminal"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.blue, size: 40),
                title: Text("Patient: John Doe", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("ID: $_patientId | Ward: B-Wing"),
              ),
            ),
            SizedBox(height: 30),

            // Vitals Simulation Section
            Text("Simulate Vitals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            
            // Heart Rate Slider
            Text("Heart Rate: ${_heartRate.toInt()} BPM"),
            Slider(
              value: _heartRate,
              min: 30, max: 180,
              divisions: 150,
              activeColor: _heartRate > 120 ? Colors.red : Colors.green,
              onChanged: (val) => setState(() => _heartRate = val),
            ),

            // SpO2 Slider
            Text("Oxygen Level (SpO2): ${_spo2.toInt()}%"),
            Slider(
              value: _spo2,
              min: 70, max: 100,
              divisions: 30,
              activeColor: _spo2 < 90 ? Colors.red : Colors.blue,
              onChanged: (val) => setState(() => _spo2 = val),
            ),

            SizedBox(height: 20),

            // Automated logic warning
            if (isUnsafe)
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Vitals Unsafe! Alert recommended.", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),

            SizedBox(height: 30),

            // Buttons Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _sendUpdate(isEmergency: false),
                    child: Text("Log Vitals"),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _sendUpdate(isEmergency: true, msg: "CODE BLUE - Critical Condition"),
                    child: Text("EMERGENCY"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),
            Center(child: Text("Server Status: $_serverStatus", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}