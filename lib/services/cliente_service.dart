import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ClienteService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  static Future<List<Map<String, dynamic>>> getClientes() async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/api/v1/clients');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao buscar clientes');
    }
  }

  static Future<void> criarCliente(String nome, String telefone, String email) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/clients');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
        'telefone': telefone,
        'email': email,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar cliente');
    }
  }
}

class AuthService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
