import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardService {
  static const String apiUrl =
      "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/admin/dashboard";

  static Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["success"] == true) {
        return jsonData["data"];
      } else {
        throw Exception("Error en la respuesta del servidor");
      }
    } else {
      throw Exception("Error HTTP ${response.statusCode}");
    }
  }
}
