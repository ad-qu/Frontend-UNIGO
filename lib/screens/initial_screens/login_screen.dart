// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:unigo/screens/initial_screens/signup_screen.dart';
import 'package:unigo/screens/initial_screens/welcome_screen.dart';
import 'package:unigo/screens/navbar.dart';
import 'package:unigo/services/auth_service.dart';
import 'package:unigo/widgets/credential_screen/input_textfield.dart';
import 'package:unigo/widgets/input_widgets/red_button.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:unigo/widgets/credential_screen/password_textfield.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/widgets/language_widgets/language_button.dart';

void main() async {
  await dotenv.load();
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Text editing controllers
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    //Login with Google
    final ValueNotifier<String> selectedLanguage = ValueNotifier<String>('ENG');

    //Login method
    void logIn() async {
      if ((emailController.text != '') && (passwordController.text != '')) {
        try {
          var response = await Dio().post(
            'http://${dotenv.env['API_URL']}/auth/login',
            data: {
              "email": emailController.text,
              "password": passwordController.text
            },
          );
          if (response.statusCode == 200) {
            Map<String, dynamic> payload = Jwt.parseJwt(response.toString());
            User u = User.fromJson(payload);
            var data = json.decode(response.toString());
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setString('token', data['token']);
            prefs.setString('idUser', u.idUser);
            prefs.setString('name', u.name);
            prefs.setString('surname', u.surname);
            prefs.setString('username', u.username);
            prefs.setString('email', emailController.text);
            prefs.setString('password', passwordController.text);
            prefs.setString('imageURL', u.imageURL ?? '');
            try {
              // prefs.setInt('exp', u.exp!);
              prefs.setInt('level', u.level!);
              prefs.setInt('experience', u.experience!);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                  showCloseIcon: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                  content: Text(
                    'Error $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const NavBar()));
          } else if (response.statusCode == 220) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                showCloseIcon: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                content: const Text(
                  'Disabled account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (response.statusCode == 221) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                showCloseIcon: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                content: const Text(
                  'Account not found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (response.statusCode == 222) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                showCloseIcon: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                content: const Text(
                  'Wrong credentials. Try again with other values',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                showCloseIcon: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                content: const Text(
                  'Wrong credentials. Try again with other values',
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
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 222, 66, 66),
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: const Text(
                'Wrong credentials. Try again with other values',
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 222, 66, 66),
            showCloseIcon: true,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
            content: const Text(
              'Empty credentials. Please, try again',
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
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
                      LanguageButton(selectedLanguage: selectedLanguage),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset('assets/icon/logo.png', height: 95),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      // Email address textfield
                      InputTextField(
                        controller: emailController,
                        labelText: AppLocalizations.of(context)!.email,
                        obscureText: false,
                      ),

                      const SizedBox(height: 15),

                      // Password textfield
                      PasswordTextField(
                        controller: passwordController,
                        labelText: AppLocalizations.of(context)!.pass,
                        obscureText: true,
                      ),
                      const SizedBox(height: 12.5),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(12.5, 0, 0, 0),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.forgot_password,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.leftToRight,
                                        child: const LoginScreen()));
                              },
                              child: Text(
                                AppLocalizations.of(context)!.click_here,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      // Log in button
                      RedButton(
                        buttonText: AppLocalizations.of(context)!.login,
                        onTap: logIn,
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.dont_have_account,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1?.color,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: const SignupScreen()));
                            },
                            child: Text(
                              AppLocalizations.of(context)!.signin,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 222, 66, 66),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
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
    );
  }
}
