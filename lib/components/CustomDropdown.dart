import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String rotulo;
  final String? valor;
  final List<String> itens;
  final Function(String?) aoMudar;
  final String? textoErro;

  const CustomDropdown({
    Key? key,
    required this.rotulo,
    required this.valor,
    required this.itens,
    required this.aoMudar,
    this.textoErro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: valor,
          items:
              itens.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: aoMudar,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: textoErro,
          ),
        ),
      ],
    );
  }
}
