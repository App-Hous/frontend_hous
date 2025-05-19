import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/contract_service.dart';

class ContractFormPage extends StatefulWidget {
  final Map<String, dynamic>? contract;

  const ContractFormPage({super.key, this.contract});

  @override
  State<ContractFormPage> createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _tipoController = TextEditingController();
  final _clienteIdController = TextEditingController();
  final _propriedadeIdController = TextEditingController();
  final _valorController = TextEditingController();
  final _statusController = TextEditingController();
  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.contract != null) {
      _numeroController.text = widget.contract!['contract_number'] ?? '';
      _tipoController.text = widget.contract!['type'] ?? '';
      _clienteIdController.text =
          widget.contract!['client_id']?.toString() ?? '';
      _propriedadeIdController.text =
          widget.contract!['property_id']?.toString() ?? '';
      _valorController.text =
          widget.contract!['contract_value']?.toString() ?? '';
      _statusController.text = widget.contract!['status'] ?? '';
      _dataInicio = DateTime.parse(widget.contract!['signing_date']);
      _dataFim = DateTime.parse(widget.contract!['expiration_date']);
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _tipoController.dispose();
    _clienteIdController.dispose();
    _propriedadeIdController.dispose();
    _valorController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _dataInicio ?? DateTime.now()
          : _dataFim ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  Future<void> _saveContract() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataInicio == null || _dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione as datas de início e fim'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.contract == null) {
        await ContractService.createContract(
          contractNumber: _numeroController.text,
          title: _numeroController.text,
          type: _tipoController.text,
          propertyType: "other",
          description: "Contrato criado via aplicativo",
          clientId: int.parse(_clienteIdController.text),
          propertyId: int.parse(_propriedadeIdController.text),
          signingDate: _dataInicio!,
          expirationDate: _dataFim!,
          contractValue: double.parse(_valorController.text),
          status: _statusController.text,
          notes: "",
        );
      } else {
        await ContractService.updateContract(
          id: widget.contract!['id'],
          numero: _numeroController.text,
          tipo: _tipoController.text,
          clienteId: int.parse(_clienteIdController.text),
          propriedadeId: int.parse(_propriedadeIdController.text),
          dataInicio: _dataInicio!,
          dataFim: _dataFim!,
          valor: double.parse(_valorController.text),
          status: _statusController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar contrato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.contract == null ? 'Novo Contrato' : 'Editar Contrato'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Número do Contrato',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o número do contrato';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tipoController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o tipo do contrato';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clienteIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID do Cliente',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o ID do cliente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _propriedadeIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID da Propriedade',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o ID da propriedade';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o valor do contrato';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _statusController,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o status do contrato';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Data de Início'),
                      subtitle: Text(_dataInicio?.toString().split(' ')[0] ??
                          'Não selecionada'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Data de Fim'),
                      subtitle: Text(_dataFim?.toString().split(' ')[0] ??
                          'Não selecionada'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveContract,
                      child: Text(widget.contract == null
                          ? 'Criar Contrato'
                          : 'Salvar Alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
