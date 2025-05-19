import 'package:flutter/material.dart';
import '../../components/contrato/contrato_card.dart';
import '../../components/contrato/contrato_filter.dart';
import '../../services/contract_service.dart';
import '../../services/cliente_service.dart';
import '../../services/servico_service.dart';

class ListaContratosPage extends StatefulWidget {
  const ListaContratosPage({super.key});

  @override
  State<ListaContratosPage> createState() => _ListaContratosPageState();
}

class _ListaContratosPageState extends State<ListaContratosPage> {
  List<Map<String, dynamic>> _contratos = [];
  bool _isLoading = true;
  String? _error;
  String _filtroAtual = 'todos';
  final List<String> _filtros = [
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
    _loadContratos();
  }

  Future<void> _loadContratos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final contratos = await ContractService.getContracts();
      final clientes = await ClienteService.getClientes();
      final imoveis = await ServicoService.getServicos();

      // Mapear IDs para nomes
      final clientesMap = {for (var c in clientes) c['id']: c['name']};
      final imoveisMap = {for (var i in imoveis) i['id']: i['name']};

      // Adicionar nomes aos contratos
      for (var contrato in contratos) {
        contrato['client_name'] = clientesMap[contrato['client_id']];
        contrato['property_name'] = imoveisMap[contrato['property_id']];
      }

      setState(() {
        _contratos = contratos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getContratosFiltrados() {
    if (_filtroAtual == 'todos') {
      return _contratos;
    }
    return _contratos.where((contrato) {
      final status = contrato['status']?.toString().toLowerCase() ?? '';
      return status == _filtroAtual.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contratos', style: Theme.of(context).textTheme.headlineSmall),
            Text(
              'Gerencie seus contratos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar busca
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros avançados
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
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
                        onPressed: _loadContratos,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filtros
                    ContratoFilter(
                      filtroAtual: _filtroAtual,
                      filtros: _filtros,
                      onFiltroChanged: (filtro) {
                        setState(() {
                          _filtroAtual = filtro;
                        });
                      },
                    ),
                    // Lista de Contratos
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadContratos,
                        child: _contratos.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Nenhum contrato encontrado',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/contratos/novo');
                                      },
                                      child: const Text('Criar novo contrato'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _getContratosFiltrados().length,
                                itemBuilder: (context, index) {
                                  final contrato =
                                      _getContratosFiltrados()[index];
                                  return ContratoCard(
                                    contrato: contrato,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/contratos/detalhes',
                                        arguments: contrato,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
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
}
