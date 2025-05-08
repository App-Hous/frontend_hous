import 'package:flutter/material.dart';
import '../services/cliente_service.dart';

class ObraDetalhePage extends StatefulWidget {
  const ObraDetalhePage({super.key});

  @override
  _ObraDetalhePageState createState() => _ObraDetalhePageState();
}

class _ObraDetalhePageState extends State<ObraDetalhePage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  String? clienteSelecionadoId;

  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> servicos = [];

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  void _carregarClientes() async {
    try {
      final lista = await ClienteService.getClientes();
      setState(() => clientes = lista);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar clientes: \$e')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> obra = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    nomeController.text = obra['nome'] ?? '';
    enderecoController.text = obra['endereco'] ?? '';
    clienteSelecionadoId = obra['cliente_id']?.toString();
    if (obra.containsKey('servicos')) {
      servicos = List<Map<String, dynamic>>.from(obra['servicos']);
    }
  }

  void _salvarAlteracoes() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alterações salvas (simulação).')),
    );
  }

  void _editarServico(int index) async {
    final tituloController = TextEditingController(text: servicos[index]['nome']);
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
          TextButton(
            onPressed: () {
              setState(() {
                servicos[index] = {
                  'nome': tituloController.text,
                  'descricao': descricaoController.text,
                };
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
              decoration: InputDecoration(labelText: 'Cliente'),
              value: clienteSelecionadoId,
              items: clientes.map((cliente) {
                return DropdownMenuItem(
                  value: cliente['id'].toString(),
                  child: Text(cliente['nome']),
                );
              }).toList(),
              onChanged: (value) => setState(() => clienteSelecionadoId = value),
            ),
            SizedBox(height: 24),
            Text('Serviços', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...servicos.asMap().entries.map((entry) {
              final index = entry.key;
              final servico = entry.value;
              return ListTile(
                title: Text(servico['nome'] ?? ''),
                subtitle: Text(servico['descricao'] ?? ''),
                trailing: Icon(Icons.edit),
                onTap: () => _editarServico(index),
              );
            }),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
