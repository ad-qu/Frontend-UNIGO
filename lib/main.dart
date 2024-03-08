import 'package:flutter/material.dart';
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
    statusBarColor: Color.fromARGB(255, 15, 15, 15),
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNIGO!',
      theme: ThemeData.light().copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color.fromARGB(255, 10, 10, 10),
        backgroundColor: Color.fromARGB(255, 235, 235, 235),
        dividerColor: Color.fromARGB(255, 37, 37, 37),
        buttonTheme: ButtonThemeData(
            buttonColor: Color.fromARGB(255, 222, 66, 66),
            textTheme: ButtonTextTheme.primary),
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Color.fromARGB(255, 25, 25, 25),
          ),
          bodyText2: TextStyle(
            color: Color.fromARGB(255, 25, 25, 25),
          ),
          headline1: TextStyle(
            color: Color.fromARGB(255, 217, 217, 217),
          ),
          headline2: TextStyle(
            color: Color.fromARGB(255, 222, 66, 66),
          ),
          headline3: TextStyle(
            color: Color.fromARGB(255, 226, 226, 226),
          ),
          headline4: TextStyle(
            color: Color.fromARGB(255, 222, 66, 66),
          ),
          headline5: TextStyle(
            color: Colors.white,
          ),
          headline6: TextStyle(
            color: Color.fromARGB(255, 222, 66, 66),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color.fromARGB(255, 15, 15, 15),
        backgroundColor: Color.fromARGB(255, 15, 15, 15),
        dividerColor: Color.fromARGB(255, 242, 242, 242),
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Color.fromARGB(255, 242, 242, 242),
          ),
          bodyText2: TextStyle(
            color: Color.fromARGB(255, 25, 25, 25),
          ),
          headline1: TextStyle(
            color: Color.fromARGB(255, 242, 242, 242),
          ),
          headline2: TextStyle(
            color: Color.fromARGB(255, 222, 66, 66),
          ),
          headline3: TextStyle(
            color: Color.fromARGB(255, 242, 242, 242),
          ),
          headline4: TextStyle(
            color: Color.fromARGB(255, 252, 197, 31),
          ),
          headline5: TextStyle(
            color: Color.fromARGB(255, 25, 25, 25),
          ),
          headline6: TextStyle(
            color: Colors.red,
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
      home: const SplashScreen(),
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
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/register_screen':
            return MaterialPageRoute(
                builder: (context) => const SignupScreen());

          case '/navbar':
            return MaterialPageRoute(builder: (context) => const NavBar());
          case '/chat':
            return MaterialPageRoute(builder: (context) => const ChatWidget());

          case '/edit_account':
            return MaterialPageRoute(
                builder: (context) => const EditInfoScreen());

          case '/edit_password':
            return MaterialPageRoute(
                builder: (context) => const EditPasswordScreen());

          default:
            return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
      },
    );
  }
}
