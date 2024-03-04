import 'package:unigo/screens/initial_screens/login_screen.dart';
import 'package:unigo/screens/initial_screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:unigo/widgets/input_widgets/grey_button.dart';
import 'package:unigo/widgets/language_widgets/language_button.dart';
import 'package:unigo/widgets/input_widgets/red_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ValueNotifier<String> selectedLanguage = ValueNotifier<String>('ENG');

  @override
  Widget build(BuildContext context) {
    void logIn() async {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const LoginScreen()));
    }

    void signUp() async {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft, child: SignupScreen()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
          content: const Text(
            'Tap back again to leave',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1000),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 25, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'v0.0.1',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 30, 30, 30),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    LanguageButton(selectedLanguage: selectedLanguage),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/welcome.png'),
                        const SizedBox(
                          height: 60,
                        ), // Espacio entre la imagen y el texto
                        Text(
                          AppLocalizations.of(context)!.welcome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 227, 227, 227),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: Column(
                  children: [
                    RedButton(
                      buttonText: AppLocalizations.of(context)!.get_stated,
                      onTap: signUp,
                    ),
                    const SizedBox(height: 10),
                    BlackButton(
                      buttonText: AppLocalizations.of(context)!.already_account,
                      onTap: logIn,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
