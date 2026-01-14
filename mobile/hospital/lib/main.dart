import 'package:flutter/material.dart';
import 'socket_service.dart';
import 'home_screen.dart';

void main() {
  runApp(const VitalSyncApp());
}

class VitalSyncApp extends StatelessWidget {
  const VitalSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const PatientSelectionScreen(),
    );
  }
}

class PatientSelectionScreen extends StatefulWidget {
  const PatientSelectionScreen({super.key});

  @override
  State<PatientSelectionScreen> createState() => _PatientSelectionScreenState();
}

class _PatientSelectionScreenState extends State<PatientSelectionScreen> {
  List<dynamic> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() async {
    final response = await SocketService.sendMessage({"action": "FETCH_PATIENTS"});
    setState(() {
      if (response is List) {
        _patients = response;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Ward B"), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final p = _patients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("ID: ${p['id']} | Room: ${p['room']}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NurseHomeScreen(patient: p)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}