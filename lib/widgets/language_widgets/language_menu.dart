// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/main.dart';

class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("language", "en");
            MyApp.setLocale(context, const Locale('en', ''));
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
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("language", "es");
            MyApp.setLocale(context, const Locale('es', ''));
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
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("language", "ca");
            MyApp.setLocale(context, const Locale('ca', ''));
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
