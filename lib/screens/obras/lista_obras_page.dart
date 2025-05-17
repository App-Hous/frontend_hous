import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/project_service.dart';
import 'obra_visualizar_page.dart';


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

  String traduzirStatus(String status) {
    switch (status) {
      case 'planning':
        return 'Planejamento';
      case 'in_progress':
        return 'Em andamento';
      case 'finished':
        return 'Concluído';
      default:
        return 'Indefinido';
    }
  }

  Color corStatus(String status) {
    switch (status) {
      case 'planning':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'finished':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obras'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home', // certifique-se que esta rota está definida no MaterialApp
              (route) => false,
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filtroAtual = value),
            itemBuilder: (context) =>
                _filtros.map((f) => PopupMenuItem(value: f, child: Text(f))).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : obrasFiltradas.isEmpty
              ? const Center(child: Text('Nenhuma obra encontrada'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: obrasFiltradas.length,
                  itemBuilder: (context, index) {
                    final obra = obrasFiltradas[index];
                    final status = obra['status'] ?? 'unknown';
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          obra['name'] ?? 'Sem nome',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text("📍 ${obra['address'] ?? 'Sem endereço'}"),
                            const SizedBox(height: 4),
                            Text(
                              "📌 ${traduzirStatus(status)}",
                              style: TextStyle(
                                color: corStatus(status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "💰 Orçamento: ${currencyFormat.format(obra['budget'] ?? 0)}",
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ObraVisualizarPage(obra: obra),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/obras/nova'),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
