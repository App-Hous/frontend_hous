import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ObraVisualizarPage extends StatelessWidget {
  final Map<String, dynamic> obra;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');

  ObraVisualizarPage({super.key, required this.obra});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Obra'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItem('Nome', obra['name']),
            _buildItem('Descrição', obra['description']),
            _buildItem('Endereço', obra['address']),
            _buildItem('Cidade', obra['city']),
            _buildItem('Estado', obra['state']),
            _buildItem('CEP', obra['zip_code']),
            _buildItem('Área Total', '${obra['total_area']} m²'),
            _buildItem('Orçamento', currencyFormat.format(obra['budget'])),
            _buildItem('Empresa', 'ID ${obra['company_id']}'),
            _buildItem('Gerente', 'ID ${obra['manager_id']}'),
            _buildItem('Status', traduzirStatus(obra['status'])),
            _buildItem('Data de Início', dateFormat.format(DateTime.parse(obra['start_date']))),
            _buildItem('Previsão de Término', dateFormat.format(DateTime.parse(obra['expected_end_date']))),
            _buildItem('Término Real', dateFormat.format(DateTime.parse(obra['actual_end_date']))),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/obra/detalhe',
                    arguments: obra,
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar Obra'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '---',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
