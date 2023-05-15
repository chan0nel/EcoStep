// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  late bool helperText;
  final TextEditingController ctrl;
  final TextEditingController? dop;

  PasswordField(
      {super.key, required this.helperText, required this.ctrl, this.dop});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool passVis = false;
  bool passValid = true;
  String hlpTxt =
      'Латиница, цифра, спец. символ, заглавная и строчная буква, от 8 символов';

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.ctrl,
      obscureText: !passVis,
      textAlignVertical: TextAlignVertical.bottom,
      maxLength: 16,
      style: const TextStyle(fontSize: 24),
      decoration: InputDecoration(
        counterText: '   ${widget.ctrl.text.length.toString()}/16',
        counterStyle: TextStyle(color: Theme.of(context).hintColor),
        helperText: widget.helperText ? hlpTxt : null,
        helperMaxLines: 3,
        helperStyle: TextStyle(
            fontSize: 13,
            color: passValid || widget.ctrl.text.trim().isEmpty
                ? Theme.of(context).hintColor
                : Colors.red),
        suffix: IconButton(
          onPressed: () {
            setState(() {
              passVis = !passVis;
            });
          },
          icon: passVis
              ? const Icon(Icons.visibility_off_rounded, size: 32)
              : const Icon(Icons.visibility_rounded, size: 32),
        ),
      ),
      onChanged: (value) {
        var regex = RegExp(
            r'^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[^\w\d\s:])([^\s]){8,16}$');
        if (regex.hasMatch(widget.ctrl.text)) {
          setState(() {
            passValid = true;
          });
        } else {
          setState(() {
            passValid = false;
          });
        }
        if (widget.dop != null) {
          if (widget.dop?.text != widget.ctrl.text) {
            setState(() {
              widget.helperText = true;
              hlpTxt = 'Пароли не совпадают';
            });
          } else {
            setState(() {
              widget.helperText = false;
            });
          }
        }
      },
    );
  }
}
