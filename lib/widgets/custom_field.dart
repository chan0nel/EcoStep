// import 'package:flutter/material.dart';

// class CustomField extends StatefulWidget {
//   final TextInputType textInputType;
//   final String hintText;
//   final TextEditingController ctrl;

//   const CustomField({
//     super.key,
//     required this.textInputType,
//     required this.hintText,
//     required this.ctrl,
//   });

//   @override
//   State<CustomField> createState() => _CustomFieldState();
// }

// class _CustomFieldState extends State<CustomField> {
//   bool valid = true;

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: widget.ctrl,
//       keyboardType: widget.textInputType,
//       decoration: InputDecoration(hintText: widget.hintText),
//       textAlignVertical: TextAlignVertical.bottom,
//       style:
//           TextStyle(fontSize: 24, color: valid ? Colors.black87 : Colors.red),
//       onChanged: (value) {
//         if (widget.textInputType.toJson()['name'] ==
//             'TextInputType.emailAddress') {
//           var regex =
//               RegExp(r'^((?!\.)[\w_.]*[^.])(@\w+)(\.\w+(\.\w+)?[^.\W])$');
//           if (regex.hasMatch(widget.ctrl.text)) {
//             setState(() {
//               valid = true;
//             });
//           } else {
//             setState(() {
//               valid = false;
//             });
//           }
//         }
//       },
//     );
//   }
// }
