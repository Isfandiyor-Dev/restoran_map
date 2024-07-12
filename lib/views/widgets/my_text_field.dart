import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String labelText;
  final String? Function(String?) validation;
  final TextEditingController textEditingController;
  const MyTextField({
    super.key,
    required this.labelText,
    required this.validation,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      validator: validation,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
