import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ContractService {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  static Future<List<Map<String, dynamic>>> getContracts({
    String? search,
    String? status,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await _getToken();

    // Build query parameters
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
      queryParams['search_fields'] =
          'title,contract_number,description,client_name,property_name';
      queryParams['exact_match'] = 'false'; // Permitir busca parcial
    }
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (startDate != null)
      queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null)
      queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

    final url = Uri.parse('$baseUrl/api/v1/contracts/')
        .replace(queryParameters: queryParams);
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

    // Criar FormData para enviar como multipart/form-data
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Adicionar campos obrigatórios
    request.fields['contract_number'] = contractNumber;
    request.fields['type'] = type;
    request.fields['client_id'] = clientId.toString();
    request.fields['property_id'] = propertyId.toString();
    request.fields['signing_date'] =
        signingDate.toIso8601String().split('T')[0];
    request.fields['contract_value'] = contractValue.toString();

    // Adicionar campos opcionais apenas se não estiverem vazios
    if (description.isNotEmpty) {
      request.fields['description'] = description;
    }
    if (expirationDate != null) {
      request.fields['expiration_date'] =
          expirationDate.toIso8601String().split('T')[0];
    }
    if (status.isNotEmpty) {
      request.fields['status'] = status;
    } else {
      // Se status não for fornecido, usar 'pending' como padrão
      request.fields['status'] = 'pending';
    }
    if (notes.isNotEmpty) {
      request.fields['notes'] = notes;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

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
    String? description,
    String? notes,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/contracts/$id');

    // Criar FormData para enviar como multipart/form-data
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Adicionar todos os campos obrigatórios
    request.fields['contract_number'] = numero;
    request.fields['type'] = tipo;
    request.fields['client_id'] = clienteId.toString();
    request.fields['property_id'] = propriedadeId.toString();
    request.fields['signing_date'] = dataInicio.toIso8601String().split('T')[0];
    request.fields['expiration_date'] = dataFim.toIso8601String().split('T')[0];
    request.fields['contract_value'] = valor.toString();
    request.fields['status'] = status;

    // Campos opcionais
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }
    if (notes != null && notes.isNotEmpty) {
      request.fields['notes'] = notes;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar contrato: ${response.body}');
    }
  }

  static Future<void> updateContractStatus({
    required int id,
    required String status,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/v1/contracts/$id');

    // Primeiro, buscar o contrato atual para manter os dados existentes
    final currentContract = await getContract(id);

    // Criar FormData para enviar como multipart/form-data com todos os campos necessários
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Manter todos os campos existentes e apenas alterar o status
    request.fields['contract_number'] =
        currentContract['contract_number']?.toString() ?? '';
    request.fields['type'] = currentContract['type']?.toString() ?? '';
    request.fields['client_id'] =
        currentContract['client_id']?.toString() ?? '';
    request.fields['property_id'] =
        currentContract['property_id']?.toString() ?? '';
    request.fields['signing_date'] =
        currentContract['signing_date']?.toString().split('T')[0] ?? '';
    request.fields['contract_value'] =
        currentContract['contract_value']?.toString() ?? '';
    request.fields['status'] = status; // Apenas este campo será alterado

    // Campos opcionais
    if (currentContract['description'] != null &&
        currentContract['description'].toString().isNotEmpty) {
      request.fields['description'] = currentContract['description'].toString();
    }
    if (currentContract['expiration_date'] != null) {
      request.fields['expiration_date'] =
          currentContract['expiration_date'].toString().split('T')[0];
    }
    if (currentContract['notes'] != null &&
        currentContract['notes'].toString().isNotEmpty) {
      request.fields['notes'] = currentContract['notes'].toString();
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar status do contrato: ${response.body}');
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
