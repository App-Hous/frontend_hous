import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../components/CustomListItem.dart';
import '../../components/CustomSearchBar.dart';
import '../../components/CustomFilterChip.dart';
import '../../components/StatusCard.dart';

class ListaObrasPage extends StatefulWidget {
  const ListaObrasPage({super.key});

  @override
  State<ListaObrasPage> createState() => _ListaObrasPageState();
}

class _ListaObrasPageState extends State<ListaObrasPage> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  bool _isLoading = false;

  // Dados de exemplo - depois serão substituídos pelos dados reais
  final List<Map<String, dynamic>> obras = [
    {
      'nome': 'Residência A',
      'endereco': 'Rua 1, Bairro X',
      'cliente': 'João Silva',
      'status': 'Em Andamento',
      'progresso': 0.65,
      'orcamento': 250000.00,
      'gastos': 150000.00,
      'dataInicio': '2024-01-15',
      'dataPrevisao': '2024-06-30',
      'tipo': 'Residencial',
    },
    {
      'nome': 'Comercial B',
      'endereco': 'Av. 2, Centro',
      'cliente': 'Maria Santos',
      'status': 'Planejamento',
      'progresso': 0.15,
      'orcamento': 120000.00,
      'gastos': 18000.00,
      'dataInicio': '2024-02-01',
      'dataPrevisao': '2024-08-15',
      'tipo': 'Comercial',
    },
    {
      'nome': 'Reforma C',
      'endereco': 'Rua 3, Bairro Y',
      'cliente': 'Pedro Oliveira',
      'status': 'Concluído',
      'progresso': 1.0,
      'orcamento': 80000.00,
      'gastos': 78000.00,
      'dataInicio': '2023-11-01',
      'dataPrevisao': '2024-02-28',
      'tipo': 'Reforma',
    },
  ];

  String _filtroAtual = 'Todos';
  final List<String> _filtros = [
    'Todos',
    'Em Andamento',
    'Planejamento',
    'Concluído',
    'Paralisado',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatusCards(),
                _buildFilterChips(),
                _buildChart(),
              ],
            ),
          ),
          _buildObrasList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/cadastro/obra');
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Nova Obra',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2C3E50),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Obras',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            Text(
              'Gerencie suas obras',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF2C3E50)),
          onPressed: () {
            // TODO: Implementar busca
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Color(0xFF2C3E50)),
          onPressed: () {
            // TODO: Implementar filtros avançados
          },
        ),
      ],
    );
  }

  Widget _buildStatusCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatusCard(
              titulo: 'Obras Ativas',
              valor: obras.length.toString(),
              icone: Icons.construction,
              cor: Colors.blue,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatusCard(
              titulo: 'Total Investido',
              valor: currencyFormat.format(_calcularTotalGastos()),
              icone: Icons.attach_money,
              cor: Colors.green,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filtros.length,
        itemBuilder: (context, index) {
          final filtro = _filtros[index];
          final isSelected = filtro == _filtroAtual;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CustomFilterChip(
              label: filtro,
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filtroAtual = filtro;
                });
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                .slideX(begin: 0.2, end: 0),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progresso das Obras',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final statusCount = <String, int>{};
    for (var obra in obras) {
      statusCount[obra['status']] = (statusCount[obra['status']] ?? 0) + 1;
    }

    return statusCount.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: _getStatusColor(entry.key),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildObrasList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final obra = obras[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/obra/detalhe',
                          arguments: obra,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(obra['status'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getObraIcon(obra['tipo']),
                                    color: _getStatusColor(obra['status']),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        obra['nome'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2C3E50),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        obra['endereco'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(obra['status'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    obra['status'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(obra['status']),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Progresso',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: obra['progresso'],
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            _getStatusColor(obra['status']),
                                          ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${(obra['progresso'] * 100).toInt()}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(obra['status']),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: obras.length,
        ),
      ),
    );
  }

  double _calcularTotalGastos() {
    return obras.fold(0, (sum, obra) => sum + (obra['gastos'] as double));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Em Andamento':
        return Colors.green;
      case 'Planejamento':
        return Colors.orange;
      case 'Concluído':
        return Colors.blue;
      case 'Paralisado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getObraIcon(String tipo) {
    switch (tipo) {
      case 'Residencial':
        return Icons.home;
      case 'Comercial':
        return Icons.store;
      case 'Reforma':
        return Icons.construction;
      default:
        return Icons.business;
    }
  }
}
