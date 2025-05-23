import 'package:flutter/material.dart';
import '../../services/contract_service.dart';

class ContractListPage extends StatefulWidget {
  const ContractListPage({super.key});

  @override
  State<ContractListPage> createState() => _ContractListPageState();
}

class _ContractListPageState extends State<ContractListPage> {
  List<Map<String, dynamic>> _contracts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final contracts = await ContractService.getContracts();
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
      ),
      body: _buildBody(),
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
                  Text('Tipo: ${contract['type'] ?? 'Não especificado'}'),
                  Text('Status: ${contract['status'] ?? 'Não especificado'}'),
                  Text(
                    'Valor: R\$ ${(contract['contract_value'] ?? 0.0).toStringAsFixed(2)}',
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir'),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.pushNamed(
                      context,
                      '/contratos/editar',
                      arguments: contract,
                    );
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: const Text(
                          'Tem certeza que deseja excluir este contrato?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await ContractService.deleteContract(contract['id']);
                        _loadContracts();
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
                },
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
}
