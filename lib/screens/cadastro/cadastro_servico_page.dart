import 'package:flutter/material.dart';

class CadastroServicoPage extends StatefulWidget {
  const CadastroServicoPage({super.key});

  @override
  _CadastroServicoPageState createState() => _CadastroServicoPageState();
}

class _CadastroServicoPageState extends State<CadastroServicoPage> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  double progresso = 0.0;

  // Simulando lista de obras
  final List<Map<String, String>> obras = [
    {'id': '1', 'nome': 'Residência A'},
    {'id': '2', 'nome': 'Comercial B'},
  ];

  String? obraSelecionadaId;

  void _salvarServico() {
    String titulo = tituloController.text.trim();
    String descricao = descricaoController.text.trim();

    if (titulo.isNotEmpty && descricao.isNotEmpty && obraSelecionadaId != null) {
      // Futuramente enviar para API
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos e selecione a obra')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Novo Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(labelText: 'Título do Serviço'),
            ),
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Obra Vinculada'),
              value: obraSelecionadaId,
              items: obras.map((obra) {
                return DropdownMenuItem(
                  value: obra['id'],
                  child: Text(obra['nome']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  obraSelecionadaId = value;
                });
              },
            ),
            Slider(
              value: progresso,
              min: 0.0,
              max: 100.0,
              divisions: 20,
              label: '${progresso.round()}%',
              onChanged: (val) {
                setState(() {
                  progresso = val;
                });
              },
            ),
            Text('Progresso estimado: ${progresso.round()}%'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarServico,
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
