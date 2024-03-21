// ignore_for_file: use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unigo/screens/initial_screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/screens/initial_screens/welcome_screen.dart';
import '../../widgets/input_widgets/red_button.dart';
import 'package:unigo/widgets/credential_screen/password_textfield.dart';
import 'package:unigo/widgets/credential_screen/input_textfield.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/widgets/language_widgets/language_button.dart';

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
  final textController = TextEditingController();
  bool _isChecked = false;
  bool _isStrong = false;

  double strength = 0;
  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Aa-z].*");
  late String password;
  String text = "";
  Color colorPasswordIndicator = Colors.black;

  bool passwordVisible = false;
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  final ValueNotifier<String> selectedLanguage = ValueNotifier<String>('ENG');

  Widget buildRichTextWithEllipsis(BuildContext context) {
    String termsText = AppLocalizations.of(context)!.terms;

    if (termsText.length > 27) {
      termsText = termsText.substring(0, 27) + '...';
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: termsText,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1?.color,
              fontSize: 14,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Sign up method
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
              backgroundColor: const Color.fromARGB(255, 222, 66, 66),
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: const Text(
                'Check that there are no empty fields',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (!EmailValidator.validate(emailController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.amber,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: const Text(
                'Invalid email address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              closeIconColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (!_isStrong) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.amber,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: const Text(
                'The password is not strong enough',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              closeIconColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (passControllerVerify.text != passwordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.amber,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: const Text(
                'Passwords don\'t match',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              closeIconColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (!_isChecked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.amber,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: const Text(
                'The terms of use and privacy policy must be accepted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              closeIconColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          var response = await Dio()
              .post("http://${dotenv.env['API_URL']}/auth/register", data: {
            "name": nameController.text,
            "surname": surnameController.text,
            "username": usernameController.text,
            "email": emailController.text,
            "password": passwordController.text,
          });
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      // ignore: prefer_const_constructors
                      child: Text(
                        'Account successfully created',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );

            Navigator.pushNamed(context, '/login_screen');
          } else if (response.statusCode == 220) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                showCloseIcon: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                content: const Text(
                  'Email address not available. Try another one',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (response.statusCode == 400) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                showCloseIcon: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                content: const Text(
                  'Check that there are valid values',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 222, 66, 66),
            showCloseIcon: true,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
            content: const Text(
              'Unable to create an account. Try again later',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    void checkPassword(String value) {
      password = value.trim();

      if (password.isEmpty) {
        setState(() {
          strength = 0;
          text = AppLocalizations.of(context)!.enterpass;
        });
      } else if (password.length < 4) {
        setState(() {
          strength = 1 / 5;
          colorPasswordIndicator = const Color.fromARGB(255, 222, 66, 66);
          text = AppLocalizations.of(context)!.shortpass;
        });
      } else if (password.length < 6) {
        setState(() {
          strength = 2 / 4;
          colorPasswordIndicator = Colors.orange;
          text = AppLocalizations.of(context)!.charpass;
        });
      } else {
        if (!letterReg.hasMatch(password) || !numReg.hasMatch(password)) {
          setState(() {
            strength = 3 / 4;
            colorPasswordIndicator = Colors.amber;
            text = AppLocalizations.of(context)!.numpass;
          });
        } else {
          setState(() {
            strength = 1;
            colorPasswordIndicator = Colors.green;
            text = AppLocalizations.of(context)!.greatpass;
            _isStrong = true;
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: 1080,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 25, 0),
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
                      child: const Icon(
                        Icons
                            .arrow_back_ios_rounded, // Replace with the desired icon
                        color: Color.fromARGB(255, 227, 227, 227),
                        size: 25,
                      ),
                    ),
                    const LanguageButton(),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/padkey.png',
                        height: 100,
                      ), // Espacio entre la imagen y el texto
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
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
                            labelText: AppLocalizations.of(context)!.surname,
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
                        labelText: AppLocalizations.of(context)!.email2,
                        obscureText: false),

                    const SizedBox(height: 15),

                    //Password textfield
                    TextField(
                      onChanged: (val) => checkPassword(val),
                      controller: passwordController,
                      obscureText: passwordVisible,
                      cursorWidth: 1,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 227, 227, 227),
                          fontSize: 14),
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: IconButton(
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color.fromARGB(255, 227, 227, 227),
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  passwordVisible = !passwordVisible;
                                },
                              );
                            },
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(17.5))),
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(17.5)),
                        ),
                        labelText: AppLocalizations.of(context)!.pass2,
                        labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 138, 138, 138),
                            fontSize: 14),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Theme.of(context).cardColor,
                        filled: true,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        //borderRadius: BorderRadius.circular(  10.0), // Establece el radio de los bordes
                        child: SizedBox(
                          height:
                              4.0, // Ajusta la altura del indicador de progreso según sea necesario
                          child: LinearProgressIndicator(
                            value: strength,
                            backgroundColor: Color.fromARGB(225, 227, 227, 227),
                            color: colorPasswordIndicator,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    //Password textfield
                    PasswordTextField(
                        controller: passControllerVerify,
                        labelText: AppLocalizations.of(context)!.pass22,
                        obscureText: true),

                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            side: BorderSide(
                                color: Theme.of(context).dividerColor),
                            checkColor:
                                const Color.fromARGB(255, 242, 242, 242),
                            activeColor: const Color.fromARGB(255, 222, 66, 66),
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.i_accept,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1?.color,
                              fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      AppLocalizations.of(context)!.terms),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                ?.color,
                                          ),
                                          textAlign: TextAlign.justify,
                                          AppLocalizations.of(context)!
                                              .gigaterms,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ButtonStyle(
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
                                          (states) => const Color.fromARGB(
                                                  255, 222, 66, 66)
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.close,
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 222, 66, 66),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: buildRichTextWithEllipsis(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    //Sign up button
                    RedButton(
                      buttonText: AppLocalizations.of(context)!.signup,
                      onTap: signUp,
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(7.5, 0, 7.5, 0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'By clicking "LOG IN", you agree that UNIGO! may retain some information you provide, and to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Use',
                              style: GoogleFonts.inter(
                                  color: const Color.fromARGB(255, 204, 49,
                                      49)), // Cambia el color a rojo
                            ),
                            const TextSpan(
                              text: ' and ',
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: GoogleFonts.inter(
                                  color: const Color.fromARGB(255, 204, 49,
                                      49)), // Cambia el color a rojo
                            ),
                            const TextSpan(
                              text: '.',
                            ),
                          ],
                        ),
                      ),
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
