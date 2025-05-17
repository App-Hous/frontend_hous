import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  static const String baseUrl = 'http://localhost:8000'; // IP local

  static Future<void> criarUsuario(String nome, String email, String senha) async {
    final url = Uri.parse('$baseUrl/api/v1/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'full_name': nome,
        'email': email,
        'password': senha,
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar usuário: ${response.body}');
    }
  }
}
