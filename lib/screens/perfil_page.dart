import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final TextEditingController nomeController = TextEditingController(text: 'Usuário Exemplo');
  final TextEditingController emailController = TextEditingController(text: 'usuario@exemplo.com');
  final TextEditingController senhaController = TextEditingController();

  void _salvarPerfil() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados atualizados (simulado).')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciar Conta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            SizedBox(height: 24),
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome completo'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: senhaController,
              decoration: InputDecoration(labelText: 'Nova senha (opcional)'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _salvarPerfil,
              icon: Icon(Icons.save),
              label: Text('Salvar alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
