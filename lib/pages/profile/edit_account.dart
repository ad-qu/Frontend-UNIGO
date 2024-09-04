// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unigo/components/credential_screen/input_big_textfield.dart';

import 'package:unigo/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/input_widgets/red_button.dart';
import 'package:unigo/components/credential_screen/input_short_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  await dotenv.load();
}

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final usernameController = TextEditingController();
  final textController = TextEditingController();
  // ignore: prefer_final_fields, unused_field
  bool _isStrong = false;

  // ignore: unused_field
  String? _token = "";
  String? _idUser = "";
  String? _name = "";
  String? _surname = "";
  String? _username = "";

  @override
  void initState() {
    super.initState();

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
      _name = prefs.getString('name');
      _surname = prefs.getString('surname');
      _username = prefs.getString('username');
    });
  }

  void editAccount() async {
    try {
      if ((nameController.text == '') &&
          (surnameController.text == '') &&
          (usernameController.text == '')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 222, 66, 66),
            showCloseIcon: true,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
            content: const Text(
              'All fields are empty',
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
        String namePlaceHolder, surnamePlaceHolder, usernamePlaceHolder;
        if (nameController.text != '') {
          namePlaceHolder = nameController.text;
        } else {
          namePlaceHolder = _name ?? '';
        }
        if (surnameController.text != '') {
          surnamePlaceHolder = surnameController.text;
        } else {
          surnamePlaceHolder = _surname ?? '';
        }
        if (usernameController.text != '') {
          usernamePlaceHolder = usernameController.text;
        } else {
          usernamePlaceHolder = _username ?? '';
        }
        final prefs = await SharedPreferences.getInstance();
        final String token = prefs.getString('token') ?? "";
        String path = 'http://${dotenv.env['API_URL']}/user/update/$_idUser';

        var response = await Dio().post(
          path,
          data: {
            "name": namePlaceHolder,
            "surname": surnamePlaceHolder,
            "username": usernamePlaceHolder,
          },
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          ),
        );
        print(response);

        print(response.statusCode);
        if (response.statusCode == 200) {
          prefs.setString("name", namePlaceHolder);
          prefs.setString("username", usernamePlaceHolder);
          prefs.setString("surname", surnamePlaceHolder);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 56, 142, 60),
              showCloseIcon: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.5)),
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 45),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                child: Text(
                  AppLocalizations.of(context)!.edit_account,
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

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NavBar()),
            (Route<dynamic> route) =>
                false, // Elimina todas las rutas anteriores
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
      print(e);
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

  @override
  Widget build(BuildContext context) {
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
                      "Editar cuenta",
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
                    child: Column(children: [
                      InputBigTextField(
                          controller: nameController,
                          labelText: "Nombre: $_name",
                          obscureText: false),

                      const SizedBox(height: 10),

                      //Surname textfield
                      InputBigTextField(
                          controller: surnameController,
                          labelText: "Apellido: $_surname",
                          obscureText: false),

                      const SizedBox(height: 10),

                      //Username textfield
                      InputBigTextField(
                          controller: usernameController,
                          labelText: "Usuario: $_username",
                          obscureText: false),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: RedButton(
                  buttonText: "EDITAR CUENTA",
                  onTap: editAccount,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 15),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: "La cuenta que modifiques deberá cumplir los ",
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.explanation2,
                        style: GoogleFonts.inter(
                            color: const Color.fromARGB(
                                255, 204, 49, 49)), // Cambia el color a rojo
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.explanation3,
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.explanation4,
                        style: GoogleFonts.inter(
                            color: const Color.fromARGB(
                                255, 204, 49, 49)), // Cambia el color a rojo
                      ),
                      TextSpan(
                        text: " de UNIGO!",
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
