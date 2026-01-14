import 'dart:io';
import 'dart:convert';

class SocketService {
  static const String serverIp = '192.168.29.118'; 
  static const int serverPort = 5000;

  static Future<String> sendData(Map<String, dynamic> data) async {
    try {
      // 1. Establish connection
      Socket socket = await Socket.connect(serverIp, serverPort, 
          timeout: Duration(seconds: 5));

      // 2. Send JSON data
      socket.write(jsonEncode(data));

      // 3. Listen for response
      String response = "No response";
      await for (var event in socket) {
        response = utf8.decode(event);
        break; 
      }

      await socket.close();
      return response;
    } catch (e) {
      return "Error: $e";
    }
  }
}