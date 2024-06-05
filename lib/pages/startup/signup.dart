// ignore_for_file: use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unigo/pages/startup/login.dart';
import '../../components/input_widgets/red_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/pages/startup/welcome.dart';
import 'package:unigo/components/language_widgets/language_button.dart';
import 'package:unigo/components/credential_screen/input_textfield.dart';
import 'package:unigo/pages/startup/terms_of_use_privacy_policy.dart';

void main() async {
  await dotenv.load();
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passControllerVerify = TextEditingController();

  double strength = 0;
  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Aa-z].*");
  late String password;
  String text = "";
  Color colorPasswordIndicator = Colors.black;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;
  bool passwordVisible1 = false;
  bool passwordVisible2 = false;

  bool _bothPasswordMatch = false;

  @override
  void initState() {
    super.initState();
    passwordVisible1 = true;
    passwordVisible2 = true;
  }

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void signUp() async {
      try {
        if ((nameController.text == '') ||
            (surnameController.text == '') ||
            (usernameController.text == '') ||
            (emailController.text == '') ||
            (passwordController.text == '') ||
            (passControllerVerify.text == '')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).splashColor,
              showCloseIcon: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.5)),
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 19.25),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                child: Text(
                  AppLocalizations.of(context)!.empty_fields,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (!EmailValidator.validate(emailController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 196, 150, 11),
              showCloseIcon: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.5)),
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 19.25),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                child: Text(
                  AppLocalizations.of(context)!.invalid_email,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (!_isPasswordEightCharacters ||
            !_hasPasswordOneNumber ||
            !_bothPasswordMatch) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 196, 150, 11),
              showCloseIcon: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.5)),
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 19.25),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                child: Text(
                  AppLocalizations.of(context)!.password_rules,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          var response = await Dio().post(
            "http://${dotenv.env['API_URL']}/auth/register",
            data: {
              "name": nameController.text,
              "surname": surnameController.text,
              "username": usernameController.text,
              "email": emailController.text,
              "password": passwordController.text,
            },
          );
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color.fromARGB(255, 56, 142, 60),
                showCloseIcon: false,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.5)),
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 12),
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                  child: Text(
                    AppLocalizations.of(context)!.account_created,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );

            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const LoginScreen(),
              ),
            );
          } else if (response.statusCode == 220) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).splashColor,
                showCloseIcon: false,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.5)),
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 19.25),
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                  child: Text(
                    AppLocalizations.of(context)!.used_email,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (response.statusCode == 400) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).splashColor,
                showCloseIcon: false,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.5)),
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 19.25),
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                  child: Text(
                    AppLocalizations.of(context)!.valid_values,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).splashColor,
            showCloseIcon: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.5)),
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 19.25),
            content: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
              child: Text(
                AppLocalizations.of(context)!.unable_to_proceed,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    onPasswordChangedConditions(String password) {
      final numericRegex = RegExp(r'[0-9]');
      setState(() {
        _isPasswordEightCharacters = false;
        if (password.length >= 8) _isPasswordEightCharacters = true;

        _hasPasswordOneNumber = false;
        if (numericRegex.hasMatch(password)) _hasPasswordOneNumber = true;
        _bothPasswordMatch = false;
        if (((passControllerVerify.text != '') &&
            (passwordController.text == passControllerVerify.text))) {
          _bothPasswordMatch = true;
        }
      });
    }

    onPasswordChangedMatch(String password) {
      setState(() {
        _bothPasswordMatch = false;
        if (((passControllerVerify.text != '') &&
            (passwordController.text == passControllerVerify.text))) {
          _bothPasswordMatch = true;
        }
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: 1080,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                child: const WelcomeScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30)),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Color.fromARGB(255, 227, 227, 227),
                          size: 25,
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.signup_banner,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleSmall?.color,
                        fontSize: 16,
                      ),
                    ),
                    const LanguageButton(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //Name textfield
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: InputTextField(
                                controller: nameController,
                                labelText: AppLocalizations.of(context)!.name,
                                obscureText: false,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Flexible(
                              child: InputTextField(
                                controller: surnameController,
                                labelText:
                                    AppLocalizations.of(context)!.surname,
                                obscureText: false,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        //Username textfield
                        InputTextField(
                            controller: usernameController,
                            labelText: AppLocalizations.of(context)!.username,
                            obscureText: false),

                        const SizedBox(height: 15),

                        //Email address textfield
                        InputTextField(
                            controller: emailController,
                            labelText: AppLocalizations.of(context)!.email,
                            obscureText: false),

                        const SizedBox(height: 15),

                        //Password textfield
                        TextField(
                          onChanged: (password) =>
                              onPasswordChangedConditions(password),
                          controller: passwordController,
                          obscureText: passwordVisible1,
                          cursorWidth: 1,
                          style: Theme.of(context).textTheme.labelMedium,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(17.5)),
                            ),
                            contentPadding: const EdgeInsets.all(17),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(17.5)),
                            ),
                            labelText: AppLocalizations.of(context)!.password,
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 138, 138, 138),
                              fontSize: 14,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            fillColor: Theme.of(context).cardColor,
                            filled: true,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    passwordVisible1 = !passwordVisible1;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.transparent,
                                  ),
                                  child: Icon(
                                    passwordVisible1
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        //Password textfield
                        TextField(
                          onChanged: (password) =>
                              onPasswordChangedMatch(password),
                          controller: passControllerVerify,
                          obscureText: passwordVisible2,
                          cursorWidth: 1,
                          style: Theme.of(context).textTheme.labelMedium,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(17.5)),
                            ),
                            contentPadding: const EdgeInsets.all(17),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(17.5)),
                            ),
                            labelText:
                                AppLocalizations.of(context)!.repeat_password,
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 138, 138, 138),
                              fontSize: 14,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            fillColor: Theme.of(context).cardColor,
                            filled: true,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    passwordVisible2 = !passwordVisible2;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.transparent,
                                  ),
                                  child: Icon(
                                    passwordVisible2
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (passwordController.text != "")
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: _isPasswordEightCharacters
                                              ? const Color.fromARGB(
                                                  255, 51, 151, 67)
                                              : Colors.transparent,
                                          border: _isPasswordEightCharacters
                                              ? Border.all(
                                                  color: Colors.transparent)
                                              : Border.all(
                                                  color: const Color.fromARGB(
                                                      255, 138, 138, 138)),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Center(
                                        child: Icon(
                                          Icons.check,
                                          color: _isPasswordEightCharacters
                                              ? const Color.fromARGB(
                                                  255, 227, 227, 227)
                                              : const Color.fromARGB(
                                                  255, 138, 138, 138),
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.characters,
                                      style: GoogleFonts.inter(
                                          color: _isPasswordEightCharacters
                                              ? const Color.fromARGB(
                                                  255, 227, 227, 227)
                                              : const Color.fromARGB(
                                                  255, 138, 138, 138)),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: _hasPasswordOneNumber
                                              ? const Color.fromARGB(
                                                  255, 51, 151, 67)
                                              : Colors.transparent,
                                          border: _hasPasswordOneNumber
                                              ? Border.all(
                                                  color: Colors.transparent)
                                              : Border.all(
                                                  color: const Color.fromARGB(
                                                      255, 138, 138, 138)),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Center(
                                        child: Icon(
                                          Icons.check,
                                          color: _hasPasswordOneNumber
                                              ? const Color.fromARGB(
                                                  255, 227, 227, 227)
                                              : const Color.fromARGB(
                                                  255, 138, 138, 138),
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.number,
                                      style: GoogleFonts.inter(
                                          color: _hasPasswordOneNumber
                                              ? const Color.fromARGB(
                                                  255, 227, 227, 227)
                                              : const Color.fromARGB(
                                                  255, 138, 138, 138)),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: _bothPasswordMatch
                                              ? const Color.fromARGB(
                                                  255, 51, 151, 67)
                                              : Colors.transparent,
                                          border: _bothPasswordMatch
                                              ? Border.all(
                                                  color: Colors.transparent)
                                              : Border.all(
                                                  color: const Color.fromARGB(
                                                      255, 138, 138, 138)),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Center(
                                        child: Icon(
                                          Icons.check,
                                          color: _bothPasswordMatch
                                              ? const Color.fromARGB(
                                                  255, 227, 227, 227)
                                              : const Color.fromARGB(
                                                  255, 138, 138, 138),
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppLocalizations.of(context)!.match,
                                      style: GoogleFonts.inter(
                                          color: _bothPasswordMatch
                                              ? const Color.fromARGB(
                                                  255, 227, 227, 227)
                                              : const Color.fromARGB(
                                                  255, 138, 138, 138)),
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
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.bottomToTop,
                      child: const TermsScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //Sign up button
                      RedButton(
                        buttonText: AppLocalizations.of(context)!.signup_button,
                        onTap: signUp,
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    AppLocalizations.of(context)!.explanation1,
                              ),
                              TextSpan(
                                text:
                                    AppLocalizations.of(context)!.explanation2,
                                style: GoogleFonts.inter(
                                    color: const Color.fromARGB(255, 204, 49,
                                        49)), // Cambia el color a rojo
                              ),
                              TextSpan(
                                text:
                                    AppLocalizations.of(context)!.explanation3,
                              ),
                              TextSpan(
                                text:
                                    AppLocalizations.of(context)!.explanation4,
                                style: GoogleFonts.inter(
                                    color: const Color.fromARGB(255, 204, 49,
                                        49)), // Cambia el color a rojo
                              ),
                              TextSpan(
                                text:
                                    AppLocalizations.of(context)!.explanation5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
