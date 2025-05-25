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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Text(
          'Contratos',
          style: GoogleFonts.poppins(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ContratoFilter(
                filtroAtual: _filtroAtual,
                filtros: _filtros,
                onFiltroChanged: (filtro) {
                  setState(() {
                    _filtroAtual = filtro;
                  });
                  _loadContratos();
                },
              ),
            ),
          ),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF2C3E50)),
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
                  : SliverFillRemaining(
                      child: _contratos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description, size: 64, color: Colors.grey[400]),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nenhum contrato encontrado',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/contratos/novo');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF2C3E50),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Criar novo contrato'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: _contratos.length,
                              itemBuilder: (context, index) {
                                final contrato = _contratos[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ContratoCard(
                                    contrato: contrato,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/contratos/detalhes',
                                        arguments: contrato,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/contratos/novo');
        },
        backgroundColor: Color(0xFF2C3E50),
        child: const Icon(Icons.add),
      ),
    );
  }
}
