import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final Widget? suffix;
  final TextEditingController? ctrl;
  const CustomField(
      {super.key, this.ctrl, this.suffix, Function(String)? onChange});

  @override
  Widget build(BuildContext context) {
    final controller = ctrl ?? TextEditingController();
    return TextField(
      controller: controller,
      decoration: InputDecoration(suffix: suffix),
      textAlignVertical: TextAlignVertical.bottom,
      style: const TextStyle(fontSize: 18),
    );
  }
}
