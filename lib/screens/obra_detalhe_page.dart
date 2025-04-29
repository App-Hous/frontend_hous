import 'package:flutter/material.dart';

class ObraDetalhePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> obra = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Obra')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(obra['nome'] ?? '-'),
            SizedBox(height: 16),
            Text('Endereço:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(obra['endereco'] ?? '-'),
            SizedBox(height: 16),
            Divider(),
            Text('Serviços', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: [
                  ListTile(title: Text('Fundação'), subtitle: Text('50% concluído')),
                  ListTile(title: Text('Alvenaria'), subtitle: Text('Em andamento')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
