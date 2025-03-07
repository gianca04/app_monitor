import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String apiUrl = "http://TU_SERVIDOR/login.php"; // Cambia por tu servidor

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {"email": email, "password": password},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {"status": "error", "message": "Error de conexión"};
    }
  }
}
