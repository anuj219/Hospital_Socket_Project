import 'dart:io';
import 'dart:convert';

class SocketService {
  static const int serverPort = 5000;

  static Future<dynamic> sendMessage(String serverIp, Map<String, dynamic> data) async {
    try {
      final socket = await Socket.connect(serverIp, serverPort, timeout: const Duration(seconds: 3));
      socket.write(jsonEncode(data));

      final rawResponse = await socket.first;
      await socket.close();
      
      return jsonDecode(utf8.decode(rawResponse));
    } catch (e) {
      return {"error": e.toString()};
    }
  }
}
