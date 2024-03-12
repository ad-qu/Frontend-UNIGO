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
        padding: const EdgeInsets.all(16.5),
        decoration: BoxDecoration(
            border:
                Border.all(color: Color.fromARGB(255, 30, 30, 30), width: 1),
            color: const Color.fromARGB(255, 23, 23, 23),
            borderRadius: BorderRadius.circular(17.5)),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 14,
              //fontWeight: FontWeight.w300,
              color: Color.fromARGB(255, 227, 227, 227),
            ),
          ),
        ),
      ),
    );
  }
}
