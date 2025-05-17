import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../services/project_service.dart';
import 'obras/obra_visualizar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> projetos = [];
  bool carregando = true;
  int obrasAndamento = 0;
  int entregasSemana = 0;
  double totalGastoMes = 0;
  int orcamentoEstourado = 0;

  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> acoesRapidas = [
    {
      'titulo': 'Nova Obra',
      'icone': Icons.add_circle_outline,
      'rota': '/obras/nova',
    },
    {
      'titulo': 'Registrar Gasto',
      'icone': Icons.payments_outlined,
      'rota': '/gastos/novo',
    },
    {
      'titulo': 'Enviar Documento',
      'icone': Icons.upload_file,
      'rota': '/documentos/enviar',
    },
    {
      'titulo': 'Relatório',
      'icone': Icons.bar_chart,
      'rota': '/relatorios',
    },
    {
      'titulo': 'Buscar Contrato',
      'icone': Icons.search,
      'rota': '/contratos/buscar',
    },
    {
      'titulo': 'Calendário',
      'icone': Icons.calendar_today,
      'rota': '/calendario',
    },
  ];

  @override
  void initState() {
    super.initState();
    _carregarProjetos();
  }

  void _carregarProjetos() async {
    try {
      final data = await ProjectService.getProjects();
      final hoje = DateTime.now();
      final inicioMes = DateTime(hoje.year, hoje.month, 1);
      final fimSemana = hoje.add(Duration(days: 7 - hoje.weekday));

      int andamento = 0;
      int entregas = 0;
      double totalMes = 0;
      int estourados = 0;

      for (var p in data) {
        final status = p['status'] ?? '';
        final gasto = (p['gastoAtual'] ?? 0).toDouble();
        final orcamento = (p['orcamento'] ?? 0).toDouble();

        final inicio = DateTime.tryParse(p['dataInicio'] ?? '') ?? DateTime(2000);
        final entrega = DateTime.tryParse(p['dataPrevista'] ?? '') ?? DateTime(2100);

        if (status == 'Em Andamento') andamento++;
        if (entrega.isAfter(hoje) && entrega.isBefore(fimSemana)) entregas++;
        if (inicio.month == hoje.month && inicio.year == hoje.year) totalMes += gasto;
        if (gasto > orcamento) estourados++;
      }

      setState(() {
        projetos = data;
        obrasAndamento = andamento;
        entregasSemana = entregas;
        totalGastoMes = totalMes;
        orcamentoEstourado = estourados;
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar projetos: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text('Olá, Engenheiro João ',
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                            Text('👷‍♂️', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Text(dateFormat.format(DateTime.now()),
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.filter_list, color: Color(0xFF2C3E50)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: Color(0xFF2C3E50)),
                      onPressed: () {},
                    ),
                    PopupMenuButton<String>(
                      icon: CircleAvatar(
                        backgroundColor: Color(0xFF2C3E50).withOpacity(0.1),
                        child: Icon(Icons.person, color: Color(0xFF2C3E50)),
                      ),
                      onSelected: (value) {
                        if (value == 'perfil') {
                          Navigator.pushNamed(context, '/perfil');
                        } else if (value == 'logout') {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'perfil',
                          child: Row(children: [Icon(Icons.person_outline), SizedBox(width: 8), Text('Perfil')]),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('Sair')]),
                        ),
                      ],
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildKPICard('Obras em andamento', '\$obrasAndamento obras', Icons.construction, Colors.blue),
                        _buildKPICard('Entregas esta semana', '\$entregasSemana obras', Icons.calendar_today, Colors.green),
                        _buildKPICard('Total gasto este mês', currencyFormat.format(totalGastoMes), Icons.payments, Colors.orange),
                        _buildKPICard('Gastos acima do orçamento', '\$orcamentoEstourado obras', Icons.warning, Colors.red),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ações Rápidas',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: acoesRapidas.length,
                          itemBuilder: (context, index) {
                            final acao = acoesRapidas[index];
                            return InkWell(
                              onTap: () => Navigator.pushNamed(context, acao['rota']),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      acao['icone'],
                                      size: 32,
                                      color: Color(0xFF2C3E50),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      acao['titulo'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Color(0xFF2C3E50),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn().scale(begin: Offset(0.8, 0.8), end: Offset(1, 1));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Obras Recentes',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final obra = projetos[index];
                      final status = obra['status'] ?? 'unknown';

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

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            obra['name'] ?? 'Sem nome',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text("📍 ${obra['address'] ?? 'Sem endereço'}"),
                              const SizedBox(height: 4),
                              Text(
                                "📌 ${traduzirStatus(status)}",
                                style: TextStyle(
                                  color: corStatus(status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("💰 Orçamento: ${currencyFormat.format(obra['budget'] ?? 0)}"),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ObraVisualizarPage(obra: obra),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: projetos.length,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/obras/nova'),
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF2C3E50),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/obras/lista');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/contratos/lista');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.construction), label: 'Obras'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Contratos'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 110, maxWidth: 120),
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 16),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
    );
  }
}
