import 'package:flutter/material.dart';
import '../../components/contrato/contrato_card.dart';
import '../../components/contrato/contrato_filter.dart';

class ListaContratosPage extends StatefulWidget {
  const ListaContratosPage({super.key});

  @override
  State<ListaContratosPage> createState() => _ListaContratosPageState();
}

class _ListaContratosPageState extends State<ListaContratosPage> {
  // Dados de exemplo - depois serão substituídos pelos dados reais
  final List<Map<String, dynamic>> contratos = [
    {
      'numero': 'CT-2024-001',
      'tipo': 'Construção',
      'cliente': 'João Silva',
      'imovel': 'Residência A',
      'dataInicio': '2024-01-15',
      'dataFim': '2024-07-15',
      'valor': 250000.00,
      'status': 'Em Andamento',
    },
    {
      'numero': 'CT-2024-002',
      'tipo': 'Reforma',
      'cliente': 'Maria Santos',
      'imovel': 'Comercial B',
      'dataInicio': '2024-02-01',
      'dataFim': '2024-04-01',
      'valor': 120000.00,
      'status': 'Pendente',
    },
    {
      'numero': 'CT-2023-015',
      'tipo': 'Construção',
      'cliente': 'Pedro Oliveira',
      'imovel': 'Residência C',
      'dataInicio': '2023-11-01',
      'dataFim': '2024-05-01',
      'valor': 350000.00,
      'status': 'Concluído',
    },
  ];

  String _filtroAtual = 'Todos';
  final List<String> _filtros = [
    'Todos',
    'Em Andamento',
    'Pendente',
    'Concluído',
    'Vencido',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contratos', style: Theme.of(context).textTheme.headlineSmall),
            Text(
              'Gerencie seus contratos',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
      body: Column(
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contratos.length,
              itemBuilder: (context, index) {
                final contrato = contratos[index];
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
