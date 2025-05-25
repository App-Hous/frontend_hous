import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../services/project_service.dart';
import '../services/expense_service.dart';
import '../services/auth_service.dart';
import 'obras/obra_visualizar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> projetos = [];
  bool carregando = true;
  int obrasAndamento = 0;
  int entregasSemana = 0;
  double totalGastoMes = 0;
  int orcamentoEstourado = 0;
  String nomeUsuario = 'Usuário';
  String? cargoUsuario;
  String? userEmail;
  String userInitials = 'U';

  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');
  final dateFormatCompact = DateFormat('dd/MM/yyyy');
  final dateFormatLong = DateFormat("dd 'de' MMMM", 'pt_BR');
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> acoesRapidas = [
    {
      'titulo': 'Nova Obra',
      'icone': Icons.add_circle_outline,
      'rota': '/obras/nova',
      'cor': Color(0xFF3498DB),
    },
    {
      'titulo': 'Registrar Gasto',
      'icone': Icons.payments_outlined,
      'rota': '/gastos/novo',
      'cor': Color(0xFF2ECC71),
    },
    {
      'titulo': 'Buscar Contratos',
      'descricao': 'Pesquise seus contratos',
      'icone': Icons.search,
      'rota': '/contratos/lista',
    },
    {
      'titulo': 'Calendário',
      'icone': Icons.calendar_today,
      'rota': '/calendario',
    },
  ];

  // Função para obter a saudação baseada no horário
  String _getSaudacao() {
    final hora = DateTime.now().hour;
    if (hora >= 4 && hora < 12) {
      return 'Bom dia';
    } else if (hora >= 12 && hora < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Carrega dados do usuário
      await _carregarDadosUsuario();
      
      // Carrega os projetos e estatísticas
      await _carregarProjetosEEstatisticas();
      
      // Carrega gastos do mês
      await _carregarGastosDoMes();
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) {
        setState(() => carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }
  
  Future<void> _carregarDadosUsuario() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null && mounted) {
        setState(() {
          nomeUsuario = userData['full_name'] ?? 'Usuário';
          cargoUsuario = userData['role'] ?? 'Engenheiro';
          userEmail = userData['email'] ?? '';
          
          // Criar iniciais do nome do usuário para o avatar
          if (nomeUsuario.isNotEmpty) {
            final names = nomeUsuario.split(' ');
            if (names.length > 1) {
              userInitials = '${names[0][0]}${names[names.length - 1][0]}';
            } else if (names.length == 1 && names[0].isNotEmpty) {
              userInitials = names[0][0];
            } else {
              userInitials = 'U';
            }
            userInitials = userInitials.toUpperCase();
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _carregarProjetosEEstatisticas() async {
    try {
      final data = await ProjectService.getProjects();
      final hoje = DateTime.now();
      final fimSemana = hoje.add(Duration(days: 7 - hoje.weekday));

      int andamento = 0;
      int entregas = 0;
      int estourados = 0;

      for (var p in data) {
        final status = p['status'] ?? '';
        final gasto = (p['current_expenses'] ?? 0).toDouble();
        final orcamento = (p['budget'] ?? 0).toDouble();
        final dataInicio = DateTime.tryParse(p['dataInicio'] ?? '') ?? DateTime(2000);
        final dataPrevista = DateTime.tryParse(p['expected_end_date'] ?? '') ?? DateTime(2100);

        if (status == 'in_progress') andamento++;
        if (dataPrevista.isAfter(hoje) && dataPrevista.isBefore(fimSemana)) entregas++;
        if (gasto > orcamento) estourados++;
      }

      if (mounted) {
        setState(() {
          projetos = data;
          obrasAndamento = andamento;
          entregasSemana = entregas;
          orcamentoEstourado = estourados;
        });
      }
    } catch (e) {
      print('Erro ao carregar projetos: $e');
      rethrow;
    }
  }
  
  Future<void> _carregarGastosDoMes() async {
    try {
      final gastos = await ExpenseService.getExpenses();
      final hoje = DateTime.now();
      final inicioMes = DateTime(hoje.year, hoje.month, 1);
      final fimMes = DateTime(hoje.year, hoje.month + 1, 0);
      
      double totalMes = 0;
      
      for (var gasto in gastos) {
        final dataGasto = DateTime.tryParse(gasto['date'] ?? '');
        if (dataGasto != null && 
            dataGasto.isAfter(inicioMes) && 
            dataGasto.isBefore(fimMes)) {
          totalMes += (gasto['amount'] ?? 0).toDouble();
        }
      }
      
      if (mounted) {
        setState(() {
          totalGastoMes = totalMes;
          carregando = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar gastos do mês: $e');
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final hoje = DateTime.now();
    final dataFormatada = dateFormatLong.format(hoje);
    final saudacao = _getSaudacao();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: carregando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2C3E50)),
                  SizedBox(height: 16),
                  Text(
                    'Carregando suas informações...',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF2C3E50),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarDados,
              color: Color(0xFF2C3E50),
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: true,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text('Olá, Engenheiro João ',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey[600])),
                              Text('👷‍♂️', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Text(
                            dateFormat.format(DateTime.now()),
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50)),
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
                        icon: Icon(Icons.notifications_outlined,
                            color: Color(0xFF2C3E50)),
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
                            child: Row(children: [
                              Icon(Icons.person_outline),
                              SizedBox(width: 8),
                              Text('Perfil')
                            ]),
                          ),
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text('Sair')
                            ]),
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
                          _buildKPICard(
                              'Obras em andamento',
                              '\$obrasAndamento obras',
                              Icons.construction,
                              Colors.blue),
                          _buildKPICard(
                              'Entregas esta semana',
                              '\$entregasSemana obras',
                              Icons.calendar_today,
                              Colors.green),
                          _buildKPICard(
                              'Total gasto este mês',
                              currencyFormat.format(totalGastoMes),
                              Icons.payments,
                              Colors.orange),
                          _buildKPICard(
                              'Gastos acima do orçamento',
                              '\$orcamentoEstourado obras',
                              Icons.warning,
                              Colors.red),
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
                          Text(
                            'Ações Rápidas',
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: acoesRapidas.length,
                            itemBuilder: (context, index) {
                              final acao = acoesRapidas[index];
                              return InkWell(
                                onTap: () =>
                                    Navigator.pushNamed(context, acao['rota']),
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
                              ).animate().fadeIn().scale(
                                  begin: Offset(0.8, 0.8), end: Offset(1, 1));
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              obra['name'] ?? 'Sem nome',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${obra['client_name'] ?? 'Cliente não informado'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${obra['expected_end_date'] ?? 'Data prevista não informada'}',
                                  style: const TextStyle( 
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '${obra['status'] ?? 'Indefinido'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.construction), label: 'Obras'),
          BottomNavigationBarItem(
              icon: Icon(Icons.description), label: 'Contratos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }

  Widget _buildCompactHeaderStat({required String title, required String value, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: Offset(0.9, 0.9), end: Offset(1, 1));
  }
}
