import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color.fromARGB(255, 10, 10, 10),
  dividerColor: const Color.fromARGB(255, 37, 37, 37),
  buttonTheme: const ButtonThemeData(
      buttonColor: Color.fromARGB(255, 222, 66, 66),
      textTheme: ButtonTextTheme.primary),
  textTheme: const TextTheme(),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color.fromARGB(255, 227, 227, 227),
    selectionColor: Color.fromARGB(35, 227, 227, 227),
    selectionHandleColor: Color.fromARGB(255, 217, 59, 60),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color.fromARGB(255, 20, 20, 20),
  secondaryHeaderColor: const Color.fromARGB(255, 227, 227, 227),
  splashColor: const Color.fromARGB(255, 204, 49, 49),
  hoverColor: const Color.fromARGB(25, 217, 59, 60),
  dividerColor: const Color.fromARGB(255, 30, 30, 30),
  cardColor: const Color.fromARGB(255, 23, 23, 23),
  textTheme: TextTheme(
    //Welcome slogan
    titleLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w900,
      color: const Color.fromARGB(255, 227, 227, 227),
    ),
    //Welcome description
    titleMedium: GoogleFonts.inter(
      fontSize: 14,
      color: const Color.fromARGB(255, 175, 175, 175),
    ),
    //Tittle entities card
    titleSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: const Color.fromARGB(255, 227, 227, 227),
    ),
    bodyLarge: GoogleFonts.inter(
      color: const Color.fromARGB(255, 227, 227, 227),
    ),
    bodyMedium: GoogleFonts.inter(
      color: const Color.fromARGB(255, 227, 227, 227),
    ),
    bodySmall: GoogleFonts.inter(
      color: const Color.fromARGB(255, 138, 138, 138),
    ),
    //Text bold
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 227, 227, 227),
    ),
    //Text normal
    labelMedium: GoogleFonts.inter(
      fontSize: 14,
      color: const Color.fromARGB(255, 227, 227, 227),
    ),
    //Text thin
    labelSmall: GoogleFonts.inter(
      color: const Color.fromARGB(255, 227, 227, 227),
    ),
    //Red text bold
    displayLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 204, 49, 49),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color.fromARGB(255, 227, 227, 227),
    selectionColor: Color.fromARGB(35, 227, 227, 227),
    selectionHandleColor: Color.fromARGB(255, 217, 59, 60),
  ),
);
