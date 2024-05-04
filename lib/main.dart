import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/entity_screens/chat_screen.dart';
import 'services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unigo/screens/navbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:unigo/screens/profile_screens/edit_info.dart';
import 'package:unigo/screens/profile_screens/edit_password.dart';
import 'package:unigo/screens/initial_screens/login_screen.dart';
import 'package:unigo/screens/initial_screens/signup_screen.dart';
import 'package:unigo/screens/initial_screens/splash_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  await Firebase.initializeApp(
    name: "Dev Project",
    options: DefaultFirebaseOptions.currentPlatform,
    
  );
  
  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint(fcmToken);
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  Future<Locale> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String language = prefs.getString("language") ?? "";
    return Locale(language);
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNIGO!',
      theme: ThemeData.light().copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color.fromARGB(255, 10, 10, 10),
        dividerColor: const Color.fromARGB(255, 37, 37, 37),
        buttonTheme: const ButtonThemeData(
            buttonColor: Color.fromARGB(255, 222, 66, 66),
            textTheme: ButtonTextTheme.primary),
        textTheme: const TextTheme(),
      ),
      darkTheme: ThemeData.dark().copyWith(
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
      ),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color.fromARGB(255, 227, 227, 227),
              selectionColor: Color.fromARGB(35, 227, 227, 227),
              selectionHandleColor: Color.fromARGB(255, 217, 59, 60),
            ),
          ),
          child: child!,
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('ca'),
      ],
      locale: _locale,
      home: const SplashScreen(),
    );
  }
}
