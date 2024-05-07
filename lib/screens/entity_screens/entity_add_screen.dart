// ignore_for_file: use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/screens/initial_screens/terms_of_use_privacy_policy.dart';
import 'package:unigo/screens/initial_screens/welcome_screen.dart';
import 'package:unigo/widgets/credential_screen/description_textfield.dart';
import 'package:unigo/widgets/entity_screen/card_entity.dart';
import '../../widgets/input_widgets/red_button.dart';
import 'package:unigo/widgets/credential_screen/password_textfield.dart';
import 'package:unigo/widgets/credential_screen/input_textfield.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/widgets/language_widgets/language_button.dart';

void main() async {
  await dotenv.load();
}

class EntityAddScreen extends StatefulWidget {
  const EntityAddScreen({super.key});

  @override
  State<EntityAddScreen> createState() => _EntityAddScreenState();
}

class _EntityAddScreenState extends State<EntityAddScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String imageURL = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    signUp() {}
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: 1080,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 0, 0),
                        child: Center(
                          child: Text(
                            "Crear entidad",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleSmall?.color,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                          PageTransition(
                            type: PageTransitionType.topToBottom,
                            child: const WelcomeScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color.fromARGB(255, 227, 227, 227),
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        imageProfile(),
                        SizedBox(
                          height: 37.5,
                        ),
                        //Username textfield
                        InputTextField(
                            controller: nameController,
                            labelText: "Nombre",
                            obscureText: false),

                        const SizedBox(height: 15),

                        //Email address textfield
                        DescriptionTextField(
                            controller: descriptionController,
                            labelText: "Descripción",
                            obscureText: false),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                            child: Text(
                              style: GoogleFonts.inter(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                fontSize: 12,
                              ),
                              "0/250",
                            ),
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
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //Sign up button
                      RedButton(
                        buttonText: "CREAR",
                        onTap: signUp(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 30),
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
                            "Recuerda que la entidad que crees deberá cumplir los ",
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

  Widget imageProfile() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: imageURL != ""
              ? Image.network(imageURL).image
              : AssetImage('images/entity.png'),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.camera_enhance_rounded,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 175,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(0, 35, 0, 0),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 25, 25, 25),
      ),
      child: Column(
        children: [
          const Text(
            "Choose a profile photo",
            style: TextStyle(
                fontSize: 18, color: Color.fromARGB(255, 242, 242, 242)),
          ),
          const SizedBox(
            height: 35,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 222, 66, 66),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: () {
                    pickImageFromGallery(ImageSource.camera);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 22.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 35,
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 222, 66, 66),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: () {
                    pickImageFromGallery(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 22.0,
                      semanticLabel: "Gallery",
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> pickImageFromGallery(ImageSource source) async {
    try {
      final _storage = FirebaseStorage.instance;
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(source: source);
      if (pickedImage != null) {
        var file = File(pickedImage.path);
        var snapshot = await _storage
            .ref()
            .child('${nameController}/profilePic')
            .putFile(file);
        var downloadURL = await snapshot.ref.getDownloadURL();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('imageURL', downloadURL);
        final String token = prefs.getString('token') ?? "";
        String path =
            'http://${dotenv.env['API_URL']}/user/update/$downloadURL'; //HAY QUE CAMBIAR LA RUTA
        var response = await Dio().post(path,
            data: {"imageURL": downloadURL},
            options: Options(
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            ));
        print(response);
        if (mounted) {
          setState(() {
            imageURL = downloadURL;
          });
        }
        print(downloadURL);
      }
    } on PlatformException catch (e) {
      print('Failed to pick the image: $e');
    }
  }
}
