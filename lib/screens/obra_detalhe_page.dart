import 'package:flutter/material.dart';

class ObraDetalhePage extends StatefulWidget {
  const ObraDetalhePage({super.key});

  @override
  _ObraDetalhePageState createState() => _ObraDetalhePageState();
}

class _ObraDetalhePageState extends State<ObraDetalhePage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  String? clienteSelecionadoId;

  List<Map<String, String>> clientes = [
    {'id': '1', 'nome': 'Cliente A'},
    {'id': '2', 'nome': 'Cliente B'},
  ];

  List<Map<String, String>> servicos = [
    {'titulo': 'Fundação', 'descricao': '50% concluído'},
    {'titulo': 'Alvenaria', 'descricao': 'Em andamento'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, String> obra = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    nomeController.text = obra['nome'] ?? '';
    enderecoController.text = obra['endereco'] ?? '';
    clienteSelecionadoId = '1'; // Simulação inicial
  }

  void _salvarAlteracoes() {
    // Aqui você enviaria as alterações para a API futuramente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alterações salvas (simulação).')),
    );
  }

  void _editarServico(int index) async {
    final tituloController = TextEditingController(text: servicos[index]['titulo']);
    final descricaoController = TextEditingController(text: servicos[index]['descricao']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Serviço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tituloController, decoration: InputDecoration(labelText: 'Título')),
            TextField(controller: descricaoController, decoration: InputDecoration(labelText: 'Descrição')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                servicos[index]['titulo'] = tituloController.text;
                servicos[index]['descricao'] = descricaoController.text;
              });
              Navigator.pop(context);
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Obra')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              value: clienteSelecionadoId,
              decoration: InputDecoration(labelText: 'Cliente Responsável'),
              items: clientes.map((c) => DropdownMenuItem(
                value: c['id'],
                child: Text(c['nome']!),
              )).toList(),
              onChanged: (val) => setState(() => clienteSelecionadoId = val),
            ),
            SizedBox(height: 24),
            Text('Serviços', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: servicos.length,
                itemBuilder: (context, index) {
                  final servico = servicos[index];
                  return ListTile(
                    title: Text(servico['titulo']!),
                    subtitle: Text(servico['descricao']!),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editarServico(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _salvarAlteracoes,
              icon: Icon(Icons.save),
              label: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
