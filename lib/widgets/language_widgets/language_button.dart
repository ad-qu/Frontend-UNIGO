import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:ea_frontend/widgets/language_widgets/language_menu.dart';

class LanguageButton extends StatelessWidget {
  final ValueNotifier<String> selectedLanguage;

  const LanguageButton({Key? key, required this.selectedLanguage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        child: Row(
          children: [
            const Icon(
              Icons.language,
              color: Color.fromARGB(255, 227, 227, 227),
            ),
            const SizedBox(width: 7.5),
            SizedBox(
              width: 40,
              child: ValueListenableBuilder<String>(
                valueListenable: selectedLanguage,
                builder: (context, value, child) => Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 227, 227, 227),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) =>
                LanguageMenu(selectedLanguage: selectedLanguage),
            width: 100,
            height: 122,
            direction: PopoverDirection.bottom,
            contentDyOffset: 5,
            arrowHeight: 10,
            arrowWidth: 15,
            arrowDxOffset: 15,
            radius: 20,
            backgroundColor: const Color.fromARGB(255, 25, 25, 25),
          );
        },
      ),
    );
  }
}
