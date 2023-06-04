import 'package:flutter/material.dart';

class CustText extends StatelessWidget {
  final String text;
  final bool bold;
  final bool com;
  const CustText(
    this.text, {
    this.bold = false,
    this.com = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold || com ? FontWeight.w500 : null,
          fontSize: 16 + (bold ? 4 : 0) + (com ? 2 : 0),
        ),
      ),
    );
  }
}
