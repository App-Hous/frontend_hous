import 'package:flutter/material.dart';
import '../../services/contract_service.dart';
import '../../components/contract_status_badge.dart';

class ContractListPage extends StatefulWidget {
  const ContractListPage({super.key});

  @override
  State<ContractListPage> createState() => _ContractListPageState();
}

class _ContractListPageState extends State<ContractListPage> {
  List<Map<String, dynamic>> _contracts = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'todos';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  String _searchQuery = '';

  final List<String> _statusOptions = [
    'todos',
    'active',
    'pending',
    'completed',
    'cancelled',
    'expired',
  ];

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContracts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final contracts = await ContractService.getContracts(
        search: _searchQuery,
        status: _selectedStatus == 'todos' ? null : _selectedStatus,
      );

      setState(() {
        _contracts = contracts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contratos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        actions: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width:
                _isSearchExpanded ? MediaQuery.of(context).size.width * 0.7 : 0,
            child: _isSearchExpanded
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar contratos...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _isSearchExpanded = false;
                          });
                          _loadContracts();
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (_) => _loadContracts(),
                  )
                : null,
          ),
          IconButton(
            icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded) {
                  _searchController.clear();
                  _searchQuery = '';
                  _loadContracts();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                  _loadContracts();
                }
              },
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/contratos/novo');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erro ao carregar contratos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContracts,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nenhum contrato encontrado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/contratos/novo');
              },
              child: const Text('Criar novo contrato'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContracts,
      child: ListView.builder(
        itemCount: _contracts.length,
        itemBuilder: (context, index) {
          final contract = _contracts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(contract['contract_number'] ?? 'Sem número'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Tipo: ${_getTypeDisplayName(contract['type'] ?? 'other')}'),
                  const SizedBox(height: 4),
                  ContractStatusBadge(status: contract['status'] ?? 'pending'),
                  const SizedBox(height: 4),
                  Text(
                    'Valor: R\$ ${(contract['contract_value'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão para marcar como concluído
                  if (contract['status'] != 'completed')
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.green),
                      onPressed: () =>
                          _updateContractStatus(contract['id'], 'completed'),
                      tooltip: 'Marcar como concluído',
                    ),

                  // Menu de ações
                  PopupMenuButton<String>(
                    onSelected: (String value) async {
                      if (value == 'delete') {
                        await _deleteContract(contract);
                      } else if (value == 'edit_status') {
                        await _showStatusDialog(contract);
                      } else if (value == 'edit') {
                        Navigator.pushNamed(
                          context,
                          '/contratos/editar',
                          arguments: contract,
                        ).then((_) => _loadContracts());
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit_status',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Editar Status'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_note, size: 16),
                            SizedBox(width: 8),
                            Text('Editar Contrato'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
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
          );
        },
      ),
    );
  }

  Future<void> _updateContractStatus(int contractId, String newStatus) async {
    try {
      await ContractService.updateContractStatus(
        id: contractId,
        status: newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status atualizado para: ${_getStatusDisplayName(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadContracts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteContract(Map<String, dynamic> contract) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o contrato "${contract['contract_number']}"?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ContractService.deleteContract(contract['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contrato excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          _loadContracts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir contrato: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showStatusDialog(Map<String, dynamic> contract) async {
    final statusOptions = {
      'active': 'Ativo',
      'pending': 'Pendente',
      'completed': 'Concluído',
      'cancelled': 'Cancelado',
      'expired': 'Vencido',
    };

    final selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alterar Status - ${contract['contract_number']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusOptions.entries.map((entry) {
            final isCurrentStatus = entry.key == contract['status'];
            return ListTile(
              title: Text(entry.value),
              leading: Radio<String>(
                value: entry.key,
                groupValue: contract['status'],
                onChanged: isCurrentStatus
                    ? null
                    : (value) {
                        Navigator.pop(context, value);
                      },
              ),
              enabled: !isCurrentStatus,
              subtitle: isCurrentStatus ? const Text('Status atual') : null,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selectedStatus != null && selectedStatus != contract['status']) {
      await _updateContractStatus(contract['id'], selectedStatus);
    }
  }

  String _getStatusDisplayName(String status) {
    const statusMap = {
      'active': 'Ativo',
      'pending': 'Pendente',
      'completed': 'Concluído',
      'cancelled': 'Cancelado',
      'expired': 'Vencido',
    };
    return statusMap[status] ?? status;
  }

  String _getTypeDisplayName(String type) {
    const typeMap = {
      'sale': 'Venda',
      'rental': 'Locação',
      'lease': 'Arrendamento',
      'other': 'Outro',
    };
    return typeMap[type] ?? type;
  }
}
