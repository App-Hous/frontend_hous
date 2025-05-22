import 'package:flutter/material.dart';
import '../../services/contract_service.dart';

class ContractSearchPage extends StatefulWidget {
  const ContractSearchPage({super.key});

  @override
  State<ContractSearchPage> createState() => _ContractSearchPageState();
}

class _ContractSearchPageState extends State<ContractSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minValueController = TextEditingController();
  final TextEditingController _maxValueController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  String? _selectedStatus;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  final List<String> _typeOptions = [
    'venda',
    'aluguel',
    'prestacao_servicos',
  ];

  final List<String> _statusOptions = [
    'active',
    'pending',
    'completed',
    'cancelled',
    'expired',
  ];

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await ContractService.getContracts(
        search: _searchController.text,
        status: _selectedStatus,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
      );

      // Filtrar por valor se especificado
      if (_minValueController.text.isNotEmpty ||
          _maxValueController.text.isNotEmpty) {
        final minValue = double.tryParse(_minValueController.text) ?? 0;
        final maxValue =
            double.tryParse(_maxValueController.text) ?? double.infinity;

        results.removeWhere((contract) {
          final value = (contract['contract_value'] ?? 0.0) as double;
          return value < minValue || value > maxValue;
        });
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca Avançada'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Palavras-chave',
                hintText: 'Número, título, descrição...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Valor mínimo',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Valor máximo',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate == null
                        ? 'Data inicial'
                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate == null
                        ? 'Data final'
                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo de contrato',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Todos os tipos'),
                ),
                ..._typeOptions.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Todos os status'),
                ),
                ..._statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _performSearch,
              icon: const Icon(Icons.search),
              label: const Text('BUSCAR'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      'Erro ao buscar contratos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ],
                ),
              )
            else if (_searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultados encontrados: ${_searchResults.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ..._searchResults.map((contract) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title:
                              Text(contract['contract_number'] ?? 'Sem número'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Tipo: ${contract['type'] ?? 'Não especificado'}'),
                              Text(
                                  'Status: ${contract['status'] ?? 'Não especificado'}'),
                              Text(
                                'Valor: R\$ ${(contract['contract_value'] ?? 0.0).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/contratos/detalhes',
                              arguments: contract['id'],
                            );
                          },
                        ),
                      )),
                ],
              )
            else if (_searchController.text.isNotEmpty ||
                _minValueController.text.isNotEmpty ||
                _maxValueController.text.isNotEmpty ||
                _startDate != null ||
                _endDate != null ||
                _selectedType != null ||
                _selectedStatus != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum contrato encontrado',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
