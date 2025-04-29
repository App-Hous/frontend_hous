import 'package:flutter/material.dart';

class CadastroObraPage extends StatefulWidget {
  @override
  _CadastroObraPageState createState() => _CadastroObraPageState();
}

class _CadastroObraPageState extends State<CadastroObraPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  bool emAndamento = true;

  void _salvarObra() {
    String nome = nomeController.text.trim();
    String endereco = enderecoController.text.trim();

    if (nome.isNotEmpty && endereco.isNotEmpty) {
      // Aqui futuramente enviaremos os dados para a API
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Obra')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome da Obra'),
            ),
            TextField(
              controller: enderecoController,
              decoration: InputDecoration(labelText: 'Endereço'),
            ),
            SwitchListTile(
              title: Text('Em andamento?'),
              value: emAndamento,
              onChanged: (val) {
                setState(() {
                  emAndamento = val;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarObra,
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
