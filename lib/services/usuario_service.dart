import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class UsuarioService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  static Future<void> criarUsuario(String nome, String email, String senha, String username) async {
    final url = Uri.parse('$baseUrl/api/v1/users/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': nome,
        'email': email,
        'password': senha,
        'username': username,
        'is_active': true,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final error = jsonDecode(response.body);
      final errorMessage = error['detail'] ?? 'Erro ao criar usuário';
      throw Exception(errorMessage);
    }
  }
}
