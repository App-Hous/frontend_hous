// lib/services/expense_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ExpenseService {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

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
  static Future<Map<String, dynamic>> createExpense({
    required int projectId,
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    int? propertyId,
    String? supplierName,
    String? supplierDocument,
    String? supplierContact,
    String? receiptDescription,
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

      request.fields['project_id'] = projectId.toString();
      request.fields['description'] = description;
      request.fields['amount'] = amount.toString();
      request.fields['date'] = DateFormat('yyyy-MM-dd').format(date);
      request.fields['category'] = category;

      if (propertyId != null) request.fields['property_id'] = propertyId.toString();
      if (supplierName != null) request.fields['supplier_name'] = supplierName;
      if (supplierDocument != null) request.fields['supplier_document'] = supplierDocument;
      if (supplierContact != null) request.fields['supplier_contact'] = supplierContact;
      if (receiptDescription != null) request.fields['receipt_description'] = receiptDescription;
      if (notes != null) request.fields['notes'] = notes;

      if (receiptFile != null && !kIsWeb && await receiptFile.exists()) {
        final stream = http.ByteStream(receiptFile.openRead());
        final length = await receiptFile.length();
        final file = http.MultipartFile('receipt', stream, length,
            filename: receiptFile.path.split('/').last);
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar gasto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao criar gasto: $e');
    }
  }

  static Future<Map<String, dynamic>> updateExpense({
    required int expenseId,
    int? projectId,
    String? description,
    double? amount,
    DateTime? date,
    String? category,
    int? propertyId,
    String? supplierName,
    String? supplierDocument,
    String? supplierContact,
    String? receiptDescription,
    String? notes,
    File? receiptFile,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final url = Uri.parse('$baseUrl/api/v1/expenses/$expenseId');

    try {
      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';

      if (projectId != null) request.fields['project_id'] = projectId.toString();
      if (description != null) request.fields['description'] = description;
      if (amount != null) request.fields['amount'] = amount.toString();
      if (date != null) request.fields['date'] = DateFormat('yyyy-MM-dd').format(date);
      if (category != null) request.fields['category'] = category;
      if (propertyId != null) request.fields['property_id'] = propertyId.toString();
      if (supplierName != null) request.fields['supplier_name'] = supplierName;
      if (supplierDocument != null) request.fields['supplier_document'] = supplierDocument;
      if (supplierContact != null) request.fields['supplier_contact'] = supplierContact;
      if (receiptDescription != null) request.fields['receipt_description'] = receiptDescription;
      if (notes != null) request.fields['notes'] = notes;

      if (receiptFile != null && !kIsWeb && await receiptFile.exists()) {
        final stream = http.ByteStream(receiptFile.openRead());
        final length = await receiptFile.length();
        final file = http.MultipartFile('receipt', stream, length,
            filename: receiptFile.path.split('/').last);
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao atualizar gasto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar gasto: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteExpense(int expenseId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

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
