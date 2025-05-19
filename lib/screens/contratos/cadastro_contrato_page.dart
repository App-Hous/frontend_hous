import 'package:flutter/material.dart';
import '../../services/contract_service.dart';
import '../../services/cliente_service.dart';
import '../../services/servico_service.dart';
import '../../services/project_service.dart';

class CadastroContratoPage extends StatefulWidget {
  @override
  _CadastroContratoPageState createState() => _CadastroContratoPageState();
}

class _CadastroContratoPageState extends State<CadastroContratoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController notasController = TextEditingController();
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController tipoImovelController = TextEditingController();

  DateTime? dataAssinatura;
  DateTime? dataExpiracao;

  String? _tipoSelecionadoPt;
  String? _statusSelecionadoPt;
  int? _clienteSelecionado;
  int? _imovelSelecionado;

  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _imoveis = [];

  bool _isLoading = false;
  String? _error;
  bool _loadingDropdowns = true;

  final Map<String, String> tiposMap = {
    'Venda': 'sale',
    'Aluguel': 'rental',
    'Arrendamento': 'lease',
    'Outro': 'other',
  };
  final Map<String, String> statusMap = {
    'Ativo': 'active',
    'Pendente': 'pending',
    'Vencido': 'expired',
    'Cancelado': 'cancelled',
    'Concluído': 'completed',
  };

  @override
  void initState() {
    super.initState();
    _carregarDropdowns();
  }

  Future<void> _carregarDropdowns() async {
    setState(() => _loadingDropdowns = true);
    try {
      final clientes = await ClienteService.getClientes();
      final imoveis = await ServicoService.getServicos();
      setState(() {
        _clientes = clientes;
        _imoveis = imoveis;
        _loadingDropdowns = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar clientes ou imóveis: $e';
        _loadingDropdowns = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Contrato'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loadingDropdowns
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: numeroController,
                      decoration: const InputDecoration(
                          labelText: 'Número do Contrato'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o número' : null,
                    ),
                    TextFormField(
                      controller: tituloController,
                      decoration: const InputDecoration(
                          labelText: 'Título do Contrato'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o título' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _tipoSelecionadoPt,
                      items: tiposMap.keys
                          .map((tipoPt) => DropdownMenuItem(
                                value: tipoPt,
                                child: Text(tipoPt),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _tipoSelecionadoPt = v),
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Selecione o tipo' : null,
                    ),
                    TextFormField(
                      controller: descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    TextFormField(
                      controller: tipoImovelController,
                      decoration:
                          const InputDecoration(labelText: 'Tipo de Imóvel'),
                    ),
                    DropdownButtonFormField<int>(
                      value: _clienteSelecionado,
                      items: _clientes
                          .map<DropdownMenuItem<int>>(
                              (cliente) => DropdownMenuItem<int>(
                                    value: cliente['id'] as int,
                                    child: Text(cliente['name'] ??
                                        'Cliente ${cliente['id']}'),
                                  ))
                          .toList(),
                      onChanged: (v) => setState(() => _clienteSelecionado = v),
                      decoration: const InputDecoration(labelText: 'Cliente'),
                      validator: (v) =>
                          v == null ? 'Selecione o cliente' : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _imovelSelecionado,
                            items: _imoveis
                                .map<DropdownMenuItem<int>>(
                                    (imovel) => DropdownMenuItem<int>(
                                          value: imovel['id'] as int,
                                          child: Text(imovel['name'] ??
                                              'Imóvel ${imovel['id']}'),
                                        ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _imovelSelecionado = v),
                            decoration:
                                const InputDecoration(labelText: 'Imóvel'),
                            validator: (v) =>
                                v == null ? 'Selecione o imóvel' : null,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Cadastrar novo imóvel',
                          onPressed: _abrirCadastroRapidoImovel,
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: valorController,
                      decoration: const InputDecoration(
                          labelText: 'Valor do Contrato',
                          hintText: 'Ex: 1.500.000,00'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o valor' : null,
                      onChanged: (value) {
                        String newValue =
                            value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (newValue.isEmpty) newValue = '0';
                        double val = double.parse(newValue) / 100;
                        valorController.value = valorController.value.copyWith(
                          text: val.toStringAsFixed(2).replaceAll('.', ','),
                          selection: TextSelection.collapsed(
                              offset: val
                                  .toStringAsFixed(2)
                                  .replaceAll('.', ',')
                                  .length),
                        );
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _statusSelecionadoPt,
                      items: statusMap.keys
                          .map((statusPt) => DropdownMenuItem(
                                value: statusPt,
                                child: Text(statusPt),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _statusSelecionadoPt = v),
                      decoration: const InputDecoration(labelText: 'Status'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Selecione o status' : null,
                    ),
                    TextFormField(
                      controller: notasController,
                      decoration:
                          const InputDecoration(labelText: 'Observações'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(dataAssinatura == null
                              ? 'Data de Assinatura não selecionada'
                              : 'Assinatura: ${dataAssinatura!.toLocal().toString().split(' ')[0]}'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => dataAssinatura = picked);
                            }
                          },
                          child: const Text('Selecionar Assinatura'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(dataExpiracao == null
                              ? 'Data de Expiração não selecionada'
                              : 'Expiração: ${dataExpiracao!.toLocal().toString().split(' ')[0]}'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => dataExpiracao = picked);
                            }
                          },
                          child: const Text('Selecionar Expiração'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _salvarContrato,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Cadastrar Contrato'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _salvarContrato() async {
    if (!_formKey.currentState!.validate() ||
        dataAssinatura == null ||
        dataExpiracao == null) {
      setState(() => _error = 'Preencha todos os campos obrigatórios e datas.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ContractService.createContract(
        contractNumber: numeroController.text.trim(),
        title: tituloController.text.trim(),
        type: tiposMap[_tipoSelecionadoPt!]!,
        propertyType: tipoImovelController.text.trim(),
        description: descricaoController.text.trim(),
        clientId: _clienteSelecionado!,
        propertyId: _imovelSelecionado!,
        signingDate: dataAssinatura!,
        expirationDate: dataExpiracao!,
        contractValue: _parseValor(valorController.text),
        status: statusMap[_statusSelecionadoPt!]!,
        notes: notasController.text.trim(),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double _parseValor(String valor) {
    return double.tryParse(valor.replaceAll('.', '').replaceAll(',', '.')) ??
        0.0;
  }

  Future<void> _abrirCadastroRapidoImovel() async {
    final novoImovel = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CadastroRapidoImovelDialog(),
    );
    if (novoImovel != null) {
      await _carregarDropdowns();
      setState(() {
        _imovelSelecionado = novoImovel['id'];
      });
    }
  }
}

class CadastroRapidoImovelDialog extends StatefulWidget {
  @override
  State<CadastroRapidoImovelDialog> createState() =>
      _CadastroRapidoImovelDialogState();
}

class _CadastroRapidoImovelDialogState
    extends State<CadastroRapidoImovelDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController progressoController = TextEditingController();
  int? _obraSelecionada;
  List<Map<String, dynamic>> _obras = [];
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarObras();
  }

  Future<void> _carregarObras() async {
    try {
      final obras = await ProjectService.getProjects();
      setState(() => _obras = obras);
    } catch (e) {
      setState(() => _erro = 'Erro ao carregar obras: $e');
    }
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await ServicoService.criarServico(
        nomeController.text.trim(),
        descricaoController.text.trim(),
        int.tryParse(progressoController.text.trim()) ?? 0,
        _obraSelecionada!,
      );
      // Após cadastrar, buscar imóveis para pegar o novo
      final imoveis = await ServicoService.getServicos();
      final novo = imoveis.lastWhere(
        (i) => i['name'] == nomeController.text.trim(),
        orElse: () => <String, dynamic>{},
      );
      if (!mounted) return;
      Navigator.of(context).pop(novo);
    } catch (e) {
      setState(() => _erro = 'Erro ao cadastrar imóvel: $e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastro rápido de Imóvel'),
      content: _erro != null
          ? Text(_erro!, style: const TextStyle(color: Colors.red))
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeController,
                    decoration:
                        const InputDecoration(labelText: 'Nome do imóvel'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe o nome' : null,
                  ),
                  TextFormField(
                    controller: descricaoController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                  ),
                  TextFormField(
                    controller: progressoController,
                    decoration:
                        const InputDecoration(labelText: 'Progresso (%)'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe o progresso' : null,
                  ),
                  DropdownButtonFormField<int>(
                    value: _obraSelecionada,
                    items: _obras
                        .map<DropdownMenuItem<int>>((obra) =>
                            DropdownMenuItem<int>(
                              value: obra['id'] as int,
                              child: Text(obra['name'] ?? 'Obra ${obra['id']}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _obraSelecionada = v),
                    decoration: const InputDecoration(labelText: 'Obra'),
                    validator: (v) => v == null ? 'Selecione a obra' : null,
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _carregando ? null : _cadastrar,
          child: _carregando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Cadastrar'),
        ),
      ],
    );
  }
}
