import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ObraVisualizarPage extends StatelessWidget {
  final Map<String, dynamic> obra;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');

  ObraVisualizarPage({super.key, required this.obra});

  String traduzirStatus(String? status) {
    switch (status) {
      case 'planning':
        return 'Planejamento';
      case 'in_progress':
        return 'Em andamento';
      case 'finished':
        return 'Concluído';
      default:
        return 'Indefinido';
    }
  }

  // Formatar data com segurança
  String formatarData(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Não definida';
    }
    
    try {
      final date = DateTime.parse(dateString);
      return dateFormat.format(date);
    } catch (e) {
      print('Erro ao formatar data: $e');
      return 'Data inválida';
    }
  }
  
  // Formatar valor numérico com segurança
  String formatarValor(dynamic valor, {String sufixo = ''}) {
    if (valor == null) {
      return '---';
    }
    
    try {
      if (valor is String) {
        if (valor.isEmpty) return '---';
        final numerico = double.tryParse(valor);
        if (numerico != null) {
          return '$numerico$sufixo';
        }
        return '$valor$sufixo';
      }
      return '$valor$sufixo';
    } catch (e) {
      print('Erro ao formatar valor: $e');
      return '---';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double orcamento = (obra['budget'] is num) 
        ? (obra['budget'] as num).toDouble() 
        : 0.0;
        
    final double gastoAtual = (obra['current_expenses'] is num) 
        ? (obra['current_expenses'] as num).toDouble() 
        : 0.0;
        
    final percentGasto = orcamento > 0 
        ? (gastoAtual / orcamento * 100).clamp(0, 100) 
        : 0.0;
    
    Color statusColor;
    final status = obra['status'] as String? ?? 'unknown';
    switch (status) {
      case 'planning':
        statusColor = Colors.orange;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        break;
      case 'finished':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Obra'),
        backgroundColor: Color(0xFF2C3E50),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            obra['name']?.toString() ?? 'Sem nome',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            traduzirStatus(status),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            obra['address']?.toString() ?? 'Sem endereço',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (obra['city'] != null || obra['state'] != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(width: 26), // Alinhamento com o ícone acima
                          Expanded(
                            child: Text(
                              '${obra['city'] ?? ''}${obra['city'] != null && obra['state'] != null ? ' - ' : ''}${obra['state'] ?? ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orçamento',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                currencyFormat.format(orcamento),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gasto Atual',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                currencyFormat.format(gastoAtual),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: percentGasto > 90 
                                    ? Colors.red 
                                    : percentGasto > 70 
                                      ? Colors.orange 
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progresso',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${percentGasto.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: percentGasto > 90 
                                        ? Colors.red 
                                        : percentGasto > 70 
                                          ? Colors.orange 
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentGasto / 100,
                                  backgroundColor: Colors.grey[200],
                                  color: percentGasto > 90 
                                    ? Colors.red 
                                    : percentGasto > 70 
                                      ? Colors.orange 
                                      : Colors.green,
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações Gerais',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildItem('Descrição', obra['description']?.toString()),
                    _buildItem('Área Total', '${formatarValor(obra['total_area'])} m²'),
                    _buildItem('CEP', obra['zip_code']?.toString()),
                    _buildDivider(),
                    _buildItem('Gerente Responsável', obra['manager_name']?.toString() ?? 'ID ${obra['manager_id'] ?? 'Não atribuído'}'),
                    _buildItem('Empresa', obra['company_name']?.toString() ?? 'ID ${obra['company_id'] ?? 'Não atribuída'}'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cronograma',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildItem('Data de Início', formatarData(obra['start_date']?.toString())),
                    _buildItem('Previsão de Término', formatarData(obra['expected_end_date']?.toString())),
                    if (status == 'finished')
                      _buildItem('Término Real', formatarData(obra['actual_end_date']?.toString())),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/obras/editar',
                      arguments: obra,
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Obra'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2C3E50),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/obras/gastos',
                      arguments: obra,
                    );
                  },
                  icon: const Icon(Icons.attach_money),
                  label: const Text('Ver Gastos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF2C3E50),
                    side: BorderSide(color: Color(0xFF2C3E50)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1),
    );
  }

  Widget _buildItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '---',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
