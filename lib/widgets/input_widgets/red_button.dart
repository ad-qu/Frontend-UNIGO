import 'package:flutter/material.dart';

class RedButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;

  const RedButton({super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(21.5),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 217, 59, 60),
            borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 227, 227, 227)),
          ),
        ),
      ),
    );
  }
}
