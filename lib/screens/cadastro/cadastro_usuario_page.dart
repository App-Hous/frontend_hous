import 'package:flutter/material.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  _CadastroUsuarioPageState createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

  void _cadastrar() {
    String nome = nomeController.text.trim();
    String email = emailController.text.trim();
    String senha = senhaController.text.trim();
    String confirmarSenha = confirmarSenhaController.text.trim();

    if (nome.isNotEmpty && email.isNotEmpty && senha.isNotEmpty && senha == confirmarSenha) {
      Navigator.pop(context); // voltar para login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro realizado com sucesso (simulado)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verifique os campos preenchidos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome completo'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: senhaController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmarSenhaController,
                decoration: InputDecoration(labelText: 'Confirmar Senha'),
                obscureText: true,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _cadastrar,
                icon: Icon(Icons.person_add),
                label: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
