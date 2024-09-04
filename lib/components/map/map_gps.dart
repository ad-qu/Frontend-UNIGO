// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:async';
import 'dart:async' as async;

import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/models/campus.dart';
import 'package:unigo/models/challenge.dart';
import 'package:unigo/pages/map/challenge_pop_up.dart';
import 'package:unigo/pages/profile/profile_home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class MapGPS extends StatefulWidget {
  const MapGPS({super.key});

  @override
  State<MapGPS> createState() => _MapGPSState();
}

class _MapGPSState extends State<MapGPS> {
  String? _idUser;

  Challenge? challenge;
  List<Challenge> challengeList = <Challenge>[];

  List<Marker> allmarkers = [];
  LocationPermission? permission;

  bool serviceEnabled = false;
  bool showUserLocation = false;
  Position? userLocation;
  async.Timer? _gpsCheckTimer;
  String? latitude;
  String? longitude;
  late MapController mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool gpsActivated = false;

  List<Campus> campusList = [];
  Campus? selectedCampus;

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    getLocationPermission();
    startGPS();

    getChallenges();
    getCampusLocation();
    getCampus();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _gpsCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> getCampusLocation() async {
    final prefs = await SharedPreferences.getInstance();
    latitude = prefs.getString('latitude');
    longitude = prefs.getString('longitude');

    if (latitude == null ||
        longitude == null ||
        latitude == '' ||
        longitude == '') {
      latitude = "41.38365114691718";
      longitude = "2.115667142329124";
      _showCampusSelectionDialog();
    }
  }

