import 'package:flutter/material.dart';

class CadastroObraPage extends StatefulWidget {
  @override
  _CadastroObraPageState createState() => _CadastroObraPageState();
}

class _CadastroObraPageState extends State<CadastroObraPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  bool emAndamento = true;

  // Simulando lista de clientes
  final List<Map<String, String>> clientes = [
    {'id': '1', 'nome': 'Cliente A'},
    {'id': '2', 'nome': 'Cliente B'},
    {'id': '3', 'nome': 'Cliente C'},
  ];

  String? clienteSelecionadoId;

  void _salvarObra() {
    String nome = nomeController.text.trim();
    String endereco = enderecoController.text.trim();

    if (nome.isNotEmpty && endereco.isNotEmpty && clienteSelecionadoId != null) {
      // Futuramente enviar para API
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos e selecione o cliente')),
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
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Cliente Responsável'),
              value: clienteSelecionadoId,
              items: clientes.map((cliente) {
                return DropdownMenuItem(
                  value: cliente['id'],
                  child: Text(cliente['nome']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  clienteSelecionadoId = value;
                });
              },
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
