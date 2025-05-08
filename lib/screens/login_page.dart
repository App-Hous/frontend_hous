import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool _carregando = false;

  void _login() async {
    String email = emailController.text.trim();
    String senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() => _carregando = true);

    final sucesso = await AuthService.login(email, senha);

    setState(() => _carregando = false);

    if (sucesso) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email ou senha inválidos')),
      );
    }
  }

  void _irParaCadastro() {
    Navigator.pushNamed(context, '/cadastro/usuario');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(Icons.account_circle, size: 100, color: Colors.blue),
                SizedBox(height: 24),
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
                TextButton(
                  onPressed: _irParaCadastro,
                  child: Text(
                    'Não possui cadastro? Cadastre-se aqui',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                SizedBox(height: 16),
                _carregando
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: Text('Entrar'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
