import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:unigo/screens/initial_screens/login_screen.dart';
import 'package:unigo/screens/initial_screens/signup_screen.dart';
import 'package:unigo/widgets/credential_screen/background.dart';
import 'package:unigo/widgets/input_widgets/apple_button.dart';
import 'package:unigo/widgets/input_widgets/google_button%20copy.dart';
import 'package:unigo/widgets/input_widgets/red_button.dart';
import 'package:unigo/widgets/language_widgets/language_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ValueNotifier<String> selectedLanguage = ValueNotifier<String>('ENG');
  int _emojiIndex = 0;
  final List<String> _emojis = ['🧭', '🤝', '📚', '🗺️', '👨‍🏫'];

  @override
  void initState() {
    super.initState();
    _updateEmoji();
  }

  void _updateEmoji() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _emojiIndex = (_emojiIndex + 1) % _emojis.length;
      });
      _updateEmoji();
    });
  }

  void logIn() async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: const LoginScreen()));
  }

  void signUp() async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: const SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 25, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('v0.0.1',
                        style: Theme.of(context).textTheme.labelMedium),
                    LanguageButton(selectedLanguage: selectedLanguage),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 60, 65),
                        child: Image.asset(
                          'assets/images/welcome.png',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 25),
                        child: Text(
                            '${AppLocalizations.of(context)!.slogan}  ${_emojis[_emojiIndex]}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Text(AppLocalizations.of(context)!.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ],
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
                    GoogleButton(
                      buttonText: "Continúa con Google",
                      onTap: logIn,
                    ),
                    const SizedBox(height: 10),
                    AppleButton(
                      buttonText: "Continúa con Apple",
                      onTap: logIn,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.have_account,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: const LoginScreen()));
                          },
                          child: Text(AppLocalizations.of(context)!.login2,
                              style: Theme.of(context).textTheme.displayLarge),
                        ),
                      ],
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
