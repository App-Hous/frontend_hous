import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/project_service.dart';
import 'obra_visualizar_page.dart';

class ListaObrasPage extends StatefulWidget {
  const ListaObrasPage({super.key});

  @override
  State<ListaObrasPage> createState() => _ListaObrasPageState();
}

class _ListaObrasPageState extends State<ListaObrasPage> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  bool _isLoading = true;
  List<Map<String, dynamic>> obras = [];
  String _filtroAtual = 'Todos';
  final List<String> _filtros = ['Todos', 'Em Andamento', 'Planejamento', 'Concluído'];

  @override
  void initState() {
    super.initState();
    _carregarObras();
  }

  void _carregarObras() async {
    try {
      final dados = await ProjectService.getProjects();
      setState(() {
        obras = dados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar obras: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get obrasFiltradas {
    if (_filtroAtual == 'Todos') return obras;
    String statusFiltro = '';
    switch (_filtroAtual) {
      case 'Em Andamento':
        statusFiltro = 'in_progress';
        break;
      case 'Planejamento':
        statusFiltro = 'planning';
        break;
      case 'Concluído':
        statusFiltro = 'finished';
        break;
    }
    return obras.where((obra) => obra['status'] == statusFiltro).toList();
  }

  String traduzirStatus(String status) {
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

  Color corStatus(String status) {
    switch (status) {
      case 'planning':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'finished':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Text(
          'Obras',
          style: GoogleFonts.poppins(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2C3E50)),
                  SizedBox(height: 16),
                  Text(
                    'Carregando obras...',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF2C3E50),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                obrasFiltradas.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.construction,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma obra encontrada',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tente mudar o filtro ou adicione uma nova obra',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final obra = obrasFiltradas[index];
                              final status = obra['status'] ?? 'unknown';
                              final orcamento = (obra['budget'] ?? 0).toDouble();
                              final gastoAtual = (obra['current_expenses'] ?? 0).toDouble();
                              final percentGasto = orcamento > 0 ? (gastoAtual / orcamento * 100).clamp(0, 100) : 0;

                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 2,
                                margin: EdgeInsets.only(bottom: 16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ObraVisualizarPage(obra: obra),
                                      ),
                                    );
                                  },
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
                                                obra['name'] ?? 'Sem nome',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2C3E50),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: corStatus(status).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                traduzirStatus(status),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: corStatus(status),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                obra['address'] ?? 'Sem endereço',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.attach_money, size: 18, color: Colors.grey[600]),
                                            SizedBox(width: 4),
                                            Text(
                                              "Orçamento: ${currencyFormat.format(orcamento)}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
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
                                                        'Gasto: ${currencyFormat.format(gastoAtual)}',
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
                              );
                            },
                            childCount: obrasFiltradas.length,
                          ),
                        ),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/obras/nova'),
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF2C3E50),
      ),
    );
  }
}
