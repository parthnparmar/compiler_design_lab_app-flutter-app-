import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Production: https://compiler-design-lab-10.onrender.com
  static const String baseUrl = 'https://compiler-design-lab-10.onrender.com';

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      }
      // Return error body so caller can read message field
      return decoded;
    } catch (e) {
      throw Exception('Cannot connect to server. Make sure Flask is running.\n$e');
    }
  }
}
