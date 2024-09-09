import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:unigo/services/auth.dart';
import 'package:unigo/pages/startup/login.dart';
import 'package:unigo/pages/startup/signup.dart';
import 'package:unigo/components/input_widgets/red_button.dart';
import 'package:unigo/components/language/language_button.dart';
import 'package:unigo/components/input_widgets/google_button.dart';
import 'package:unigo/components/credential_screen/animated_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
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

  void _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });
    await AuthService().signInWithGoogle(context);
    setState(() {
      _isSigningIn = false;
    });
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
                        padding: const EdgeInsets.fromLTRB(35, 0, 35, 25),
                        child: Text(
                            '${AppLocalizations.of(context)!.slogan}  🧭',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
                        child: Text(AppLocalizations.of(context)!.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(35, 5, 35, 0),
                        child: Text(AppLocalizations.of(context)!.hype,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: Column(
                  children: [
                    RedButton(
                      buttonText: AppLocalizations.of(context)!.get_stated,
                      onTap: signUp,
                    ),
                    const SizedBox(height: 15),
                    Stack(
                      children: [
                        GoogleButton(
                          buttonText:
                              AppLocalizations.of(context)!.google_login,
                          onTap: _signInWithGoogle,
                        ),
                        if (_isSigningIn)
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: MediaQuery.of(context).size.width - 95,
                            child: Center(
                              child: SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  backgroundColor: Theme.of(context)
                                      .secondaryHeaderColor
                                      .withOpacity(0.5),
                                  strokeCap: StrokeCap.round,
                                  strokeWidth: 4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
                      ],
                    ),
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
