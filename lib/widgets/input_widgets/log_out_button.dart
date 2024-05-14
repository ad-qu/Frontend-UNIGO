import 'package:flutter/material.dart';

class LogOutButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;

  const LogOutButton(
      {super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(17.5)),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  const SizedBox(
                    width: 17,
                  ),
                  Text(
                    buttonText,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
