import 'package:flutter/material.dart';

class LanguageMenu extends StatelessWidget {
  final ValueNotifier<String> selectedLanguage;

  const LanguageMenu({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            selectedLanguage.value = 'ENG';
            Navigator.pop(context);
          },
          child: Container(
            height: 39,
            color: const Color.fromARGB(255, 14, 14, 14),
            child: const Center(
              child: Text(
                'English',
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 227, 227, 227),
                ),
              ),
            ),
          ),
        ),
        const Divider(color: Color.fromARGB(50, 227, 227, 227), height: 1),
        GestureDetector(
          onTap: () {
            selectedLanguage.value = 'ESP';
            Navigator.pop(context);
          },
          child: Container(
            height: 40,
            color: const Color.fromARGB(255, 41, 41, 41),
            child: const Center(
              child: Text(
                'Español',
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 227, 227, 227),
                ),
              ),
            ),
          ),
        ),
        const Divider(color: Color.fromARGB(50, 227, 227, 227), height: 1),
        GestureDetector(
          onTap: () {
            selectedLanguage.value = 'CAT';
            Navigator.pop(context);
          },
          child: Container(
            height: 40,
            color: const Color.fromARGB(255, 14, 14, 14),
            child: const Center(
              child: Text(
                'Català',
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 227, 227, 227),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
