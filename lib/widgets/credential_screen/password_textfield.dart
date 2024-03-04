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
      cursorColor: const Color.fromARGB(255, 222, 66, 66),
      style: const TextStyle(
          color: Color.fromARGB(255, 227, 227, 227), fontSize: 14),
      decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(color: Color.fromARGB(255, 25, 25, 25), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          focusedBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 25, 25, 25), width: 1),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          labelText: widget.labelText,
          labelStyle: const TextStyle(
              color: Color.fromARGB(255, 138, 138, 138), fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          fillColor: const Color.fromARGB(50, 30, 30, 30),
          filled: true,
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Color.fromARGB(255, 227, 227, 227),
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          )),
    );
  }
}
