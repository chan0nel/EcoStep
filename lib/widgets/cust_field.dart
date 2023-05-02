// ignore_for_file: avoid_init_to_null

import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  final TextEditingController? ctrl;
  final String? hintText;
  final bool custStyle;
  final TextInputType type;
  const CustomField({
    super.key,
    this.ctrl = null,
    this.custStyle = false,
    this.hintText = null,
    this.type = TextInputType.text,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  bool valid = true;

  @override
  Widget build(BuildContext context) {
    TextStyle style = widget.custStyle
        ? TextStyle(fontSize: 24, color: valid ? Colors.black87 : Colors.red)
        : const TextStyle(fontSize: 16);

    return TextField(
      scrollPhysics: const BouncingScrollPhysics(),
      controller: widget.ctrl,
      textAlignVertical: TextAlignVertical.bottom,
      decoration: InputDecoration(hintText: widget.hintText),
      style: style,
      onChanged: widget.custStyle
          ? (value) {
              if (widget.type.toJson()['name'] ==
                  'TextInputType.emailAddress') {
                var regex =
                    RegExp(r'^((?!\.)[\w_.]*[^.])(@\w+)(\.\w+(\.\w+)?[^.\W])$');
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
          : null,
    );
  }
}
