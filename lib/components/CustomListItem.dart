import 'package:flutter/material.dart';

class CustomListItem extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final String? status;
  final Color? corStatus;
  final VoidCallback? aoClicar;
  final Widget? trailing;

  const CustomListItem({
    Key? key,
    required this.titulo,
    this.subtitulo,
    this.status,
    this.corStatus,
    this.aoClicar,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitulo != null) Text(subtitulo!),
            if (status != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: corStatus?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status!,
                  style: TextStyle(color: corStatus, fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: trailing,
        onTap: aoClicar,
      ),
    );
  }
}
