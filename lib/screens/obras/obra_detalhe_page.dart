import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/project_service.dart';


class ObraDetalhePage extends StatefulWidget {
  const ObraDetalhePage({super.key});

  @override
  State<ObraDetalhePage> createState() => _ObraDetalhePageState();
}

class _ObraDetalhePageState extends State<ObraDetalhePage> {
  final _formKey = GlobalKey<FormState>();

  late Map<String, dynamic> obra;

  late TextEditingController nomeController;
  late TextEditingController descricaoController;
  late TextEditingController enderecoController;
  late TextEditingController cidadeController;
  late TextEditingController estadoController;
  late TextEditingController cepController;
  late TextEditingController areaController;
  late TextEditingController orcamentoController;
  late TextEditingController managerIdController;
  late TextEditingController companyIdController;

  DateTime? dataInicio;
  DateTime? dataFimPrevista;
  DateTime? dataFimReal;
  String statusSelecionado = 'planning';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    obra = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    nomeController = TextEditingController(text: obra['name']);
    descricaoController = TextEditingController(text: obra['description']);
    enderecoController = TextEditingController(text: obra['address']);
    cidadeController = TextEditingController(text: obra['city']);
    estadoController = TextEditingController(text: obra['state']);
    cepController = TextEditingController(text: obra['zip_code']);
    areaController = TextEditingController(text: obra['total_area'].toString());
    orcamentoController = TextEditingController(text: obra['budget'].toString());
    managerIdController = TextEditingController(text: obra['manager_id'].toString());
    companyIdController = TextEditingController(text: obra['company_id'].toString());

    dataInicio = DateTime.tryParse(obra['start_date']);
    dataFimPrevista = DateTime.tryParse(obra['expected_end_date']);
    dataFimReal = DateTime.tryParse(obra['actual_end_date']);
    statusSelecionado = obra['status'] ?? 'planning';
  }

  Future<void> _selecionarData(BuildContext context, DateTime? initial, Function(DateTime) onConfirmar) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) onConfirmar(data);
  }

  void _salvarAlteracoes() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    await ProjectService.updateProject(
      id: obra['id'],
      nome: nomeController.text.trim(),
      descricao: descricaoController.text.trim(),
      endereco: enderecoController.text.trim(),
      cidade: cidadeController.text.trim(),
      estado: estadoController.text.trim(),
      cep: cepController.text.trim(),
      areaTotal: double.tryParse(areaController.text) ?? 0,
      orcamento: double.tryParse(orcamentoController.text) ?? 0,
      dataInicio: dataInicio!,
      dataFimPrevista: dataFimPrevista!,
      dataFimReal: dataFimReal!,
      status: statusSelecionado,
      companyId: int.tryParse(companyIdController.text) ?? 0,
      managerId: int.tryParse(managerIdController.text) ?? 0,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Obra atualizada com sucesso!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao atualizar obra: $e')),
    );
  }
}


  void _excluirObra() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta obra?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await ProjectService.deleteProject(obra['id']);
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/obras', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Obra excluída com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir obra: \$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Obra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
              TextFormField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descrição')),
              TextFormField(controller: enderecoController, decoration: const InputDecoration(labelText: 'Endereço')),
              TextFormField(controller: cidadeController, decoration: const InputDecoration(labelText: 'Cidade')),
              TextFormField(controller: estadoController, decoration: const InputDecoration(labelText: 'Estado')),
              TextFormField(controller: cepController, decoration: const InputDecoration(labelText: 'CEP')),
              TextFormField(controller: areaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Área Total')),
              TextFormField(controller: orcamentoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Orçamento')),
              TextFormField(controller: companyIdController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ID da Empresa')),
              TextFormField(controller: managerIdController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ID do Gerente')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: statusSelecionado,
                items: [
                  DropdownMenuItem(value: 'planning', child: Text('Planejamento')),
                  DropdownMenuItem(value: 'in_progress', child: Text('Em andamento')),
                  DropdownMenuItem(value: 'completed', child: Text('Concluído')),
                ],
                onChanged: (value) => setState(() => statusSelecionado = value!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text('Data de Início: ${DateFormat('dd/MM/yyyy').format(dataInicio!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selecionarData(context, dataInicio, (data) => setState(() => dataInicio = data)),
              ),
              ListTile(
                title: Text('Previsão de Término: ${DateFormat('dd/MM/yyyy').format(dataFimPrevista!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selecionarData(context, dataFimPrevista, (data) => setState(() => dataFimPrevista = data)),
              ),
              ListTile(
                title: Text('Término Real: ${DateFormat('dd/MM/yyyy').format(dataFimReal!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selecionarData(context, dataFimReal, (data) => setState(() => dataFimReal = data)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _salvarAlteracoes,
                      child: const Text('Salvar Alterações'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                    onPressed: _excluirObra,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}