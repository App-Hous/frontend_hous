import 'package:flutter/material.dart';

class ContractStatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const ContractStatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: isSmall ? 12 : 14,
            color: config.color,
          ),
          SizedBox(width: isSmall ? 2 : 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return _StatusConfig(
          label: 'Ativo',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case 'pending':
        return _StatusConfig(
          label: 'Pendente',
          color: Colors.orange,
          icon: Icons.pending,
        );
      case 'completed':
        return _StatusConfig(
          label: 'Concluído',
          color: Colors.blue,
          icon: Icons.task_alt,
        );
      case 'cancelled':
        return _StatusConfig(
          label: 'Cancelado',
          color: Colors.red,
          icon: Icons.cancel,
        );
      case 'expired':
        return _StatusConfig(
          label: 'Vencido',
          color: Colors.grey,
          icon: Icons.schedule,
        );
      default:
        return _StatusConfig(
          label: status.toUpperCase(),
          color: Colors.grey,
          icon: Icons.help,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}
