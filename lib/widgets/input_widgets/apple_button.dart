import 'package:flutter/material.dart';

class AppleButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;

  const AppleButton({super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(17.5)),
        child: Stack(
          children: [
            Image.asset('assets/images/apple_dark.png', height: 30),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
