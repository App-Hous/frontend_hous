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
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  (Color, Color) _getStatusColors(String status) {
    switch (status) {
      case 'Em Andamento':
        return (Colors.green, Colors.green.withOpacity(0.1));
      case 'Pendente':
        return (Colors.orange, Colors.orange.withOpacity(0.1));
      case 'Concluído':
        return (Colors.blue, Colors.blue.withOpacity(0.1));
      case 'Vencido':
        return (Colors.red, Colors.red.withOpacity(0.1));
      default:
        return (Colors.grey, Colors.grey.withOpacity(0.1));
    }
  }
}
