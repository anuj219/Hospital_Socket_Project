import 'dart:io';
import 'dart:convert';

class SocketService {
  static const int serverPort = 5000;

  static Future<dynamic> sendMessage(String serverIp, Map<String, dynamic> data) async {
    try {
      final socket = await Socket.connect(serverIp, serverPort, timeout: const Duration(seconds: 3));  //included a 3-second timeout to handle network latencies gracefully

      socket.write(jsonEncode(data));
      // serialize our patient data into a JSON string before transmission, ensuring backend can easily parse the data sent

      final rawResponse = await socket.first;
      await socket.close();
      
      return jsonDecode(utf8.decode(rawResponse));
    } catch (e) {
      return {"error": e.toString()};
    }
  }
}
