import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final void Function(int) onTabTapped; // Removido o ? para garantir função obrigatória

  const CustomScaffold({
    Key? key,
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped, // Corrigido tipo esperado
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
