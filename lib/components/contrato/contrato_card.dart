import 'package:flutter/material.dart';
import 'contrato_status.dart';

class ContratoCard extends StatelessWidget {
  final Map<String, dynamic> contrato;
  final VoidCallback onTap;

  const ContratoCard({Key? key, required this.contrato, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildInfoRows(context),
              const SizedBox(height: 12),
              _buildDates(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.description,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (contrato['contract_number']?.toString() ?? '-'),
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _traduzirTipo(contrato['type']?.toString()),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ContratoStatus(status: contrato['status'] ?? 'Não especificado'),
      ],
    );
  }

  Widget _buildInfoRows(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoRow(
          context,
          'Cliente',
          (contrato['client_name']?.toString() ??
              contrato['client_id']?.toString() ??
              '-'),
          Icons.person_outline,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          context,
          'Imóvel',
          (contrato['property_name']?.toString() ??
              contrato['property_id']?.toString() ??
              '-'),
          Icons.home_outlined,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          context,
          'Valor',
          _formatarValor(contrato['contract_value']),
          Icons.attach_money,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    dynamic value,
    IconData icon,
  ) {
    final safeValue = value?.toString() ?? '-';
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            safeValue,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDates(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildDateInfo(
            context,
            'Início',
            contrato['signing_date']?.toString().split('T')[0] ??
                'Não especificada',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateInfo(
            context,
            'Término',
            contrato['expiration_date']?.toString().split('T')[0] ??
                'Não especificada',
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(BuildContext context, String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatarValor(dynamic valor) {
    if (valor == null) return 'R\$ 0,00';
    final number = double.tryParse(valor.toString()) ?? 0.0;
    return 'R\$ ' +
        number.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  String _traduzirTipo(String? type) {
    switch (type) {
      case 'sale':
        return 'Venda';
      case 'rental':
        return 'Aluguel';
      case 'lease':
        return 'Arrendamento';
      case 'other':
        return 'Outro';
      default:
        return type ?? 'Tipo não especificado';
    }
  }
}
