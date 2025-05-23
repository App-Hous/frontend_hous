import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000'; // IP local

  static Future<bool> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/api/v1/login/access-token');
    print('Enviando login para $url com $email e senha...');

    try {
      // Convertendo para formato form-urlencoded conforme esperado pelo FastAPI
      final body = {
        'username': email,
        'password': senha,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          
          // Também vamos guardar o token de atualização, se disponível
          if (data['refresh_token'] != null) {
            await prefs.setString('refresh_token', data['refresh_token']);
          }
          
          // Buscar dados do usuário após login bem-sucedido
          await _getUserInfo(token);
          
          print('Token salvo com sucesso: $token');
          return true;
        } else {
          print('Token não encontrado na resposta');
          throw Exception('Token não encontrado na resposta');
        }
      } else {
        final error = jsonDecode(response.body);
        print('Erro na resposta: $error');
        throw Exception(error['detail'] ?? 'Erro desconhecido');
      }
    } catch (e) {
      print('Erro ao fazer login: $e');
      throw Exception('Erro ao fazer login: $e');
    }
  }

  static Future<void> _getUserInfo(String token) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/users/me');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        
        // Salvar informações do usuário
        await prefs.setString('user_data', jsonEncode(userData));
        print('Dados do usuário salvos: $userData');
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
    print('Dados de autenticação removidos');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }
  
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }
}
