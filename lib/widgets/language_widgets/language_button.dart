import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:popover/popover.dart';
import 'package:unigo/widgets/language_widgets/language_menu.dart';

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
          SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Color.fromARGB(255, 7, 7, 7),
          ));
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
            backgroundColor: Color.fromARGB(255, 14, 14, 14),
            onPop: () {
              // Restaurar el color de la barra de estado cuando se cierra el popover
              SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                statusBarColor: Color.fromARGB(255, 15, 15,
                    15), // Cambiar al color predeterminado cuando se cierra el popover
              ));
            },
          );
        },
      ),
    );
  }
}
