import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String dica;
  final Function(String) aoBuscar;
  final TextEditingController? controlador;

  const CustomSearchBar({
    Key? key,
    required this.dica,
    required this.aoBuscar,
    this.controlador,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      decoration: InputDecoration(
        hintText: dica,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: aoBuscar,
    );
  }
}
