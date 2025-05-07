import 'package:flutter/material.dart';
import 'custom_bottom_nav.dart';
import 'custom_app_bar.dart';

class CustomScaffold extends StatelessWidget {
  final String titulo;
  final Widget corpo;
  final List<Widget>? acoes;
  final bool mostrarNavInferior;
  final int indiceAtual;
  final Function(int)? aoClicarNav;

  const CustomScaffold({
    Key? key,
    required this.titulo,
    required this.corpo,
    this.acoes,
    this.mostrarNavInferior = true,
    this.indiceAtual = 0,
    this.aoClicarNav,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: titulo, actions: acoes),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16.0), child: corpo),
      ),
      bottomNavigationBar:
          mostrarNavInferior
              ? CustomBottomNav(currentIndex: indiceAtual, onTap: aoClicarNav)
              : null,
    );
  }
}
