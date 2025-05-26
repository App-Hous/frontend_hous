import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServicoService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  static Future<List<Map<String, dynamic>>> getServicos() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/properties');

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
      throw Exception('Erro ao buscar serviços');
    }
  }

  static Future<void> criarServico(String nome, String descricao, int progresso, int obraId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/properties');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
        'descricao': descricao,
        'progresso': progresso,
        'obra_id': obraId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar serviço');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
