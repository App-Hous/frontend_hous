import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> obras = [
    {'nome': 'Residência A', 'endereco': 'Rua 1, Bairro X'},
    {'nome': 'Comercial B', 'endereco': 'Av. 2, Centro'},
  ];

  void _logout(BuildContext context) {
    // TODO: limpar SharedPreferences futuramente
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Obras em Andamento'),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            onSelected: (value) {
              if (value == 'perfil') {
                Navigator.pushNamed(context, '/perfil');
              } else if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'perfil', child: Text('Gerenciar Conta')),
              PopupMenuItem(value: 'logout', child: Text('Sair')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: obras.length,
        itemBuilder: (context, index) {
          final obra = obras[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.home_work, color: Colors.blue, size: 32),
              title: Text(
                obra['nome']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(obra['endereco']!),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(context, '/obra/detalhe', arguments: obra);
              },
            ),
          );
        },
      ),
      floatingActionButton: _buildExpandableFab(context),
    );
  }

  Widget _buildExpandableFab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _miniFab(
          context,
          icon: Icons.add_location_alt,
          label: 'Nova Obra',
          onPressed: () => Navigator.pushNamed(context, '/cadastro/obra'),
        ),
        SizedBox(height: 8),
        _miniFab(
          context,
          icon: Icons.person_add,
          label: 'Novo Cliente',
          onPressed: () => Navigator.pushNamed(context, '/cadastro/cliente'),
        ),
        SizedBox(height: 8),
        _miniFab(
          context,
          icon: Icons.build,
          label: 'Novo Serviço',
          onPressed: () => Navigator.pushNamed(context, '/cadastro/servico'),
        ),
        SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: () {},
          child: Icon(Icons.add),
          tooltip: 'Ações',
        ),
      ],
    );
  }

  Widget _miniFab(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(right: 8),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: TextStyle(fontSize: 14)),
        ),
        FloatingActionButton(
          heroTag: label,
          mini: true,
          onPressed: onPressed,
          child: Icon(icon),
        ),
      ],
    );
  }
}