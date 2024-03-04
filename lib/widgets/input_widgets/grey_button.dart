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
            border:
                Border.all(color: Color.fromARGB(255, 25, 25, 25), width: 1),
            color: const Color.fromARGB(50, 30, 30, 30),
            borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 227, 227, 227),
            ),
          ),
        ),
      ),
    );
  }
}
