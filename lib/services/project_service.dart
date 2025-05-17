import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProjectService {
  static const String baseUrl = 'http://localhost:8000';

  static Future<List<Map<String, dynamic>>> getProjects() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/projects/');

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
      throw Exception('Erro ao buscar projetos: ${response.body}');
    }
  }

  static Future<void> createProject({
    required String nome,
    required String descricao,
    required String endereco,
    required String cidade,
    required String estado,
    required String cep,
    required double areaTotal,
    required double orcamento,
    required DateTime dataInicio,
    required DateTime dataFimPrevista,
    required DateTime dataFimReal,
    required String status,
    required int companyId,
    required int managerId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/projects/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': nome,
        'description': descricao,
        'address': endereco,
        'city': cidade,
        'state': estado,
        'zip_code': cep,
        'total_area': areaTotal,
        'budget': orcamento,
        'start_date': dataInicio.toIso8601String(),
        'expected_end_date': dataFimPrevista.toIso8601String(),
        'actual_end_date': dataFimReal.toIso8601String(),
        'status': status,
        'company_id': companyId,
        'manager_id': managerId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao criar projeto: ${response.body}');
    }
  }

  static Future<void> updateProject({
    required int id,
    required String nome,
    required String descricao,
    required String endereco,
    required String cidade,
    required String estado,
    required String cep,
    required double areaTotal,
    required double orcamento,
    required DateTime dataInicio,
    required DateTime dataFimPrevista,
    required DateTime dataFimReal,
    required String status,
    required int companyId,
    required int managerId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/projects/$id');
    print('>>> Atualizando obra:');
print(jsonEncode({
  'name': nome,
  'description': descricao,
  'address': endereco,
  'city': cidade,
  'state': estado,
  'zip_code': cep,
  'total_area': areaTotal,
  'budget': orcamento,
  'start_date': dataInicio.toIso8601String().split("T")[0],
  'expected_end_date': dataFimPrevista.toIso8601String().split("T")[0],
  'actual_end_date': dataFimReal.toIso8601String().split("T")[0],
  'status': status,
  'company_id': companyId,
  'manager_id': managerId,
}));


    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': nome,
        'description': descricao,
        'address': endereco,
        'city': cidade,
        'state': estado,
        'zip_code': cep,
        'total_area': areaTotal,
        'budget': orcamento,
        'start_date': dataInicio.toIso8601String().split("T")[0],
        'expected_end_date': dataFimPrevista.toIso8601String().split("T")[0],
        'actual_end_date': dataFimReal.toIso8601String().split("T")[0],
        'status': status,
        'company_id': companyId,
        'manager_id': managerId,
      }),
    );

    if (response.statusCode != 200) {
      final erro = jsonDecode(response.body);
      throw Exception(erro['detail'] ?? 'Erro ao atualizar projeto.');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> deleteProject(int id) async {
  final token = await _getToken();
  final url = Uri.parse('$baseUrl/api/v1/projects/$id');

  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Erro ao deletar projeto: ${response.body}');
  }
}

}
