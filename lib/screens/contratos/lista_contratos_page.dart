import 'package:flutter/material.dart';
import '../../components/contrato/contrato_card.dart';
import '../../components/contrato/contrato_filter.dart';
import '../../components/contrato/contrato_search_field.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  String _searchQuery = '';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContratos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final contratos = await ContractService.getContracts(
        search: _searchQuery,
        status: _filtroAtual == 'todos' ? null : _filtroAtual,
      );
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

      // Filtrar resultados se houver termo de busca
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        contratos.removeWhere((contrato) {
          final title = (contrato['title'] ?? '').toString().toLowerCase();
          final number =
              (contrato['contract_number'] ?? '').toString().toLowerCase();
          final clientName =
              (contrato['client_name'] ?? '').toString().toLowerCase();
          final propertyName =
              (contrato['property_name'] ?? '').toString().toLowerCase();

          return !title.contains(searchLower) &&
              !number.contains(searchLower) &&
              !clientName.contains(searchLower) &&
              !propertyName.contains(searchLower);
        });
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
            Text('Contratos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    )),
            Text(
              'Gerencie seus contratos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        actions: [
          ContratoSearchField(
            controller: _searchController,
            isExpanded: _isSearchExpanded,
            contracts: _contratos,
            onResultsFiltered: (filteredResults) {
              setState(() {
                _contratos = filteredResults;
              });
            },
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onSubmitted: (_) => _loadContratos(),
            onToggle: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded) {
                  _searchController.clear();
                  _searchQuery = '';
                  _loadContratos();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _loadContratos();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Função de busca avançada foi removida'),
                  duration: Duration(seconds: 2),
                ),
              );
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
                        _loadContratos();
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
                                itemCount: _contratos.length,
                                itemBuilder: (context, index) {
                                  final contrato = _contratos[index];
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
