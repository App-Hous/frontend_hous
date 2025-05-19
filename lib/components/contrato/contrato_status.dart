import 'package:flutter/material.dart';

class ContratoStatus extends StatelessWidget {
  final String status;

  const ContratoStatus({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final (color, backgroundColor) = _getStatusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Ativo';
      case 'pending':
        return 'Pendente';
      case 'completed':
        return 'Concluído';
      case 'cancelled':
        return 'Cancelado';
      case 'expired':
        return 'Vencido';
      default:
        return status;
    }
  }

  (Color, Color) _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return (Colors.green, Colors.green.withOpacity(0.1));
      case 'pending':
        return (Colors.orange, Colors.orange.withOpacity(0.1));
      case 'completed':
        return (Colors.blue, Colors.blue.withOpacity(0.1));
      case 'cancelled':
        return (Colors.red, Colors.red.withOpacity(0.1));
      case 'expired':
        return (Colors.red, Colors.red.withOpacity(0.1));
      default:
        return (Colors.grey, Colors.grey.withOpacity(0.1));
    }
  }
}
