import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DescriptionBigTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Function(String)? function;

  const DescriptionBigTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    this.function,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DescriptionBigTextFieldState createState() =>
      _DescriptionBigTextFieldState();
}

class _DescriptionBigTextFieldState extends State<DescriptionBigTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textAlignVertical: TextAlignVertical.top,
      maxLength: 200,
      minLines: 3,
      maxLines: 5,
      expands: false,
      obscureText: widget.obscureText,
      cursorWidth: 1,
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
        alignLabelWithHint: true,
        counterText: '',
      ),
    );
  }
}
