import 'package:flutter/material.dart';

class DeleteAccountButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;

  const DeleteAccountButton(
      {super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor, width: 0),
            color: Theme.of(context).splashColor,
            borderRadius: BorderRadius.circular(17.5)),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.delete_forever_rounded,
                    size: 20,
                    color: Theme.of(context).canvasColor,
                  ),
                  SizedBox(
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
