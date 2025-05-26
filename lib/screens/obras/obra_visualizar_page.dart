import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/project_service.dart';

class ObraVisualizarPage extends StatefulWidget {
  final Map<String, dynamic> obra;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');

  ObraVisualizarPage({super.key, required this.obra});

  @override
  _ObraVisualizarPageState createState() => _ObraVisualizarPageState();
}

class _ObraVisualizarPageState extends State<ObraVisualizarPage> {
  final ProjectService _projectService = ProjectService();

  String traduzirStatus(String? status) {
    switch (status) {
      case 'planning':
        return 'Planejamento';
      case 'in_progress':
        return 'Em andamento';
      case 'completed':
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
      return widget.dateFormat.format(date);
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

  Future<void> _confirmarExclusao() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir esta obra?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ProjectService.deleteProject(widget.obra['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Obra excluída com sucesso')),
        );
        Navigator.pop(context, true); // Volta para a lista com flag de atualização
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir obra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double orcamento = (widget.obra['budget'] is num) 
        ? (widget.obra['budget'] as num).toDouble() 
        : 0.0;
        
    final double gastoAtual = (widget.obra['current_expenses'] is num) 
        ? (widget.obra['current_expenses'] as num).toDouble() 
        : 0.0;
        
    final percentGasto = orcamento > 0 
        ? (gastoAtual / orcamento * 100).clamp(0, 100) 
        : 0.0;
    
    final status = widget.obra['status'] as String? ?? 'unknown';
    Color statusColor = Colors.grey;
    switch (status) {
      case 'planning':
        statusColor = Colors.orange;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        break;
      case 'completed':
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
                title: Container(
                  width: double.infinity,
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 4,
                    children: [
                      Text(
                        widget.obra['name'] ?? 'Sem nome',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
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
                background: Container(
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
                    arguments: widget.obra,
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
                                  widget.obra['address'] ?? 'Sem endereço',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.obra['city'] != null || widget.obra['state'] != null) ...[
                            SizedBox(height: 4),
                            Padding(
                              padding: EdgeInsets.only(left: 28),
                              child: Text(
                                '${widget.obra['city'] ?? ''}${widget.obra['city'] != null && widget.obra['state'] != null ? ' - ' : ''}${widget.obra['state'] ?? ''}',
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
                                      widget.currencyFormat.format(orcamento),
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
                                      widget.currencyFormat.format(gastoAtual),
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
                            widget.obra['description']?.toString() ?? '---',
                            Icons.description_outlined,
                          ),
                          _buildInfoItem(
                            'Área Total',
                            '${formatarValor(widget.obra['total_area'])} m²',
                            Icons.square_foot,
                          ),
                          _buildInfoItem(
                            'CEP',
                            widget.obra['zip_code']?.toString() ?? '---',
                            Icons.location_on_outlined,
                          ),
                          Divider(height: 32),
                          _buildInfoItem(
                            'Gerente',
                            widget.obra['manager_name']?.toString() ?? 'ID ${widget.obra['manager_id'] ?? 'Não atribuído'}',
                            Icons.person_outline,
                          ),
                          _buildInfoItem(
                            'Empresa',
                            widget.obra['company_name']?.toString() ?? 'ID ${widget.obra['company_id'] ?? 'Não atribuída'}',
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
                            formatarData(widget.obra['start_date']?.toString()),
                            Icons.calendar_today_outlined,
                          ),
                          _buildInfoItem(
                            'Previsão de Término',
                            formatarData(widget.obra['expected_end_date']?.toString()),
                            Icons.event_outlined,
                          ),
                          if (status == 'completed')
                            _buildInfoItem(
                              'Término Real',
                              formatarData(widget.obra['actual_end_date']?.toString()),
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
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/obras/editar',
                              arguments: widget.obra,
                            );
                            if (result == true) {
                              Navigator.pop(context, true); // Volta para a lista com flag de atualização
                            }
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
                          onPressed: _confirmarExclusao,
                          icon: Icon(Icons.delete, color: Colors.red),
                          label: Text('Excluir'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
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
