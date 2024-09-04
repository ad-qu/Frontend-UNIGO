import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:unigo/components/credential_screen/description_short_textfield.dart';
import 'package:unigo/components/credential_screen/input_big_textfield.dart';
import 'package:unigo/components/credential_screen/question_textfield.dart';
import 'package:unigo/components/input_widgets/red_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/pages/entity/entity_home.dart';
import 'package:unigo/pages/entity/itineraries/challenge_location_picker.dart';
import 'package:unigo/components/credential_screen/input_short_textfield.dart';
import 'package:unigo/components/credential_screen/description_big_textfield.dart';

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
  TextEditingController xpController = TextEditingController();

  List<String> questionArray = List.filled(4, '');
  final questionController = TextEditingController();
  final List<TextEditingController> answerControllers = List.generate(
    3,
    (index) => TextEditingController(),
  );
  String selectedAnswer = '';
  int selectedAnswerIndex = -1;
  bool showQuestionSection = false;
  bool showXPSection = false;
  String longitude = "";
  String latitude = "";
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    questionController.dispose();
    xpController.dispose();

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
      if (nameController.text == '' ||
          descriptionController.text == '' ||
          latitude == '' ||
          longitude == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).splashColor,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).secondaryHeaderColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.5)),
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
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
      } else {
        setState(() {
          _isUploading = true;
        });

        final prefs = await SharedPreferences.getInstance();
        final String token = prefs.getString('token') ?? "";
        updateQuestionArray();
        try {
          // ignore: use_build_context_synchronously

          print(nameController.text);
          print(descriptionController.text);
          print(latitude);
          print(longitude);
          print(questionArray);
          print(selectedAnswer);
          print(widget.idItinerary);
          if (xpController.text == '') {
            xpController.text = "0";
          }
          await Dio().post(
            'http://${dotenv.env['API_URL']}/challenge/add',
            data: {
              "name": nameController.text,
              "description": descriptionController.text,
              "latitude": latitude,
              "longitude": longitude,
              "question": questionArray,
              "answer": selectedAnswer,
              "experience": xpController.text,
              "itinerary": widget.idItinerary,
            },
            options: Options(
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            ),
          );
          Navigator.pop(context, true);
        } catch (e) {
          print(e);
        } finally {
          setState(() {
            _isUploading = false;
          });
        }
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
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 15),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Nombre del reto
                        InputBigTextField(
                          controller: nameController,
                          labelText: "Nombre",
                          obscureText: false,
                        ),
                        const SizedBox(height: 15),

                        // Descripción del reto
                        DescriptionBigTextField(
                          controller: descriptionController,
                          labelText: "Descripción",
                          obscureText: false,
                        ),
                        const SizedBox(height: 35),

                        // Interruptor para otorgar XP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "¿Desea que este reto dé XP?",
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.75, // Redimensionar el Switch
                              child: Switch(
                                value: showXPSection,
                                onChanged: (value) {
                                  setState(() {
                                    showXPSection = value;
                                  });
                                },
                                activeColor: Theme.of(context)
                                    .splashColor, // Color cuando está activado
                                inactiveTrackColor:
                                    Colors.grey, // Pista inactiva
                                inactiveThumbColor: Theme.of(context)
                                    .splashColor, // Control deslizante inactivo
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Mostrar el TextField de XP si el interruptor está activado
                        if (showXPSection) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "Ingrese la cantidad de experiencia (0-100):",
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

                          // TextField para ingresar el XP con el nuevo diseño
                          TextField(
                            controller: xpController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                  3), // Limitar a 3 caracteres
                            ],
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
                              labelText: "XP",
                              labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 138, 138, 138),
                                fontSize: 14,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                              counterText: '',
                              hintText: "0-100",
                            ),
                            onChanged: (value) {
                              final newValue = int.tryParse(value) ?? 0;

                              if (newValue > 100) {
                                xpController.text = '100';
                                xpController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: xpController.text.length),
                                );
                              } else if (newValue < 0) {
                                xpController.text = '0';
                                xpController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: xpController.text.length),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 20),
                        ],

                        // Interruptor para mostrar la sección de preguntas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "¿Desea agregar una pregunta?",
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.75, // Redimensionar el Switch
                              child: Switch(
                                value: showQuestionSection,
                                onChanged: (value) {
                                  setState(() {
                                    showQuestionSection = value;
                                  });
                                },
                                activeColor: Theme.of(context)
                                    .splashColor, // Color cuando está activado
                                inactiveTrackColor:
                                    Colors.grey, // Pista inactiva
                                inactiveThumbColor: Theme.of(context)
                                    .splashColor, // Control deslizante inactivo
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Mostrar la sección de preguntas y respuestas si el interruptor está activado
                        if (showQuestionSection) ...[
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
                                      child: InputBigTextField(
                                        controller: answerControllers[index],
                                        labelText: "Respuesta ${index + 1}",
                                        obscureText: false,
                                      ),
                                    ),
                                    Radio<int>(
                                      activeColor: Theme.of(context)
                                          .secondaryHeaderColor,
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
                          const SizedBox(height: 20),
                        ],
                        const SizedBox(height: 15),

                        // Selección de ubicación del reto
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
                              final result = await Navigator.of(context,
                                      rootNavigator: true)
                                  .push(
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
                                            color:
                                                Theme.of(context).dividerColor,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .dividerColor, // Color del borde
                                              width: 1, // Ancho del borde
                                            ),
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
                child: Stack(
                  children: [
                    // Botón para crear el reto
                    RedButton(
                      buttonText: "CREAR",
                      onTap: createChallenge,
                    ),
                    if (_isUploading) // Mostrar el indicador de carga si está subiendo
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: MediaQuery.of(context).size.width - 95,
                        child: Center(
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              backgroundColor: Theme.of(context)
                                  .secondaryHeaderColor
                                  .withOpacity(0.5),
                              strokeCap: StrokeCap.round,
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).secondaryHeaderColor),
                            ),
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
    );
  }
}

class _XPInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Limitar la entrada a valores entre 0 y 100
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    int value = int.parse(newValue.text);
    if (value < 0) {
      value = 0;
    } else if (value > 100) {
      value = 100;
    }
    return TextEditingValue(
      text: value.toString(),
      selection: newValue.selection,
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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                tileBuilder: isDarkMode ? _darkModeTileBuilder : null,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    height: 35,
                    width: 35,
                    point: LatLng(widget.latitude, widget.longitude),
                    child: Icon(
                      Icons.location_on,
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

Widget _darkModeTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) {
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[
      -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
      -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
      -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
      0, 0, 0, 1, 0, // Alpha channel
    ]),
    child: tileWidget,
  );
}
