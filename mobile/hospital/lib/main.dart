import 'package:flutter/material.dart';
import 'socket_service.dart';
import 'home_screen.dart';

void main() => runApp(const HospitalApp());

class HospitalApp extends StatelessWidget {
  const HospitalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, 
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue), 
    home: const PatientSelectionScreen());
  }
}

class PatientSelectionScreen extends StatefulWidget {
  const PatientSelectionScreen({super.key});
  @override
  State<PatientSelectionScreen> createState() => _PatientSelectionScreenState();
}

class _PatientSelectionScreenState extends State<PatientSelectionScreen> {
  final TextEditingController _ipController = TextEditingController(text: "192.168.");
  List<dynamic> _patients = [];
  bool _isLoading = false;

  void _loadPatients() async {
    setState(() => _isLoading = true);
    final response = await SocketService.sendMessage(_ipController.text, {"action": "FETCH_PATIENTS"});
    
    setState(() {
      if (response is List) {
        _patients = response;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to connect to Server")));
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Login")),
      body: Column(
        children: [
          // IP INPUT SECTION
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(labelText: "Server IP Address", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _loadPatients, child: const Text("Connect")),
              ],
            ),
          ),
          const Divider(),
          // PATIENT LIST SECTION
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _patients.length,
                    itemBuilder: (context, index) {
                      final p = _patients[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(p['name']),
                        subtitle: Text("ID: ${p['id']} | ${p['room']}"),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NurseHomeScreen(patient: p, serverIp: _ipController.text)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}