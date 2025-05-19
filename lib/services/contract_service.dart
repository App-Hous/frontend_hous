import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContractService {
  static const String baseUrl = 'http://localhost:8000';

  static Future<List<Map<String, dynamic>>> getContracts() async {
    final token = await _getToken();
    print('Token para requisição de contratos: $token');

    final url = Uri.parse('$baseUrl/api/v1/contracts/');
    print('URL da requisição: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status da resposta: ${response.statusCode}');
    print('Corpo da resposta: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao buscar contratos: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getContract(int id) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/contracts/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar contrato: ${response.body}');
    }
  }

  static Future<void> createContract({
    required String contractNumber,
    required String title,
    required String type,
    required String propertyType,
    required String description,
    required int clientId,
    required int propertyId,
    required DateTime signingDate,
    required DateTime expirationDate,
    required double contractValue,
    required String status,
    required String notes,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/contracts/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'contract_number': contractNumber,
        'title': title,
        'type': type,
        'property_type': propertyType,
        'description': description,
        'client_id': clientId,
        'property_id': propertyId,
        'signing_date': signingDate.toIso8601String().split('T')[0],
        'expiration_date': expirationDate.toIso8601String().split('T')[0],
        'contract_value': contractValue,
        'status': status,
        'notes': notes,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao criar contrato: ${response.body}');
    }
  }

  static Future<void> updateContract({
    required int id,
    required String numero,
    required String tipo,
    required int clienteId,
    required int propriedadeId,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valor,
    required String status,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/contracts/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'contract_number': numero,
        'type': tipo,
        'client_id': clienteId,
        'property_id': propriedadeId,
        'signing_date': dataInicio.toIso8601String().split('T')[0],
        'expiration_date': dataFim.toIso8601String().split('T')[0],
        'contract_value': valor,
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar contrato: ${response.body}');
    }
  }

  static Future<void> deleteContract(int id) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/contracts/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao deletar contrato: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getContractDocuments(
      int contractId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/contracts/$contractId/documents');

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
      throw Exception(
          'Erro ao buscar documentos do contrato: ${response.body}');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
