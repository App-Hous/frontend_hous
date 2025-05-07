import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;
  final VoidCallback? aoClicar;

  const StatusCard({
    Key? key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.aoClicar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: aoClicar,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icone, color: cor),
                  const SizedBox(width: 8),
                  Text(titulo, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                valor,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: cor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
