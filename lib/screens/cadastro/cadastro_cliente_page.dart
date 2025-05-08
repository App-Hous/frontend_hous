import 'package:flutter/material.dart';
import '../../services/cliente_service.dart';

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({super.key});

  @override
  _CadastroClientePageState createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool carregando = false;

  void _salvarCliente() async {
    String nome = nomeController.text.trim();
    String telefone = telefoneController.text.trim();
    String email = emailController.text.trim();

    if (nome.isNotEmpty && telefone.isNotEmpty && email.isNotEmpty) {
      setState(() => carregando = true);
      try {
        await ClienteService.criarCliente(nome, telefone, email);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente criado com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar cliente: \$e')),
        );
      } finally {
        setState(() => carregando = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Novo Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome completo'),
            ),
            TextField(
              controller: telefoneController,
              decoration: InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            carregando
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _salvarCliente,
                    child: Text('Salvar'),
                  ),
          ],
        ),
      ),
    );
  }
}
