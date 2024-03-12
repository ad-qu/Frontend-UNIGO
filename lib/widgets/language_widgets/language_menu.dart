import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            color: const Color.fromARGB(255, 20, 20, 20),
            child: Center(
              child: Text(
                'English',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color.fromARGB(255, 227, 227, 227),
                ),
              ),
            ),
          ),
        ),
        const Divider(color: Color.fromARGB(255, 35, 35, 35), height: 1),
        GestureDetector(
          onTap: () {
            selectedLanguage.value = 'ESP';
            Navigator.pop(context);
          },
          child: Container(
            height: 40,
            color: const Color.fromARGB(255, 30, 30, 30),
            child: Center(
              child: Text(
                'Español',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color.fromARGB(255, 227, 227, 227),
                ),
              ),
            ),
          ),
        ),
        const Divider(color: Color.fromARGB(255, 35, 35, 35), height: 1),
        GestureDetector(
          onTap: () {
            selectedLanguage.value = 'CAT';
            Navigator.pop(context);
          },
          child: Container(
            height: 40,
            color: const Color.fromARGB(255, 20, 20, 20),
            child: Center(
              child: Text(
                'Català',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color.fromARGB(255, 227, 227, 227),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
