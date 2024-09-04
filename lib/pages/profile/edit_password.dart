// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';
import 'package:unigo/pages/startup/login.dart';
import 'package:unigo/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../components/input_widgets/red_button.dart';
import 'package:unigo/components/credential_screen/password_textfield.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPasswordScreen extends StatefulWidget {
  const EditPasswordScreen({super.key});

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final previouspassController = TextEditingController();
  final passwordController = TextEditingController();
  final passControllerVerify = TextEditingController();
  bool _isStrong = false;

  // ignore: unused_field
  String? _token = "";
  String? _idUser = "";
  String? _password = "";

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
  FirebaseAuth auth = FirebaseAuth.instance;

  bool passwordVisible = false;
  @override
  void initState() {
    super.initState();
    passwordVisible1 = true;
    passwordVisible2 = true;
    getUserInfo();
  }

  Future clearInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _idUser = prefs.getString('idUser');
      _password = prefs.getString('password');
    });
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

  @override
  Widget build(BuildContext context) {
    void editAccount() async {
      try {
        if ((previouspassController.text == '') ||
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
                'Revisa que los campos no esten vacíos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
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
                'The new password is not strong enough',
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
                'New password don\'t match',
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
        } else if (previouspassController.text != _password) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.amber,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: const Text(
                'Check that you have entered your current password correctly',
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
          final prefs = await SharedPreferences.getInstance();
          final String token = prefs.getString('token') ?? "";
          String path = 'http://${dotenv.env['API_URL']}/user/update/$_idUser';

          var response = await Dio().post(
            path,
            data: {
              "password": passwordController.text,
            },
            options: Options(
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            ),
          );

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
                  children: [
                    Expanded(
                      child: Text(
                        'Account successfully edited',
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
            auth.signOut();
            GoogleSignIn().signOut();
            FirebaseFirestore.instance.clearPersistence;
            clearInfo();
            Restart.restartApp();
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
              'Unable to edit the account. Try again later',
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 17.5, 15, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ),
                    Text(
                      "Editar contraseña",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleSmall?.color,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        size: 27.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                  child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      Column(
                        children: [
                          //Previous password textfield
                          PasswordTextField(
                              controller: previouspassController,
                              labelText:
                                  AppLocalizations.of(context)!.pass_label,
                              obscureText: false),

                          const SizedBox(height: 10),

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
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(17.5)),
                              ),
                              contentPadding: const EdgeInsets.all(17),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(17.5)),
                              ),
                              labelText: AppLocalizations.of(context)!.password,
                              labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 138, 138, 138),
                                fontSize: 14,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
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
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

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
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(17.5)),
                              ),
                              contentPadding: const EdgeInsets.all(17),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(17.5)),
                              ),
                              labelText:
                                  AppLocalizations.of(context)!.repeat_password,
                              labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 138, 138, 138),
                                fontSize: 14,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
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
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
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
                                        AppLocalizations.of(context)!
                                            .characters,
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
                    ]),
                  ),
                ),
              ),
              //Sign up button
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: RedButton(
                  buttonText: "EDITAR CONTRASEÑA",
                  onTap: editAccount,
                ),
              ),

              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 15),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text:
                            "Para aplicar los cambios, será necesario volver a iniciar sesión en UNIGO!",
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
