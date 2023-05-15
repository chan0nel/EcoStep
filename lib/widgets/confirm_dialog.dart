import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String opt;
  const ConfirmDialog({super.key, required this.opt});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        'Вы уверены что хотите $opt?',
        style: const TextStyle(fontSize: 20),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Да')),
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Нет')),
      ],
    );
  }
}
