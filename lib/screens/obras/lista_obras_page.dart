import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../components/CustomListItem.dart';
import '../../components/CustomSearchBar.dart';
import '../../components/CustomFilterChip.dart';
import '../../components/StatusCard.dart';
import '../../services/project_service.dart';

class ListaObrasPage extends StatefulWidget {
  const ListaObrasPage({super.key});

  @override
  State<ListaObrasPage> createState() => _ListaObrasPageState();
}

class _ListaObrasPageState extends State<ListaObrasPage> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  bool _isLoading = true;
  List<Map<String, dynamic>> obras = [];
  String _filtroAtual = 'Todos';
  final List<String> _filtros = ['Todos', 'Em Andamento', 'Planejamento', 'Concluído'];

  @override
  void initState() {
    super.initState();
    _carregarObras();
  }

  void _carregarObras() async {
    try {
      final dados = await ProjectService.getProjects();
      setState(() {
        obras = dados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar obras: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get obrasFiltradas {
    if (_filtroAtual == 'Todos') return obras;
    return obras.where((obra) => obra['status'] == _filtroAtual).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Obras'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filtroAtual = value),
            itemBuilder: (context) => _filtros.map((f) => PopupMenuItem(value: f, child: Text(f))).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : obrasFiltradas.isEmpty
              ? Center(child: Text('Nenhuma obra encontrada'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: obrasFiltradas.length,
                  itemBuilder: (context, index) {
                    final obra = obrasFiltradas[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(obra['nome'] ?? 'Sem nome'),
                        subtitle: Text(obra['endereco'] ?? 'Sem endereço'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/obra/detalhe',
                            arguments: obra,
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/obras/nova'),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
