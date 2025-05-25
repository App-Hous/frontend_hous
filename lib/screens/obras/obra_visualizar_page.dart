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
    
    final status = obra['status'] as String? ?? 'unknown';
    Color statusColor = Colors.grey;
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
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF34495E),
                    Color(0xFF2C3E50),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      obra['name'] ?? 'Sem nome',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        traduzirStatus(status),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/obras/editar',
                    arguments: obra,
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  obra['address'] ?? 'Sem endereço',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (obra['city'] != null || obra['state'] != null) ...[
                            SizedBox(height: 4),
                            Padding(
                              padding: EdgeInsets.only(left: 28),
                              child: Text(
                                '${obra['city'] ?? ''}${obra['city'] != null && obra['state'] != null ? ' - ' : ''}${obra['state'] ?? ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
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
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      currencyFormat.format(orcamento),
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
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
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      currencyFormat.format(gastoAtual),
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
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
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progresso do Orçamento',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${percentGasto.toStringAsFixed(0)}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
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
                              SizedBox(height: 8),
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
                                  minHeight: 8,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações Gerais',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildInfoItem(
                            'Descrição',
                            obra['description']?.toString() ?? '---',
                            Icons.description_outlined,
                          ),
                          _buildInfoItem(
                            'Área Total',
                            '${formatarValor(obra['total_area'])} m²',
                            Icons.square_foot,
                          ),
                          _buildInfoItem(
                            'CEP',
                            obra['zip_code']?.toString() ?? '---',
                            Icons.location_on_outlined,
                          ),
                          Divider(height: 32),
                          _buildInfoItem(
                            'Gerente',
                            obra['manager_name']?.toString() ?? 'ID ${obra['manager_id'] ?? 'Não atribuído'}',
                            Icons.person_outline,
                          ),
                          _buildInfoItem(
                            'Empresa',
                            obra['company_name']?.toString() ?? 'ID ${obra['company_id'] ?? 'Não atribuída'}',
                            Icons.business_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cronograma',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildInfoItem(
                            'Data de Início',
                            formatarData(obra['start_date']?.toString()),
                            Icons.calendar_today_outlined,
                          ),
                          _buildInfoItem(
                            'Previsão de Término',
                            formatarData(obra['expected_end_date']?.toString()),
                            Icons.event_outlined,
                          ),
                          if (status == 'finished')
                            _buildInfoItem(
                              'Término Real',
                              formatarData(obra['actual_end_date']?.toString()),
                              Icons.event_available_outlined,
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/obras/editar',
                              arguments: obra,
                            );
                          },
                          icon: Icon(Icons.edit),
                          label: Text('Editar Obra'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Confirmar Exclusão',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Tem certeza que deseja excluir esta obra?',
                                  style: GoogleFonts.poppins(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cancelar',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // fecha o dialog
                                      Navigator.pop(context); // volta para a lista
                                      // TODO: Implementar a exclusão da obra
                                    },
                                    child: Text(
                                      'Excluir',
                                      style: GoogleFonts.poppins(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(Icons.delete_outline),
                          label: Text('Excluir'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
