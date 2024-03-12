// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Function(String)? function;

  const PasswordTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    this.function,
  }) : super(key: key);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      cursorWidth: 1,
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).dividerColor, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(17.5))),
        contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).dividerColor, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(17.5)),
        ),
        labelText: widget.labelText,
        labelStyle: const TextStyle(
            color: Color.fromARGB(255, 138, 138, 138), fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Theme.of(context).cardColor,
        filled: true,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 7.0),
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
