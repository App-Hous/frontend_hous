import 'package:flutter/material.dart';
import '../../services/servico_service.dart';

class CadastroServicoPage extends StatefulWidget {
  const CadastroServicoPage({Key? key}) : super(key: key);

  @override
  State<CadastroServicoPage> createState() => _CadastroServicoPageState();
}

class _CadastroServicoPageState extends State<CadastroServicoPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController progressoController = TextEditingController();
  final TextEditingController obraIdController = TextEditingController();

  bool carregando = false;

  void _cadastrar() async {
    final nome = nomeController.text.trim();
    final descricao = descricaoController.text.trim();
    final progresso = int.tryParse(progressoController.text.trim()) ?? 0;
    final obraId = int.tryParse(obraIdController.text.trim()) ?? 0;

    if (nome.isEmpty || descricao.isEmpty || progresso == 0 || obraId == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      await ServicoService.criarServico(nome, descricao, progresso, obraId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço cadastrado com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar serviço: $e')),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome do serviço'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: progressoController,
              decoration: const InputDecoration(labelText: 'Progresso (%)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: obraIdController,
              decoration: const InputDecoration(labelText: 'ID da Obra'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            carregando
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _cadastrar,
                    icon: const Icon(Icons.check),
                    label: const Text('Cadastrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
