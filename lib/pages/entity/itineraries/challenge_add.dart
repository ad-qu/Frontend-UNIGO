import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:unigo/components/credential_screen/description_short_textfield.dart';
import 'package:unigo/components/credential_screen/question_textfield.dart';
import 'package:unigo/components/input_widgets/red_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/pages/entity/entity_home.dart';
import 'package:unigo/pages/entity/itineraries/challenge_location_picker.dart';
import 'package:unigo/components/credential_screen/input_textfield.dart';
import 'package:unigo/components/credential_screen/description_big_textfield.dart';

void main() async {
  await dotenv.load();
}

class ChallengeAdd extends StatefulWidget {
  final String idItinerary;
  const ChallengeAdd({
    super.key,
    required this.idItinerary,
  });

  @override
  State<ChallengeAdd> createState() => _ChallengeAddState();
}

class _ChallengeAddState extends State<ChallengeAdd> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  List<String> questionArray = List.filled(4, '');
  final questionController = TextEditingController();
  final List<TextEditingController> answerControllers = List.generate(
    3,
    (index) => TextEditingController(),
  );
  String selectedAnswer = '';
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

  void updateQuestionArray() {
    if (selectedAnswerIndex >= 0 &&
        selectedAnswerIndex < answerControllers.length) {
      setState(() {
        selectedAnswer = answerControllers[selectedAnswerIndex].text;
        questionArray[0] = questionController.text;
        questionArray[1] = answerControllers[0].text;
        questionArray[2] = answerControllers[1].text;
        questionArray[3] = answerControllers[2].text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future createChallenge() async {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? "";
      updateQuestionArray();
      try {
        // Navigator.pop(
        //   // ignore: use_build_context_synchronously
        //   context,
        //   PageTransition(
        //     type: PageTransitionType.topToBottom,
        //     child: const EntityScreen(),
        //   ),
        // );
        print(nameController.text);
        print(descriptionController.text);
        print(latitude);
        print(longitude);
        print(questionArray);
        print(selectedAnswer);
        print(widget.idItinerary);

        await Dio().post(
          'http://${dotenv.env['API_URL']}/challenge/add',
          data: {
            "name": nameController.text,
            "description": descriptionController.text,
            "latitude": latitude,
            "longitude": longitude,
            "question": questionArray,
            "answer": selectedAnswer,
            "itinerary": widget.idItinerary,
            "experience": 100,
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
                        //Nombre del reto
                        InputTextField(
                          controller: nameController,
                          labelText: "Nombre",
                          obscureText: false,
                        ),
                        const SizedBox(height: 15),

                        //Descripción del reto
                        DescriptionShortTextField(
                          controller: descriptionController,
                          labelText: "Descripción",
                          obscureText: false,
                        ),
                        const SizedBox(height: 35),

                        // Instrucciones sobre las respuestas
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

                        // Pregunta del reto
                        QuestionTextField(
                          controller: questionController,
                          labelText: "Pregunta",
                          obscureText: false,
                        ),
                        const SizedBox(height: 7),

                        // Respuestas del reto
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
                                      obscureText: false,
                                    ),
                                  ),
                                  Radio<int>(
                                    activeColor:
                                        Theme.of(context).secondaryHeaderColor,
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
                        const SizedBox(height: 25),

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

                        const SizedBox(height: 15),

                        // Mostrar el MiniMap solo si las coordenadas son válidas
                        if (latitude.isNotEmpty && longitude.isNotEmpty)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              MiniMap(
                                latitude: double.tryParse(latitude) ?? 0.0,
                                longitude: double.tryParse(longitude) ?? 0.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
                                          latitude =
                                              result['latitude'].toString();
                                          longitude =
                                              result['longitude'].toString();
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 10, 50),
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            12.5, 7.5, 12.5, 7.5),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              size: 20,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              "Editar",
                                              style: GoogleFonts.inter(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.color,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const ChallengeLocationPicker(),
                                ),
                              );

                              if (result != null) {
                                setState(() {
                                  latitude = result['latitude'].toString();
                                  longitude = result['longitude'].toString();
                                });
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const MiniMap(
                                  latitude: 41.27561,
                                  longitude: 1.98722,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(17),
                                  child: Container(
                                    height: 101,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(17),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.45),
                                          spreadRadius: 1,
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Icon(
                                            Icons.edit,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 30),
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
                    // Botón para crear el reto
                    RedButton(
                      buttonText: "CREAR",
                      onTap: createChallenge,
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

class MiniMap extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MiniMap({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  _MiniMapState createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> {
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant MiniMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      mapController.move(LatLng(widget.latitude, widget.longitude), 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width - 67.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: AbsorbPointer(
          absorbing: true,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.latitude, widget.longitude),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    height: 35,
                    width: 35,
                    point: LatLng(widget.latitude, widget.longitude),
                    child: Icon(
                      Icons.location_pin,
                      color: Theme.of(context).splashColor,
                      size: 35.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
