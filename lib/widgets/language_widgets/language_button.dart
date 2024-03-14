import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popover/popover.dart';
import 'package:unigo/widgets/language_widgets/language_menu.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        child: const Row(
          children: [
            Icon(
              Icons.language,
              color: Color.fromARGB(255, 227, 227, 227),
            ),
          ],
        ),
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) => const LanguageMenu(),
            width: 100,
            height: 122,
            direction: PopoverDirection.bottom,
            contentDyOffset: 5,
            arrowHeight: 10,
            arrowWidth: 15,
            arrowDxOffset: 0,
            radius: 20,
            backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          );
        },
      ),
    );
  }
}
