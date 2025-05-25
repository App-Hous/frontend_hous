import 'package:flutter/material.dart';

class ContratoSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Color textColor;
  final Color hintColor;
  final List<Map<String, dynamic>> contracts;
  final Function(List<Map<String, dynamic>>) onResultsFiltered;

  const ContratoSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.isExpanded,
    required this.onToggle,
    required this.contracts,
    required this.onResultsFiltered,
    this.hintText = 'Buscar contratos...',
    this.textColor = Colors.black,
    this.hintColor = Colors.white70,
  });

  void _filterResults(String searchQuery) {
    if (searchQuery.isEmpty) {
      onResultsFiltered(contracts);
      return;
    }

    final searchLower = searchQuery.toLowerCase();
    final filteredResults = contracts.where((contrato) {
      final title = (contrato['title'] ?? '').toString().toLowerCase();
      final number =
          (contrato['contract_number'] ?? '').toString().toLowerCase();
      final clientName =
          (contrato['client_name'] ?? '').toString().toLowerCase();
      final propertyName =
          (contrato['property_name'] ?? '').toString().toLowerCase();
      final description =
          (contrato['description'] ?? '').toString().toLowerCase();

      return title.contains(searchLower) ||
          number.contains(searchLower) ||
          clientName.contains(searchLower) ||
          propertyName.contains(searchLower) ||
          description.contains(searchLower);
    }).toList();

    onResultsFiltered(filteredResults);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isExpanded)
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(color: hintColor),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              style: TextStyle(color: textColor),
              onChanged: (value) {
                onChanged(value);
                _filterResults(value);
              },
              onSubmitted: (value) {
                onSubmitted(value);
                _filterResults(value);
              },
            ),
          ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            onToggle();
            if (!isExpanded) {
              _filterResults(controller.text);
            }
          },
        ),
      ],
    );
  }
}
