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
import 'package:unigo/pages/entity/itineraries/challenge_location_picker.dart';
import 'package:unigo/pages/startup/welcome.dart';
import 'package:unigo/components/credential_screen/input_textfield.dart';
import 'package:unigo/components/credential_screen/description_textfield.dart';

void main() async {
  await dotenv.load();
}

class ChallengeAdd extends StatefulWidget {
  final String idEntity;
  const ChallengeAdd({
    super.key,
    required this.idEntity,
  });

  @override
  State<ChallengeAdd> createState() => _ChallengeAddState();
}

class _ChallengeAddState extends State<ChallengeAdd> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final questionController = TextEditingController();
  final List<TextEditingController> answerControllers = List.generate(
    3,
    (index) => TextEditingController(),
  );
  int selectedAnswerIndex = -1;

  String longitude = "";
  String latitude = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future createEntity() async {
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
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 0, 0),
                        child: Center(
                          child: Text(
                            "Crear reto",
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
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "Recuerda que habrán 3 posibles respuestas.\nSolo una será la correcta.",
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        InputTextField(
                            controller: questionController,
                            labelText: "Pregunta",
                            obscureText: false),
                        const SizedBox(height: 15),
                        Column(
                          children: List.generate(3, (index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InputTextField(
                                        controller: answerControllers[index],
                                        labelText: "Respuesta ${index + 1}",
                                        obscureText: false),
                                  ),
                                  Radio<int>(
                                    value: index,
                                    groupValue: selectedAnswerIndex,
                                    onChanged: (int? value) {
                                      setState(() {
                                        selectedAnswerIndex = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "A continuación, deberá seleccionar la ubicación del reto en el mapa.",
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChallengeLocationPicker(),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                latitude = result['latitude'].toString();
                                longitude = result['longitude'].toString();
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.map_outlined,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text("Latitud: $latitude"),
                        Text("Longitud: $longitude"),
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
                            "Recuerda que el reto que crees deberá cumplir los ",
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
