// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:unigo/components/credential_screen/input_big_textfield.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:unigo/pages/navbar.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unigo/pages/startup/welcome.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/components/input_widgets/red_button.dart';
import 'package:unigo/components/language/language_button.dart';
import 'package:unigo/components/credential_screen/password_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final passwordController = TextEditingController();
    final emailController = TextEditingController();

    void logIn() async {
      if ((emailController.text != '') && (passwordController.text != '')) {
        try {
          var response = await Dio().post(
            'http://${dotenv.env['API_URL']}/auth/logIn',
            data: {
              "email": emailController.text,
              "password": passwordController.text
            },
          );

          print(response.data);

          if (response.statusCode == 222) {
            Map<String, dynamic> data = response.data;
            final token = data['token'];
            final idUser = data['_id'];
            final name = data['name'];
            final surname = data['surname'];
            final username = data['username'];
            final imageURL = data['imageURL'];
            final campus = data['campus'];
            final latitude = data['latitude'];
            final longitude = data['longitude'];
            final level = data['level'];
            final experience = data['experience'];

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setString('token', token);
            prefs.setString('idUser', idUser);
            prefs.setString('name', name);
            prefs.setString('surname', surname);
            prefs.setString('username', username);
            prefs.setString('email', emailController.text);
            prefs.setString('password', passwordController.text);
            prefs.setString('campus', campus ?? '');
            prefs.setString('latitude', latitude ?? '');
            prefs.setString('longitude', longitude ?? '');
            prefs.setString('imageURL', imageURL ?? '');
            prefs.setInt('level', level);
            prefs.setInt('experience', experience);

            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const NavBar(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).splashColor,
                showCloseIcon: true,
                closeIconColor: Theme.of(context).secondaryHeaderColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.5)),
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 45),
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                  child: Text(
                    "Parece que ocurrió un error",
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
        } on DioException catch (e) {
          if (e.response != null) {
            switch (e.response!.statusCode) {
              case 401:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).splashColor,
                    showCloseIcon: true,
                    closeIconColor: Theme.of(context).secondaryHeaderColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17.5)),
                    margin: const EdgeInsets.fromLTRB(30, 0, 30, 45),
                    content: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      child: Text(
                        "Verifica tus credenciales",
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
                break;
              case 404:
                print('Error 404: Recurso no encontrado.');
                break;
              case 423:
                print('Usuario inabilidado.');
                break;
              case 500:
                print('Error 500: Error en el servidor.');
                break;
              default:
                print('Error inesperado: ${e.response!.statusCode}');
                break;
            }
          } else {
            // Error sin respuesta del servidor
            print('Error sin respuesta del servidor: ${e.message}');
          }
        } catch (e) {
          // Otros errores que no son de Dio
          print('Ocurrió un error inesperado: $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).splashColor,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).secondaryHeaderColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.5)),
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 45),
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
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 1080,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                            PageTransition(
                              type: PageTransitionType.leftToRight,
                              child: const WelcomeScreen(),
                            ),
                          );
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
                        AppLocalizations.of(context)!.login_banner,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 17.5, 30, 0),
                  child: Column(
                    children: [
                      // Email address textfield
                      InputBigTextField(
                        controller: emailController,
                        labelText: AppLocalizations.of(context)!.email,
                        obscureText: false,
                      ),

                      const SizedBox(height: 15),

                      // Password textfield
                      PasswordTextField(
                        controller: passwordController,
                        labelText: AppLocalizations.of(context)!.password,
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RedButton(
                          buttonText:
                              AppLocalizations.of(context)!.login_button,
                          onTap: logIn,
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!.faster1,
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.faster2,
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.color,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.faster3,
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 12,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
