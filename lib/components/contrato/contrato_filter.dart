import 'package:flutter/material.dart';

class ContratoFilter extends StatelessWidget {
  final String filtroAtual;
  final List<String> filtros;
  final Function(String) onFiltroChanged;

  const ContratoFilter({
    Key? key,
    required this.filtroAtual,
    required this.filtros,
    required this.onFiltroChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final filtro = filtros[index];
          final isSelected = filtro == filtroAtual;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_formatStatus(filtro)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFiltroChanged(filtro);
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Color(0xFF2C3E50).withOpacity(0.2),
              checkmarkColor: Color(0xFF2C3E50),
              labelStyle: TextStyle(
                color: isSelected
                    ? Color(0xFF2C3E50)
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: isSelected 
                  ? BorderSide(color: Color(0xFF2C3E50), width: 1.5)
                  : BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'todos':
        return 'Todos';
      case 'active':
        return 'Ativos';
      case 'pending':
        return 'Pendentes';
      case 'completed':
        return 'Concluídos';
      case 'cancelled':
        return 'Cancelados';
      case 'expired':
        return 'Vencidos';
      case 'sale':
        return 'Venda';
      case 'rental':
        return 'Aluguel';
      case 'lease':
        return 'Arrendamento';
      case 'other':
        return 'Outros';
      case 'high_value':
        return 'Alto Valor';
      case 'expiring_soon':
        return 'Vencem em Breve';
      default:
        return status.toUpperCase();
    }
  }
}
