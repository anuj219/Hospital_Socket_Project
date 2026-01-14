import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

// At the very top of main.dart, outside any class:
const String globalServerIp = '192.168.29.118'; // Put your real IP here
const int globalServerPort = 5000;

void main() {
  runApp(const VitalSyncApp());
}

class VitalSyncApp extends StatelessWidget {
  const VitalSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const PatientSelectionScreen(),
    );
  }
}

// --- SCREEN 1: SELECT PATIENT ---
class PatientSelectionScreen extends StatefulWidget {
  const PatientSelectionScreen({super.key});

  @override
  State<PatientSelectionScreen> createState() => _PatientSelectionScreenState();
}

class _PatientSelectionScreenState extends State<PatientSelectionScreen> {
  List<dynamic> patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final socket = await Socket.connect(globalServerIp, 5000, timeout: const Duration(seconds: 3));
      socket.write(jsonEncode({"action": "FETCH_PATIENTS"}));
      
      await socket.listen((data) {
        setState(() {
          patients = jsonDecode(utf8.decode(data));
          isLoading = false;
        });
      }).asFuture();
      await socket.close();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server Offline")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Patient Ward")),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final p = patients[index];
              return ListTile(
                leading: const Icon(Icons.bed_outlined),
                title: Text(p['name']),
                subtitle: Text("ID: ${p['id']} | ${p['room']}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => NurseHomeScreen(patient: p))
                ),
              );
            },
          ),
    );
  }
}

// --- SCREEN 2: NURSE DASHBOARD ---
class NurseHomeScreen extends StatefulWidget {
  final Map<dynamic, dynamic> patient;
  const NurseHomeScreen({super.key, required this.patient});

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  double _heartRate = 75;
  double _spo2 = 98;

  Future<void> _send(bool isEmergency) async {
    try {
      final socket = await Socket.connect(globalServerIp, 5000); // CHANGE TO YOUR IP
      socket.write(jsonEncode({
        "action": "LOG_DATA",
        "patient_id": widget.patient['id'],
        "heart_rate": _heartRate.toInt(),
        "spo2": _spo2.toInt(),
        "is_emergency": isEmergency ? 1 : 0,
        "message": isEmergency ? "EMERGENCY: Room ${widget.patient['room']}" : "Routine"
      }));
      await socket.close();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Sent")));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Monitoring: ${widget.patient['name']}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Heart Rate: ${_heartRate.toInt()}"),
            Slider(value: _heartRate, min: 40, max: 180, onChanged: (v) => setState(() => _heartRate = v)),
            Text("SpO2: ${_spo2.toInt()}%"),
            Slider(value: _spo2, min: 70, max: 100, onChanged: (v) => setState(() => _spo2 = v)),
            const Spacer(),
            ElevatedButton(onPressed: () => _send(false), child: const Text("Log Vitals")),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _send(true), 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("EMERGENCY"),
            ),
          ],
        ),
      ),
    );
  }
}