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
import 'package:unigo/models/challenge.dart';
import 'package:unigo/pages/map/challenge_screen.dart';
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

  late MapController mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  SharedPreferences? _prefs;
  static const String _lastKnownLocationKey = 'last_known_location';

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    getChallenges();

    SharedPreferences.getInstance().then(
      (prefs) {
        _prefs = prefs;
        final lastLocationString = prefs.getString(_lastKnownLocationKey);
        if (lastLocationString != null) {
          final lastLocation = Position.fromMap(
            Map<String, dynamic>.from(json.decode(lastLocationString)),
          );
          setState(() {
            userLocation = lastLocation;
          });
          mapController.move(
            LatLng(userLocation!.latitude, userLocation!.longitude),
            18,
          );
        }
      },
    );
    centerAndGetLocationPermission();
    _startGPSTimer();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _gpsCheckTimer?.cancel(); // Cancelar el temporizador
    super.dispose();
  }

  void _startGPSTimer() {
    _gpsCheckTimer =
        async.Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (serviceEnabled = await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          showUserLocation = true;
        });
      } else {
        setState(() {
          showUserLocation = false;
        });
      }
    });
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
                      child: MyChallengePage(
                        selectedChallengeId: challenge.idChallenge,
                        nameChallenge: challenge.name,
                        descrChallenge: challenge.description,
                        expChallenge: challenge.experience.toString(),
                        questions: challenge.question,
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

  Future centerAndGetLocationPermission() async {
    if (serviceEnabled) {
      _positionStreamSubscription = Geolocator.getPositionStream().listen(
        (Position position) {
          setState(
            () {
              userLocation = position;
              _prefs?.setString(
                  _lastKnownLocationKey, json.encode(position.toJson()));
            },
          );
        },
      );
      final center = LatLng(userLocation!.latitude, userLocation!.longitude);
      mapController.move(center, 17);
    }
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

  void centerUniversityLocation() {
    const center = LatLng(41.27561, 1.98722);
    mapController.move(center, 18);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(41.27561, 1.98722),
            // initialCenter: LatLng(userLocation!.latitude, userLocation!.longitude),
            initialZoom: 18,
            maxZoom: 20,
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                const LatLng(41, 1.65),
                const LatLng(41.6, 2.35),
              ),
            ),
          ),
          children: [
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                    Uri.parse('https://openstreetmap.org/copyright'),
                  ),
                ),
              ],
            ),
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
            onTap: () {
              centerUniversityLocation();
            },
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
            onTap: centerAndGetLocationPermission,
            child: Container(
              width: 62.5,
              height: 62.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).splashColor,
              ),
              child: Center(
                child: Icon(
                  showUserLocation
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
