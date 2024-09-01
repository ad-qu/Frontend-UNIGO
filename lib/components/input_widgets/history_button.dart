import 'package:flutter/material.dart';

class HistoryButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;

  const HistoryButton(
      {super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(55, 56, 142, 60), width: 1),
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
                    Icons.manage_search_rounded,
                    color: Theme.of(context).secondaryHeaderColor,
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
