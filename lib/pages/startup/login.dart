import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/components/snackbar/snackbar_provider.dart';

import 'package:unigo/pages/navbar.dart';
import 'package:unigo/pages/startup/welcome.dart';
import 'package:unigo/components/input_widgets/red_button.dart';
import 'package:unigo/components/language/language_button.dart';
import 'package:unigo/components/credential_screen/password_textfield.dart';
import 'package:unigo/components/credential_screen/input_big_textfield.dart';

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
              // ignore: use_build_context_synchronously
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const NavBar(),
              ),
            );
          } else {
            SnackBarProvider().showErrorSnackBar(
                // ignore: use_build_context_synchronously
                context,
                // ignore: use_build_context_synchronously
                AppLocalizations.of(context)!.server_error,
                30,
                0,
                30,
                45);
          }
        } on DioException catch (e) {
          if (e.response != null) {
            switch (e.response!.statusCode) {
              case 401:
                SnackBarProvider().showErrorSnackBar(
                    context,
                    AppLocalizations.of(context)!.verify_credentials,
                    30,
                    0,
                    30,
                    45);
                break;
              case 404:
                SnackBarProvider().showErrorSnackBar(
                    context,
                    AppLocalizations.of(context)!.verify_credentials,
                    30,
                    0,
                    30,
                    45);
                break;
              case 423:
                SnackBarProvider().showErrorSnackBar(context,
                    AppLocalizations.of(context)!.disabled_user, 30, 0, 30, 45);
                break;
              case 500:
                SnackBarProvider().showErrorSnackBar(context,
                    AppLocalizations.of(context)!.server_error, 30, 0, 30, 45);
                break;
              default:
                SnackBarProvider().showErrorSnackBar(context,
                    AppLocalizations.of(context)!.server_error, 30, 0, 30, 45);
                break;
            }
          } else {
            SnackBarProvider().showErrorSnackBar(
                // ignore: use_build_context_synchronously
                context,
                // ignore: use_build_context_synchronously
                AppLocalizations.of(context)!.server_error,
                30,
                0,
                30,
                45);
          }
        } catch (e) {
          SnackBarProvider().showErrorSnackBar(
              // ignore: use_build_context_synchronously
              context,
              // ignore: use_build_context_synchronously
              AppLocalizations.of(context)!.server_error,
              30,
              0,
              30,
              45);
        }
      } else {
        SnackBarProvider().showErrorSnackBar(
            context, AppLocalizations.of(context)!.empty_fields, 30, 0, 30, 45);
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
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Theme.of(context).secondaryHeaderColor,
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
