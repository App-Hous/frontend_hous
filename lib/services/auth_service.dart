import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000'; // IP local

  static Future<bool> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/api/v1/login/access-token');
    print('Enviando login para \$url com \$email e senha...');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': senha,
        },
      );

      print('Status: \${response.statusCode}');
      print('Body: \${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          return true;
        } else {
          throw Exception('Token não encontrado na resposta');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Erro desconhecido');
      }
    } catch (e) {
      print('Erro ao fazer login: \$e');
      throw Exception('Erro ao fazer login: \$e');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
