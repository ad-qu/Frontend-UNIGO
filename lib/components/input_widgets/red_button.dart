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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).splashColor,
            borderRadius: BorderRadius.circular(17.5)),
        child: Center(
          child:
              Text(buttonText, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}
