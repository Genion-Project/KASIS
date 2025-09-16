import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://bendahara.ecotrace.site'; // ganti sesuai server

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // sukses
    } else {
      // jika gagal login
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login gagal');
    }
  }
}
