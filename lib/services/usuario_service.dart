import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  static const String baseUrl = 'http://localhost:8000'; // IP local

  static Future<void> criarUsuario(String nome, String email, String senha, String username) async {
    final url = Uri.parse('$baseUrl/api/v1/users/register');

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
