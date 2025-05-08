import 'package:flutter/material.dart';
import '../../services/project_service.dart';

class CadastroObraPage extends StatefulWidget {
  const CadastroObraPage({Key? key}) : super(key: key);

  @override
  State<CadastroObraPage> createState() => _CadastroObraPageState();
}

class _CadastroObraPageState extends State<CadastroObraPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController areaTotalController = TextEditingController();
  final TextEditingController orcamentoController = TextEditingController();
  final TextEditingController companyIdController = TextEditingController();
  final TextEditingController managerIdController = TextEditingController();

  DateTime? dataInicio;
  DateTime? dataFimPrevista;
  DateTime? dataFimReal;
  String statusSelecionado = 'planning';

  bool carregando = false;

  Future<void> _selecionarData(BuildContext context, DateTime? initial, Function(DateTime) onConfirmar) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) onConfirmar(data);
  }

  void _cadastrar() async {
    final nome = nomeController.text.trim();
    final descricao = descricaoController.text.trim();
    final endereco = enderecoController.text.trim();
    final cidade = cidadeController.text.trim();
    final estado = estadoController.text.trim();
    final cep = cepController.text.trim();
    final areaTotal = double.tryParse(areaTotalController.text.trim()) ?? 0;
    final orcamento = double.tryParse(orcamentoController.text.trim()) ?? 0;
    final companyId = int.tryParse(companyIdController.text.trim()) ?? 0;
    final managerId = int.tryParse(managerIdController.text.trim()) ?? 0;

    if ([nome, endereco, cidade, estado, cep].any((e) => e.isEmpty) ||
        dataInicio == null || dataFimPrevista == null || dataFimReal == null ||
        areaTotal <= 0 || orcamento <= 0 || companyId == 0 || managerId == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      await ProjectService.createProject(
        nome: nome,
        descricao: descricao,
        endereco: endereco,
        cidade: cidade,
        estado: estado,
        cep: cep,
        areaTotal: areaTotal,
        orcamento: orcamento,
        dataInicio: dataInicio!,
        dataFimPrevista: dataFimPrevista!,
        dataFimReal: dataFimReal!,
        status: statusSelecionado,
        companyId: companyId,
        managerId: managerId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projeto cadastrado com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar projeto: \$e')),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Obra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descrição')),
            TextField(controller: enderecoController, decoration: const InputDecoration(labelText: 'Endereço')),
            TextField(controller: cidadeController, decoration: const InputDecoration(labelText: 'Cidade')),
            TextField(controller: estadoController, decoration: const InputDecoration(labelText: 'Estado')),
            TextField(controller: cepController, decoration: const InputDecoration(labelText: 'CEP')),
            TextField(controller: areaTotalController, decoration: const InputDecoration(labelText: 'Área Total'), keyboardType: TextInputType.number),
            TextField(controller: orcamentoController, decoration: const InputDecoration(labelText: 'Orçamento'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: Text(dataInicio == null ? 'Data de início não selecionada' : 'Início: ${dataInicio!.toLocal().toString().split(' ')[0]}'),
              ),
              TextButton(
                onPressed: () => _selecionarData(context, dataInicio, (data) => setState(() => dataInicio = data)),
                child: const Text('Selecionar Início'),
              ),
            ]),
            Row(children: [
              Expanded(
                child: Text(dataFimPrevista == null ? 'Previsão de término não selecionada' : 'Prevista: ${dataFimPrevista!.toLocal().toString().split(' ')[0]}'),
              ),
              TextButton(
                onPressed: () => _selecionarData(context, dataFimPrevista, (data) => setState(() => dataFimPrevista = data)),
                child: const Text('Selecionar Previsão'),
              ),
            ]),
            Row(children: [
              Expanded(
                child: Text(dataFimReal == null ? 'Término real não selecionado' : 'Real: ${dataFimReal!.toLocal().toString().split(' ')[0]}'),
              ),
              TextButton(
                onPressed: () => _selecionarData(context, dataFimReal, (data) => setState(() => dataFimReal = data)),
                child: const Text('Selecionar Término'),
              ),
            ]),
            DropdownButtonFormField<String>(
              value: statusSelecionado,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['planning', 'in_progress', 'completed']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => statusSelecionado = val ?? 'planning'),
            ),
            TextField(controller: companyIdController, decoration: const InputDecoration(labelText: 'ID da Empresa'), keyboardType: TextInputType.number),
            TextField(controller: managerIdController, decoration: const InputDecoration(labelText: 'ID do Gerente'), keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            carregando
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _cadastrar,
                    icon: const Icon(Icons.check),
                    label: const Text('Cadastrar Projeto'),
                  ),
          ],
        ),
      ),
    );
  }
}
