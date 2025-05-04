import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> obras = [
    {
      'nome': 'Residência A',
      'endereco': 'Rua 1, Bairro X',
      'cliente': 'Cliente A',
      'status': 'Em Andamento',
      'progresso': '65%',
    },
    {
      'nome': 'Comercial B',
      'endereco': 'Av. 2, Centro',
      'cliente': 'Cliente B',
      'status': 'Planejamento',
      'progresso': '15%',
    },
  ];

  int _selectedIndex = 0;
  bool mostrarBotoes = false;

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo, Engenheiro',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Obras em Andamento',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar busca
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificações
            },
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
                _logout(context);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'perfil',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: Color(0xFF2C3E50)),
                        SizedBox(width: 8),
                        Text('Gerenciar Conta'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Color(0xFFE74C3C)),
                        SizedBox(width: 8),
                        Text('Sair'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                _buildStatCard(
                  icon: Icons.construction,
                  title: 'Obras Ativas',
                  value: obras.length.toString(),
                ),
                SizedBox(width: 16),
                _buildStatCard(
                  icon: Icons.people_outline,
                  title: 'Clientes',
                  value: '12',
                ),
                SizedBox(width: 16),
                _buildStatCard(
                  icon: Icons.calendar_today,
                  title: 'Próximos Eventos',
                  value: '3',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suas Obras',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton.icon(
                  onPressed:
                      () => Navigator.pushNamed(context, '/cadastro/obra'),
                  icon: Icon(Icons.add),
                  label: Text('Nova Obra'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: obras.length,
              itemBuilder: (context, index) {
                final obra = obras[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/obra/detalhe',
                        arguments: obra,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2C3E50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.home_work,
                                  color: Color(0xFF2C3E50),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      obra['nome']!,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      obra['endereco']!,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      obra['status'] == 'Em Andamento'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  obra['status']!,
                                  style: TextStyle(
                                    color:
                                        obra['status'] == 'Em Andamento'
                                            ? Colors.green
                                            : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Progresso',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value:
                                          double.parse(
                                            obra['progresso']!.replaceAll(
                                              '%',
                                              '',
                                            ),
                                          ) /
                                          100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                obra['progresso']!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Cronograma',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Documentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Color(0xFF2C3E50), size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
