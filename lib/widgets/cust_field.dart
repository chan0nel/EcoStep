// ignore_for_file: avoid_init_to_null

import 'package:diplom/logic/map_service.dart';
import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  final TextEditingController? ctrl;
  final String? hintText;
  final bool custStyle;
  final TextInputType type;
  final bool onSubm;
  const CustomField(
      {super.key,
      this.ctrl = null,
      this.custStyle = false,
      this.hintText = null,
      this.type = TextInputType.text,
      this.onSubm = false});

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  bool valid = true;
  Function? func = null;

  void email(value) {
    if (widget.type.toJson()['name'] == 'TextInputType.emailAddress') {
      var regex = RegExp(r'^((?!\.)[\w_.]*[^.])(@\w+)(\.\w+(\.\w+)?[^.\W])$');
      if (regex.hasMatch(widget.ctrl!.text)) {
        setState(() {
          valid = true;
        });
      } else {
        setState(() {
          valid = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = widget.type == TextInputType.emailAddress
        ? TextStyle(fontSize: 16, color: valid ? Colors.black87 : Colors.red)
        : const TextStyle(fontSize: 16);
    return TextField(
      scrollPhysics: const BouncingScrollPhysics(),
      controller: widget.ctrl,
      textAlignVertical: TextAlignVertical.bottom,
      decoration: InputDecoration(hintText: widget.hintText),
      style: style,
      enabled: !widget.onSubm,
      onChanged: (value) {
        if (widget.type == TextInputType.emailAddress) email(value);
      },
    );
  }
}