  Future getCampus() async {
    String path = 'http://${dotenv.env['API_URL']}/campus/get/all';
    try {
      var response = await Dio().get(path);
      var campus = response.data as List;
      setState(() {
        campusList = campus.map((campus) => Campus.fromJson2(campus)).toList();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future getChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    _idUser = prefs.getString('idUser');

    String path =
        'http://${dotenv.env['API_URL']}/challenge/get/availableChallenges/$_idUser';
    try {
      var response = await Dio().get(path,
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          }));
      var list = response.data as List;

      setState(() {
        challengeList =
            list.map((challenge) => Challenge.fromJson2(challenge)).toList();
      });
      fetchAndBuildMarkers();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void fetchAndBuildMarkers() {
    final newMarkers = challengeList.map(
      (challenge) {
        final latitude = double.parse(challenge.latitude);
        final longitude = double.parse(challenge.longitude);
        return Marker(
          height: 37.5,
          width: 37.5,
          point: LatLng(latitude, longitude),
          rotate: true,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: ChallengePopUp(
                        selectedChallengeId: challenge.idChallenge,
                        nameChallenge: challenge.name,
                        descrChallenge: challenge.description,
                        expChallenge: challenge.experience.toString(),
                        questions: challenge.question,
                        imageURL: challenge.imageURL,
                      ),
                    ),
                  );
                },
              );
            },
            child: ClipOval(
              child: (challenge.imageURL == null || challenge.imageURL!.isEmpty)
                  ? Image.asset(
                      'assets/images/challenge.png',
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      challenge.imageURL!,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Container(
                            color: Colors.transparent,
                            child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Theme.of(context).hoverColor,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).splashColor,
                                ),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          'assets/images/challenge.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
          ),
        );
      },
    ).toList();

    allmarkers.addAll(newMarkers);
  }

  Future<void> getLocationPermission() async {
    LocationPermission checkPermissions;
    checkPermissions = await Geolocator.checkPermission();

    if (checkPermissions == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Location permission denied forever',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: const SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Location permission has been denied forever. Please enable it in your device settings to use this feature.",
                    style: TextStyle(fontSize: 13.5),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  overlayColor: WidgetStateColor.resolveWith(
                    (states) =>
                        const Color.fromARGB(255, 222, 66, 66).withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color.fromARGB(255, 222, 66, 66),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  overlayColor: WidgetStateColor.resolveWith(
                    (states) =>
                        const Color.fromARGB(255, 222, 66, 66).withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  'Open Settings',
                  style: TextStyle(
                    color: Color.fromARGB(255, 222, 66, 66),
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }
  }

  Future<void> getPositionSubscription() async {
    _positionStreamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        setState(() {
          userLocation = position;
        });
      },
    );
  }

  Future<void> startGPS() async {
    _gpsCheckTimer =
        async.Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (gpsActivated) {
        if (await Geolocator.isLocationServiceEnabled() == false) {
          setState(() {
            gpsActivated = false;
          });
        }
      } else {
        if (await Geolocator.isLocationServiceEnabled() == true) {
          getPositionSubscription();
          setState(() {
            gpsActivated = true;
          });
        }
      }
    });
  }

  openSettings() {
    Geolocator.openLocationSettings();
  }

  Future<void> _showCampusSelectionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Selecciona un campus universitario',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            content: FutureBuilder(
              future: getCampus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: double.maxFinite,
                    height: 155,
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Color.fromARGB(25, 217, 59, 60),
                        strokeCap: StrokeCap.round,
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 204, 49, 49)),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error al cargar los campus'),
                  );
                } else {
                  return Container(
                    width: double.maxFinite,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height *
                          0.5, // 60% de la altura de la pantalla
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'No ha sido posible seleccionar un campus universitario al iniciar sesión con Google. Selecciona uno para continuar.',
                            style: TextStyle(
                                fontSize: 13.5), // Mismo tamaño de texto
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<Campus>(
                            value: selectedCampus,
                            enableFeedback: false,
                            iconEnabledColor:
                                Theme.of(context).secondaryHeaderColor,
                            isExpanded: true,
                            hint: const Text(
                              'Seleccionar campus',
                              style: TextStyle(
                                color: Color.fromARGB(255, 138, 138, 138),
                                fontSize: 14,
                              ),
                            ),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(17.5)),
                              ),
                              contentPadding: const EdgeInsets.all(17),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(17.5)),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                            ),
                            dropdownColor: Theme.of(context).cardColor,
                            items: campusList.map((Campus campus) {
                              return DropdownMenuItem<Campus>(
                                value: campus,
                                child: Text(
                                  campus.name,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.color,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (Campus? newValue) {
                              setState(() {
                                selectedCampus = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (selectedCampus != null) {
                    final prefs = await SharedPreferences.getInstance();
                    final String token = prefs.getString('token') ?? "";
                    _idUser = prefs.getString('idUser');
                    print(selectedCampus);
                    print("1");

                    print("id");
                    print(_idUser);

                    print("2");

                    String path =
                        'http://${dotenv.env['API_URL']}/user/update/$_idUser';

                    try {
                      var response = await Dio().post(
                        path,
                        data: {
                          "campus": selectedCampus?.idCampus,
                        },
                        options: Options(
                          headers: {
                            "Content-Type": "application/json",
                            "Authorization": "Bearer $token",
                          },
                        ),
                      );
                      print(response.statusCode);
                      print(response);

                      if (response.statusCode == 200) {
                        prefs.setString(
                            'campus', selectedCampus?.idCampus ?? '');
                        prefs.setString(
                            'latitude', selectedCampus?.latitude ?? '');
                        prefs.setString(
                            'longitude', selectedCampus?.longitude ?? '');

                        Navigator.of(context).pop();
                      } else {
                        print("Error");
                      }
                    } catch (e) {
                      // Manejar errores de solicitud
                      print('Error al realizar la solicitud: $e');
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, selecciona un campus.'),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  overlayColor: WidgetStateColor.resolveWith(
                    (states) => const Color.fromARGB(255, 204, 49, 49)
                        .withOpacity(0.2), // Color del overlay al presionar
                  ),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 204, 49, 49), // Cambia el color del texto a rojo
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void centerUniversityLocation() {
    print("sdfsdfasfsdf");
    print(latitude);
    if (latitude != null ||
        longitude != null ||
        latitude != '' ||
        latitude != '') {
      LatLng center = LatLng(double.parse(latitude!), double.parse(longitude!));
      mapController.move(center, 17);
    } else {
      LatLng defaultCenter = const LatLng(41.38365114691718, 2.115667142329124);
      mapController.move(defaultCenter, 17);
    }
  }

  void centerUserLocation() {
    LatLng center = LatLng(userLocation!.latitude, userLocation!.longitude);
    mapController.move(center, 17);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter:
                  LatLng(double.parse(latitude!), double.parse(longitude!)),
              initialZoom: 16.5,
              maxZoom: 20,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                tileBuilder: isDarkMode ? _darkModeTileBuilder : null,
              ),
              MarkerLayer(
                markers: allmarkers,
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  headingSectorColor: Colors.blue.shade700,
                  marker: DefaultLocationMarker(
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 250,
            right: 32,
            child: GestureDetector(
              onTap: centerUniversityLocation,
              child: Container(
                width: 62.5,
                height: 62.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).splashColor,
                ),
                child: const Center(
                  child: Icon(
                    Icons.school_rounded,
                    color: Color.fromARGB(255, 238, 238, 238),
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 157.5,
            right: 32,
            child: GestureDetector(
              onTap: gpsActivated == true ? centerUserLocation : openSettings,
              child: Container(
                width: 62.5,
                height: 62.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).splashColor,
                ),
                child: Center(
                  child: Icon(
                    gpsActivated
                        ? Icons.gps_fixed_rounded
                        : Icons.gps_off_rounded,
                    color: const Color.fromARGB(255, 238, 238, 238),
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
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
