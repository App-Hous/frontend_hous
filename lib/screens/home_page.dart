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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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
      'titulo': 'Buscar Contratos',
      'descricao': 'Pesquise seus contratos',
      'icone': Icons.search,
      'rota': '/contratos/lista',
      'cor': Color(0xFF9B59B6),
    },
    {
      'titulo': 'Relatórios',
      'icone': Icons.analytics_outlined,
      'rota': '/dashboard',
      'cor': Color(0xFFE67E22),
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
      final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
      final fimSemana = inicioSemana.add(Duration(days: 6));
      final inicioMes = DateTime(hoje.year, hoje.month, 1);
      final fimMes = DateTime(hoje.year, hoje.month + 1, 0);

      int andamento = 0;
      int entregas = 0;
      int estourados = 0;
      double totalGastoMesAtual = 0;

      for (var projeto in data) {
        final status = projeto['status'] ?? '';
        final gastoAtual = (projeto['current_expenses'] ?? 0).toDouble();
        final orcamento = (projeto['budget'] ?? 0).toDouble();
        
        // Converte as datas do projeto
        final dataPrevista = DateTime.tryParse(projeto['expected_end_date'] ?? '') ?? DateTime(2100);
        final dataInicio = DateTime.tryParse(projeto['start_date'] ?? '');
        
        // Calcula obras em andamento
        if (status == 'in_progress') {
          andamento++;
        }
        
        // Calcula entregas da semana
        if (dataPrevista.isAfter(inicioSemana) && 
            dataPrevista.isBefore(fimSemana) && 
            status != 'completed') {
          entregas++;
        }
        
        // Calcula orçamentos estourados
        if (gastoAtual > orcamento && status != 'completed') {
          estourados++;
        }
        
        // Calcula gastos do mês atual
        if (dataInicio != null && 
            dataInicio.isAfter(inicioMes) && 
            dataInicio.isBefore(fimMes)) {
          totalGastoMesAtual += gastoAtual;
        }
      }

      if (mounted) {
        setState(() {
          projetos = data;
          obrasAndamento = andamento;
          entregasSemana = entregas;
          orcamentoEstourado = estourados;
          totalGastoMes = totalGastoMesAtual;
          carregando = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar projetos e estatísticas: $e');
      if (mounted) {
        setState(() {
          carregando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados dos projetos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        final valorGasto = (gasto['amount'] ?? 0).toDouble();
        
        if (dataGasto != null && 
            dataGasto.isAfter(inicioMes) && 
            dataGasto.isBefore(fimMes)) {
          totalMes += valorGasto;
        }
      }
      
      if (mounted) {
        setState(() {
          totalGastoMes = totalMes;
        });
      }
    } catch (e) {
      print('Erro ao carregar gastos do mês: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar gastos do mês: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                  Text('Carregando suas informações...',
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
                  // Header compacto e moderno
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF34495E),
                            Color(0xFF2C3E50),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$saudacao, ${nomeUsuario.split(' ').first}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          cargoUsuario ?? 'Engenheiro',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/perfil');
                                    },
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white24,
                                      child: Text(
                                        userInitials,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        dataFormatada,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactHeaderStat(
                                      title: 'Obras Ativas', 
                                      value: '$obrasAndamento',
                                      icon: Icons.construction,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildCompactHeaderStat(
                                      title: 'Entregas Semana', 
                                      value: '$entregasSemana',
                                      icon: Icons.assignment_turned_in,
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

                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildKPICard('Obras em andamento', '$obrasAndamento obras', Icons.construction, Colors.blue),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildKPICard('Entregas esta semana', '$entregasSemana obras', Icons.calendar_today, Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildKPICard('Total gasto este mês', currencyFormat.format(totalGastoMes), Icons.payments, Colors.orange),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildKPICard('Gastos acima do orçamento', '$orcamentoEstourado obras', Icons.warning, Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                          SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: acoesRapidas.length,
                              separatorBuilder: (context, index) => SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final acao = acoesRapidas[index];
                                return InkWell(
                                  onTap: () => Navigator.pushNamed(context, acao['rota']),
                                  child: Container(
                                    width: 110,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (acao['cor'] as Color? ?? Color(0xFF2C3E50)).withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: (acao['cor'] as Color? ?? Color(0xFF2C3E50)).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            acao['icone'],
                                            size: 28,
                                            color: acao['cor'] as Color? ?? Color(0xFF2C3E50),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            acao['titulo'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF2C3E50),
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn().scale(begin: Offset(0.8, 0.8), end: Offset(1, 1));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Obras Recentes',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/obras/lista'),
                            child: Text(
                              'Ver todas',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFF3498DB),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (projetos.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'Nenhuma obra encontrada',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        }
                        
                        final obra = projetos[index];
                        final status = obra['status'] ?? 'unknown';

                        Color corStatus(String status) {
                          switch (status) {
                            case 'planning':
                              return Colors.orange;
                            case 'in_progress':
                              return Colors.blue;
                            case 'completed':
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
                            case 'completed':
                              return 'Concluído';
                            default:
                              return 'Indefinido';
                          }
                        }

                        final orcamento = (obra['budget'] ?? 0).toDouble();
                        final gastoAtual = (obra['current_expenses'] ?? 0).toDouble();
                        final percentGasto = orcamento > 0 ? (gastoAtual / orcamento * 100).clamp(0, 100) : 0;

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              padding: const EdgeInsets.all(16),
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
                        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
                      },
                      childCount: projetos.isEmpty ? 1 : projetos.length.clamp(0, 4),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 80),
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
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.construction), label: 'Obras'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Contratos'),
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
