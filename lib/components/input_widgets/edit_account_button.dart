import 'package:flutter/material.dart';

class EditAccountButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;

  const EditAccountButton(
      {super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(17.5)),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit,
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
