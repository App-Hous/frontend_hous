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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final filtro = filtros[index];
          final isSelected = filtro == filtroAtual;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filtro),
              selected: isSelected,
              onSelected: (selected) => onFiltroChanged(filtro),
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color:
                    isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
              ),
            ),
          );
        },
      ),
    );
  }
}
