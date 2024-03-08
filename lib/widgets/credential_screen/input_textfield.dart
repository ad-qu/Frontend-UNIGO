import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Colors.black,
        ),
      ),
      home: Scaffold(
        body: Center(
          child: InputTextField(
            controller: TextEditingController(),
            labelText: 'Password',
            obscureText: true,
          ),
        ),
      ),
    );
  }
}

class InputTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Function(String)? function;

  const InputTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    this.function,
  }) : super(key: key);

  @override
  _InputTextFieldState createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      cursorColor: const Color.fromARGB(255, 227, 227, 227),
      cursorWidth: 1,
      style: const TextStyle(
        color: Color.fromARGB(255, 227, 227, 227),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 25, 25, 25),
            width: 1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 25, 25, 25),
            width: 1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 138, 138, 138),
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: const Color.fromARGB(50, 30, 30, 30),
        filled: true,
      ),
    );
  }
}
