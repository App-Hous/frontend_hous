import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<Map<String, dynamic>> _contratosFiltrados = [];
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
    'sale',
    'rental',
    'lease',
    'high_value',
    'expiring_soon',
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
        if (contrato['title'] == null || contrato['title'].toString().isEmpty) {
          contrato['title'] = contrato['contract_number'];
        }
      }

      setState(() {
        _contratos = contratos;
        _isLoading = false;
      });

      // Aplicar filtros após carregar os dados
      _aplicarFiltros();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _aplicarFiltros() {
    List<Map<String, dynamic>> contratosFiltrados = List.from(_contratos);

    // Aplicar filtros especiais
    if (_filtroAtual != 'todos') {
      contratosFiltrados = contratosFiltrados.where((contrato) {
        switch (_filtroAtual) {
          case 'active':
          case 'pending':
          case 'completed':
          case 'cancelled':
          case 'expired':
            return contrato['status'] == _filtroAtual;
          case 'sale':
          case 'rental':
          case 'lease':
            return contrato['type'] == _filtroAtual;
          case 'high_value':
            final valor = (contrato['contract_value'] ?? 0.0).toDouble();
            return valor >= 50000.0; // Contratos acima de R$ 50.000
          case 'expiring_soon':
            if (contrato['expiration_date'] != null) {
              try {
                final dataExpiracao =
                    DateTime.parse(contrato['expiration_date']);
                final agora = DateTime.now();
                final diferenca = dataExpiracao.difference(agora).inDays;
                return diferenca <= 30 &&
                    diferenca >= 0; // Expiram em até 30 dias
              } catch (e) {
                return false;
              }
            }
            return false;
          default:
            return true;
        }
      }).toList();
    }

    // Aplicar filtro de busca
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      contratosFiltrados = contratosFiltrados.where((contrato) {
        final title = (contrato['title'] ?? '').toString().toLowerCase();
        final number =
            (contrato['contract_number'] ?? '').toString().toLowerCase();
        final clientName =
            (contrato['client_name'] ?? '').toString().toLowerCase();
        final propertyName =
            (contrato['property_name'] ?? '').toString().toLowerCase();
        final description =
            (contrato['description'] ?? '').toString().toLowerCase();
        final type = (contrato['type'] ?? '').toString().toLowerCase();
        final status = (contrato['status'] ?? '').toString().toLowerCase();

        return title.contains(searchLower) ||
            number.contains(searchLower) ||
            clientName.contains(searchLower) ||
            propertyName.contains(searchLower) ||
            description.contains(searchLower) ||
            type.contains(searchLower) ||
            status.contains(searchLower);
      }).toList();
    }

    // Ordenar por data de criação (mais recentes primeiro)
    contratosFiltrados.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at'] ?? '');
      final dateB = DateTime.tryParse(b['created_at'] ?? '');
      if (dateA != null && dateB != null) {
        return dateB.compareTo(dateA);
      }
      return 0;
    });

    setState(() {
      _contratosFiltrados = contratosFiltrados;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _aplicarFiltros();
  }

  void _onFiltroChanged(String filtro) {
    setState(() {
      _filtroAtual = filtro;
    });
    _aplicarFiltros();
  }

  Future<void> _handleNavigateToNovoContrato() async {
    final result = await Navigator.pushNamed(context, '/contratos/novo');
    if (result == true) {
      // Contrato criado com sucesso, recarregar lista
      await _loadContratos();

      // Mostrar feedback de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Contrato criado com sucesso!',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: _isSearchExpanded
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar contratos...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: TextStyle(color: Color(0xFF2C3E50)),
                onChanged: _onSearchChanged,
                onSubmitted: (_) => _aplicarFiltros(),
              )
            : Text(
                'Contratos',
                style: GoogleFonts.poppins(
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchExpanded ? Icons.close : Icons.search,
              color: Color(0xFF2C3E50),
            ),
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded) {
                  _searchQuery = '';
                  _searchController.clear();
                  _aplicarFiltros();
                }
              });
            },
          ),
        ],
        centerTitle: false,
      ),
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadContratos,
        color: Color(0xFF2C3E50),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ContratoFilter(
                  filtroAtual: _filtroAtual,
                  filtros: _filtros,
                  onFiltroChanged: _onFiltroChanged,
                ),
              ),
            ),
            // Mostrar contador de resultados
            if (!_isLoading && _error == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_contratosFiltrados.length} contrato${_contratosFiltrados.length != 1 ? 's' : ''} encontrado${_contratosFiltrados.length != 1 ? 's' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _filtroAtual != 'todos')
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchQuery = '';
                              _filtroAtual = 'todos';
                              _searchController.clear();
                              _isSearchExpanded = false;
                            });
                            _aplicarFiltros();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.clear,
                                    size: 16, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  'Limpar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            _isLoading
                ? SliverFillRemaining(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF2C3E50)),
                    ),
                  )
                : _error != null
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Erro ao carregar contratos',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _error!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadContratos,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2C3E50),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _contratosFiltrados.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description,
                                      size: 64, color: Colors.grey[400]),
                                  SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty ||
                                            _filtroAtual != 'todos'
                                        ? 'Nenhum contrato encontrado com os filtros aplicados'
                                        : 'Nenhum contrato encontrado',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  if (_searchQuery.isNotEmpty ||
                                      _filtroAtual != 'todos')
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _searchQuery = '';
                                          _filtroAtual = 'todos';
                                          _searchController.clear();
                                          _isSearchExpanded = false;
                                        });
                                        _aplicarFiltros();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[600],
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Limpar filtros'),
                                    ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _handleNavigateToNovoContrato,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF2C3E50),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Criar novo contrato'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: EdgeInsets.only(
                                bottom: 80, left: 16, right: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final contrato = _contratosFiltrados[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: ContratoCard(
                                      contrato: contrato,
                                      onUpdate: _loadContratos,
                                      onTap: () async {
                                        final result =
                                            await Navigator.pushNamed(
                                          context,
                                          '/contratos/detalhes',
                                          arguments: contrato,
                                        );

                                        // Se houve alguma mudança nos detalhes, recarregar lista
                                        if (result == true) {
                                          await _loadContratos();

                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(Icons.refresh,
                                                        color: Colors.white),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Lista atualizada com sucesso!',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Colors.blue,
                                                duration: Duration(seconds: 2),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  );
                                },
                                childCount: _contratosFiltrados.length,
                              ),
                            ),
                          ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleNavigateToNovoContrato,
        backgroundColor: Color(0xFF2C3E50),
        child: const Icon(Icons.add),
      ),
    );
  }
}
