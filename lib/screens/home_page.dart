import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> obras = [
    {
      'nome': 'Residência A',
      'endereco': 'Rua 1, Bairro X',
      'cliente': 'Cliente A',
      'status': 'Em Andamento',
      'progresso': 65,
      'valor': 150000.0,
      'dataInicio': DateTime(2024, 1, 15),
      'dataPrevista': DateTime(2024, 6, 15),
      'tipo': 'Residencial',
      'orcamento': 200000.0,
      'gastoAtual': 180000.0,
      'prioridade': 'Alta',
    },
    {
      'nome': 'Comercial B',
      'endereco': 'Av. 2, Centro',
      'cliente': 'Cliente B',
      'status': 'Planejamento',
      'progresso': 15,
      'valor': 250000.0,
      'dataInicio': DateTime(2024, 2, 1),
      'dataPrevista': DateTime(2024, 8, 1),
      'tipo': 'Comercial',
      'orcamento': 300000.0,
      'gastoAtual': 280000.0,
      'prioridade': 'Média',
    },
    {
      'nome': 'Reforma C',
      'endereco': 'Rua 3, Jardim',
      'cliente': 'Cliente C',
      'status': 'Concluído',
      'progresso': 100,
      'valor': 80000.0,
      'dataInicio': DateTime(2023, 12, 1),
      'dataPrevista': DateTime(2024, 3, 1),
      'tipo': 'Reforma',
      'orcamento': 90000.0,
      'gastoAtual': 85000.0,
      'prioridade': 'Baixa',
    },
  ];

  final List<Map<String, dynamic>> alertas = [
    {
      'tipo': 'orcamento',
      'mensagem': '3 obras com orçamento ultrapassado',
      'icone': Icons.warning_amber_rounded,
      'cor': Colors.orange,
    },
    {
      'tipo': 'atraso',
      'mensagem': '1 obra atrasada!',
      'icone': Icons.error_outline,
      'cor': Colors.red,
    },
  ];

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

  int _selectedIndex = 0;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
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
                      Text(
                        'Olá, Engenheiro João ',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '👷‍♂️',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Text(
                    dateFormat.format(DateTime.now()),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
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
                icon: Stack(
                  children: [
                    Icon(Icons.notifications_outlined,
                        color: Color(0xFF2C3E50)),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
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
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Text('Perfil'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Sair'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (alertas.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade50, Colors.orange.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Alertas Importantes',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...alertas.map((alerta) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(alerta['icone'], color: alerta['cor']),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  alerta['mensagem'],
                                  style: GoogleFonts.poppins(
                                    color: alerta['cor'],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
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
                    '3 obras',
                    Icons.construction,
                    Colors.blue,
                  ),
                  _buildKPICard(
                    'Entregas esta semana',
                    '2 obras',
                    Icons.calendar_today,
                    Colors.green,
                  ),
                  _buildKPICard(
                    'Total gasto este mês',
                    currencyFormat.format(215000),
                    Icons.payments,
                    Colors.orange,
                  ),
                  _buildKPICard(
                    'Gastos acima do orçamento',
                    '1 obra',
                    Icons.warning,
                    Colors.red,
                  ),
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
                      ).animate().fadeIn().scale(
                            begin: Offset(0.8, 0.8),
                            end: Offset(1, 1),
                          );
                    },
                  ),
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
                  Row(
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
                      PopupMenuButton<String>(
                        icon: Icon(Icons.sort, color: Color(0xFF2C3E50)),
                        onSelected: (value) {
                          // TODO: Implementar ordenação
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'urgentes',
                            child: Text('Mais Urgentes'),
                          ),
                          PopupMenuItem(
                            value: 'orcamento',
                            child: Text('Orçamento Estourado'),
                          ),
                          PopupMenuItem(
                            value: 'entrega',
                            child: Text('Próxima Entrega'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final obra = obras[index];
                final bool orcamentoEstourado =
                    obra['gastoAtual'] > obra['orcamento'];
                return Container(
                  margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Stack(
                          children: [
                            Icon(
                              _getIconForType(obra['tipo']),
                              color: Color(0xFF2C3E50),
                            ),
                            if (orcamentoEstourado)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Icon(
                                  Icons.warning,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                obra['nome'],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getColorForStatus(obra['status'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            obra['status'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _getColorForStatus(obra['status']),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: obra['progresso'] / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForStatus(obra['status']),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${obra['progresso']}% Concluído',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (orcamentoEstourado)
                              Text(
                                'Orçamento: ${currencyFormat.format(obra['gastoAtual'])} / ${currencyFormat.format(obra['orcamento'])}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/obras/lista');
                    },
                  ),
                ).animate().fadeIn().slideX(begin: 0.2, end: 0);
              },
              childCount: obras.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/obras/nova');
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF2C3E50),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
            icon: Icon(Icons.construction),
            label: 'Obras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Contratos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 110,
        maxWidth: 120,
      ),
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
                    title
                        .replaceAll(
                            'Total gasto este mês', 'Total gasto\neste mês')
                        .replaceAll('Obras em andamento', 'Obras em\nandamento')
                        .replaceAll(
                            'Entregas esta semana', 'Entregas\nesta semana')
                        .replaceAll('Gastos acima do orçamento',
                            'Gastos acima\ndo orçamento'),
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
      ).animate().fadeIn().scale(
            begin: Offset(0.8, 0.8),
            end: Offset(1, 1),
          ),
    );
  }

  IconData _getIconForType(String tipo) {
    switch (tipo) {
      case 'Residencial':
        return Icons.home;
      case 'Comercial':
        return Icons.business;
      case 'Reforma':
        return Icons.construction;
      default:
        return Icons.construction;
    }
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Em Andamento':
        return Colors.blue;
      case 'Planejamento':
        return Colors.orange;
      case 'Concluído':
        return Colors.green;
      case 'Vencido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
