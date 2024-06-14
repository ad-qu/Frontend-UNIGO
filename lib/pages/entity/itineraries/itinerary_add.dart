import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unigo/components/input_widgets/red_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/pages/entity/entity_home.dart';
import 'package:unigo/pages/startup/welcome.dart';
import 'package:unigo/components/credential_screen/input_short_textfield.dart';
import 'package:unigo/components/credential_screen/description_big_textfield.dart';

void main() async {
  await dotenv.load();
}

class ItineraryAdd extends StatefulWidget {
  final String idEntity;
  const ItineraryAdd({
    super.key,
    required this.idEntity,
  });

  @override
  State<ItineraryAdd> createState() => _ItineraryAddState();
}

class _ItineraryAddState extends State<ItineraryAdd> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String imageURL = "";
  File? _tempImageFile;

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickAnImage(ImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _tempImageFile = File(pickedImage.path);
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to pick the image: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future createEntity() async {
      if (_tempImageFile != null) {
        await uploadImageToFirebase();
      }
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? "";
      try {
        Navigator.pop(
          // ignore: use_build_context_synchronously
          context,
          PageTransition(
            type: PageTransitionType.topToBottom,
            child: const EntityScreen(),
          ),
        );
        await Dio().post(
          'http://${dotenv.env['API_URL']}/itinerary/add/${widget.idEntity}',
          data: {
            "name": nameController.text,
            "description": descriptionController.text,
            "imageURL": imageURL,
            "number": 0,
          },
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          ),
        );
      } catch (e) {
        // ignore: avoid_print
        print(e);
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
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 0, 0),
                        child: Center(
                          child: Text(
                            "Crear itinerario",
                            style: Theme.of(context).textTheme.titleSmall,
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
                            child: const EntityScreen(),
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
                        imageItinerary(),
                        const SizedBox(
                          height: 37.5,
                        ),
                        //Username textfield
                        InputShortTextField(
                            controller: nameController,
                            labelText: "Nombre",
                            obscureText: false),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //Sign up button
                    RedButton(
                      buttonText: "CREAR",
                      onTap: createEntity,
                    ),
                  ],
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
                            "Recuerda que el itinerario que crees deberá cumplir los ",
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

  Widget imageItinerary() {
    return Stack(
      children: [
        _tempImageFile != null
            ? CircleAvatar(
                radius: 40,
                backgroundImage: FileImage(_tempImageFile!),
              )
            : const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/itinerary.png'),
              ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
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
                  Icons.camera_alt,
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
      height: 215,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Column(
        children: [
          Text(
            "Choose an itinerary photo",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 45,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).splashColor,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    pickAnImage(ImageSource.camera);
                    //pickImageFromGallery(ImageSource.camera);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 40,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).splashColor,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    pickAnImage(ImageSource.gallery);

                    //pickImageFromGallery(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
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

  Future<void> uploadImageToFirebase() async {
    try {
      final storage = FirebaseStorage.instance;

      var snapshot = await storage
          .ref()
          .child('itineraries/${nameController.text}/picture')
          .putFile(_tempImageFile!);
      var downloadURL = await snapshot.ref.getDownloadURL();

      if (mounted) {
        setState(() {
          imageURL = downloadURL;
        });
      }
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Failed to pick the image: $e');
    }
  }
}
