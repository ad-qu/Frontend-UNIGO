import 'package:popover/popover.dart';
import 'package:flutter/material.dart';
import 'package:unigo/components/language/language_menu.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) => const LanguageMenu(),
            width: 100,
            height: 122,
            direction: PopoverDirection.bottom,
            contentDyOffset: -7.5,
            arrowHeight: 10,
            arrowWidth: 15,
            arrowDxOffset: 0,
            radius: 20,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30)),
          child: Icon(
            Icons.language,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
      ),
    );
  }
}
