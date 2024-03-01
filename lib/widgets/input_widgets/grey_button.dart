import 'package:flutter/material.dart';

class BlackButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;

  const BlackButton({super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(255, 41, 41, 41), width: 1),
            color: const Color.fromARGB(15, 41, 41, 41),
            borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 13,
              color: Color.fromARGB(255, 227, 227, 227),
            ),
          ),
        ),
      ),
    );
  }
}
