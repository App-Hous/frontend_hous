import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;
  final Color? cor;

  const CustomFilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.cor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: cor?.withOpacity(0.2),
      checkmarkColor: cor,
      labelStyle: TextStyle(color: selected ? cor : Colors.grey[600]),
    );
  }
}
