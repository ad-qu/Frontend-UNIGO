import 'package:flutter/material.dart';

class InputShortTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Function(String)? function;

  const InputShortTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    this.function,
  });

  @override
  // ignore: library_private_types_in_public_api
  _InputShortTextFieldState createState() => _InputShortTextFieldState();
}

class _InputShortTextFieldState extends State<InputShortTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      cursorWidth: 1,
      maxLength: 12,
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).dividerColor, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(17.5)),
        ),
        contentPadding: const EdgeInsets.all(17),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).dividerColor, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(17.5)),
        ),
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 138, 138, 138),
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Theme.of(context).cardColor,
        filled: true,
        counterText: '',
      ),
    );
  }
}
