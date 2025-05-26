import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ExpenseService {

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  // Listar todos os gastos
  static Future<List<Map<String, dynamic>>> getExpenses({
    int? skip = 0,
    int? limit = 100,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final queryParams = {
      if (skip != null) 'skip': skip.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final url = Uri.parse('$baseUrl/api/v1/expenses/').replace(queryParameters: queryParams);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erro ao buscar gastos: ${response.statusCode}');
    }
  }

  // Buscar gastos de um projeto específico
  static Future<List<Map<String, dynamic>>> getProjectExpenses(
    int projectId, {
    int? skip = 0,
    int? limit = 100,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final queryParams = {
      if (skip != null) 'skip': skip.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final url = Uri.parse('$baseUrl/api/v1/expenses/project/$projectId').replace(queryParameters: queryParams);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erro ao buscar gastos do projeto: ${response.statusCode}');
    }
  }

  // Buscar soma dos gastos por projeto
  static Future<double> getExpensesSumByProject(int projectId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/expenses/sum/project/$projectId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['total'] ?? 0.0).toDouble();
    } else {
      throw Exception('Erro ao buscar soma dos gastos: ${response.statusCode}');
    }
  }

  // Buscar soma dos gastos por categoria
  static Future<double> getExpensesSumByCategory(int projectId, String category) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/expenses/sum/category/$projectId/$category');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['total'] ?? 0.0).toDouble();
    } else {
      throw Exception('Erro ao buscar soma dos gastos por categoria: ${response.statusCode}');
    }
  }

  // Criar um novo gasto
  static Future<Map<String, dynamic>> createExpense({
    required int projectId,
    required String description,
    required double amount,
    required DateTime date,
    required String expenseType,
    required String category,
    required Map<String, dynamic> expense_in,
    int? propertyId,
    String? notes,
    File? receiptFile,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/expenses/');
    
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Criando o objeto expense_data conforme esperado pelo backend
      final expense_data = {
        'project_id': projectId,
        'description': description,
        'amount': amount,
        'date': DateFormat('dd/MM/yyyy').format(date),
        'expense_type': expenseType,
        'category': category,
      };

      if (propertyId != null) {
        expense_data['property_id'] = propertyId;
      }
      if (notes != null && notes.isNotEmpty) {
        expense_data['notes'] = notes;
      }

      // Enviando expense_data como um campo do formulário
      request.fields['expense_data'] = jsonEncode(expense_data);

      print('Enviando expense_data:');
      print(jsonEncode(expense_data));
      
      // Adiciona o arquivo se existir
      if (receiptFile != null && !kIsWeb && await receiptFile.exists()) {
        var stream = http.ByteStream(receiptFile.openRead());
        var length = await receiptFile.length();
        var multipartFile = http.MultipartFile(
          'receipt',
          stream,
          length,
          filename: receiptFile.path.split('/').last
        );
        request.files.add(multipartFile);
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print('Status code: ${response.statusCode}');
      print('Resposta: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar gasto: ${response.body}');
      }
    } catch (e) {
      print("Erro ao enviar dados: $e");
      throw Exception('Erro ao criar gasto: $e');
    }
  }

  // Obter um gasto específico por ID
  static Future<Map<String, dynamic>> getExpense(int expenseId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/expenses/$expenseId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar gasto: ${response.statusCode}');
    }
  }

  // Atualizar um gasto existente
  static Future<Map<String, dynamic>> updateExpense({
    required int expenseId,
    int? projectId,
    String? description,
    double? amount,
    DateTime? date,
    String? expenseType,
    int? propertyId,
    String? category,
    String? notes,
    File? receiptFile,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/expenses/$expenseId');
    
    // Se não tiver recibo, usa JSON normal
    if (receiptFile == null) {
      final Map<String, dynamic> body = {};
      
      if (projectId != null) body['project_id'] = projectId;
      if (description != null) body['description'] = description;
      if (amount != null) body['amount'] = amount;
      if (date != null) body['date'] = date.toIso8601String();
      if (expenseType != null) body['expense_type'] = expenseType;
      if (propertyId != null) body['property_id'] = propertyId;
      if (category != null) body['category'] = category;
      if (notes != null) body['notes'] = notes;

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao atualizar gasto: ${response.body}');
      }
    } 
    // Se tiver recibo, usa multipart request
    else {
      var request = http.MultipartRequest('PUT', url);
      
      // Adiciona o token de autenticação
      request.headers['Authorization'] = 'Bearer $token';
      
      // Adiciona os campos do formulário
      if (projectId != null) request.fields['project_id'] = projectId.toString();
      if (description != null) request.fields['description'] = description;
      if (amount != null) request.fields['amount'] = amount.toString();
      if (date != null) request.fields['date'] = date.toIso8601String();
      if (expenseType != null) request.fields['expense_type'] = expenseType;
      if (propertyId != null) request.fields['property_id'] = propertyId.toString();
      if (category != null) request.fields['category'] = category;
      if (notes != null) request.fields['notes'] = notes;
      
      // Adiciona o arquivo de recibo
      var fileStream = http.ByteStream(receiptFile.openRead());
      var length = await receiptFile.length();
      var multipartFile = http.MultipartFile(
        'receipt', 
        fileStream, 
        length,
        filename: receiptFile.path.split('/').last
      );
      
      request.files.add(multipartFile);
      
      // Envia a requisição
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao atualizar gasto: ${response.body}');
      }
    }
  }

  // Excluir um gasto
  static Future<Map<String, dynamic>> deleteExpense(int expenseId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/expenses/$expenseId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao excluir gasto: ${response.statusCode}');
    }
  }
} 