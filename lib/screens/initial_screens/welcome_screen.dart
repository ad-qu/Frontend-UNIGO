import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unigo/screens/initial_screens/login_screen.dart';
import 'package:unigo/screens/initial_screens/signup_screen.dart';
import 'package:unigo/services/auth_service.dart';
import 'package:unigo/widgets/credential_screen/animated_background.dart';
import 'package:unigo/widgets/input_widgets/apple_button.dart';
import 'package:unigo/widgets/input_widgets/google_button.dart';
import 'package:unigo/widgets/input_widgets/red_button.dart';
import 'package:unigo/widgets/language_widgets/language_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dotenv.env['VERSION']!,
                        style: Theme.of(context).textTheme.labelMedium),
                    const LanguageButton(),
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
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Column(
                  children: [
                    RedButton(
                      buttonText: AppLocalizations.of(context)!.get_stated,
                      onTap: signUp,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      child: GoogleButton(
                        buttonText: AppLocalizations.of(context)!.google_login,
                        onTap: () => AuthService().signInWithGoogle(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppleButton(
                      buttonText: AppLocalizations.of(context)!.apple_login,
                      onTap: logIn,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(55, 15, 55, 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const LoginScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(17.5)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.have_account,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!.login,
                              style: Theme.of(context).textTheme.displayLarge),
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
