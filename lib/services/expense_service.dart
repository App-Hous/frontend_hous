import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

class ExpenseService {
  static const String baseUrl = 'http://localhost:8000'; // Mesma base URL dos outros serviços

  // Listar todos os gastos
  static Future<List<Map<String, dynamic>>> getExpenses() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/expenses/');
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
  static Future<List<Map<String, dynamic>>> getProjectExpenses(int projectId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/expenses/project/$projectId/');
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

  // Criar um novo gasto
  static Future<Map<String, dynamic>> createExpense({
    required int projectId,
    required String description,
    required double amount,
    required DateTime date,
    required String expenseType,
    int? propertyId,
    String? category,
    String? notes,
    File? receiptFile,
    String expense_in = 'obra', // Valor padrão para o campo obrigatório
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/expenses/');
    
    // Se estamos em ambiente web ou se não temos arquivo, usamos JSON direto
    // Ou se o arquivo tem caminho iniciado com "blob:" (que é o caso no web)
    if (receiptFile == null || 
        (receiptFile.path.startsWith('blob:')) ||
        kIsWeb) {
      
      print("Usando fluxo JSON sem arquivo para enviar o gasto");
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'project_id': projectId,
          'description': description,
          'amount': amount,
          'date': date.toIso8601String(),
          'expense_type': expenseType,
          'property_id': propertyId,
          'category': category,
          'notes': notes,
          'expense_in': expense_in, // Campo obrigatório adicionado
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar gasto: ${response.body}');
      }
    } 
    // Se não estamos no web e temos um arquivo válido, tentamos o multipart
    else {
      try {
        // Verifica se o arquivo existe antes de tentar enviar
        bool arquivoValido = false;
        try {
          arquivoValido = await receiptFile.exists();
        } catch (e) {
          print("Erro ao verificar arquivo: $e");
          arquivoValido = false;
        }
        
        // Se o arquivo não existir, voltamos para o fluxo JSON
        if (!arquivoValido) {
          print("Arquivo inválido, usando fluxo JSON");
          return await createExpense(
            projectId: projectId,
            description: description,
            amount: amount,
            date: date,
            expenseType: expenseType,
            propertyId: propertyId,
            category: category,
            notes: notes,
            expense_in: expense_in,
            receiptFile: null, // Remove o arquivo para usar JSON
          );
        }
        
        var request = http.MultipartRequest('POST', url);
        
        // Adiciona o token de autenticação
        request.headers['Authorization'] = 'Bearer $token';
        
        // Adiciona os campos do formulário
        request.fields['project_id'] = projectId.toString();
        request.fields['description'] = description;
        request.fields['amount'] = amount.toString();
        request.fields['date'] = date.toIso8601String();
        request.fields['expense_type'] = expenseType;
        request.fields['expense_in'] = expense_in; // Campo obrigatório adicionado
        
        if (propertyId != null) {
          request.fields['property_id'] = propertyId.toString();
        }
        
        if (category != null) {
          request.fields['category'] = category;
        }
        
        if (notes != null) {
          request.fields['notes'] = notes;
        }
        
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
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          throw Exception('Erro ao criar gasto: ${response.body}');
        }
      } catch (e) {
        print("Erro ao enviar arquivo: $e");
        // Se falhar o upload com arquivo, tenta novamente sem o arquivo
        return await createExpense(
          projectId: projectId,
          description: description,
          amount: amount,
          date: date,
          expenseType: expenseType,
          propertyId: propertyId,
          category: category,
          notes: notes,
          expense_in: expense_in, // Mantém o mesmo valor de expense_in
          receiptFile: null, // Remove o arquivo para tentar novamente
        );
      }
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