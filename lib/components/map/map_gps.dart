// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unigo/models/challenge%20(deprecated).dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unigo/pages/map/challenge_screen.dart';

void main() async {
  await dotenv.load();
}

class MapGPS extends StatefulWidget {
  const MapGPS({super.key});

  @override
  State<MapGPS> createState() => _MapGPSState();
}

class _MapGPSState extends State<MapGPS> {
  String? _idUser;

  ChallengeD? challenge;
  List<ChallengeD> challengeList = <ChallengeD>[];

  List<Marker> allmarkers = [];

  String? selectedChallengeId;
  String? nameChallenge;
  String? descrChallenge;
  int? expChallenge;
  List<String>? questions;
  LocationPermission? permission;

  bool serviceEnabled = false;
  bool showUserLocation = false;
  Position? userLocation;

  late MapController mapController;

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    getChallenges();
    getLocationPermission();
  }

  void getChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    _idUser = prefs.getString('idUser');

    String path =
        'http://${dotenv.env['API_URL']}/challenge/get/available/$_idUser';
    var response = await Dio().get(path,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        }));
    var registros = response.data as List;
    for (var sub in registros) {
      challengeList.add(ChallengeD.fromJson(sub));
    }
    if (mounted) {
      setState(() {
        challengeList = challengeList;
      });
    }
    fetchAndBuildMarkers();
  }

  void fetchAndBuildMarkers() {
    final newMarkers = challengeList.map((challenge) {
      final lat = double.parse(challenge.lat);
      final long = double.parse(challenge.long);
      return Marker(
        height: 35,
        width: 35,
        point: LatLng(lat, long),
        rotate: true,
        // Utiliza 'child' para especificar el widget dentro del marcador
        child: GestureDetector(
          onTap: () {
            setState(() {
              questions = challenge.questions;
              selectedChallengeId = challenge.id;
              nameChallenge = challenge.name;
              descrChallenge = challenge.descr;
              expChallenge = challenge.exp;
            });
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
                      selectedChallengeId: selectedChallengeId,
                      nameChallenge: nameChallenge,
                      descrChallenge: descrChallenge,
                      expChallenge: expChallenge.toString(),
                      questions: questions,
                    ),
                  ),
                );
              },
            );
          },
          child: Image.asset(
            'images/marker.png',
          ),
        ),
      );
    }).toList();

    allmarkers.addAll(newMarkers);
  }

  void getLocationPermission() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Location service disabled',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: const SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "The location service is disabled. Please enable it in your device settings.",
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
                  overlayColor: MaterialStateColor.resolveWith(
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
                  Geolocator.openLocationSettings();
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
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

    LocationPermission checkPermissions;
    checkPermissions = await Geolocator.checkPermission();

    if (checkPermissions == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // ignore: use_build_context_synchronously
      showDialog(
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
                  overlayColor: MaterialStateColor.resolveWith(
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
    listenToLocationUpdates();
  }

  void listenToLocationUpdates() {
    Geolocator.getPositionStream().listen((Position position) async {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (mounted) {
        if (serviceEnabled) {
          setState(() {
            userLocation = position;
            showUserLocation = true;
            updateMarkers();
          });
        } else {
          setState(() {
            userLocation = null;
            showUserLocation = false;
            updateMarkers();
          });
        }
      }
    }, onError: (e) {
      setState(() {
        userLocation = null;
        showUserLocation = false;
        updateMarkers();
      });
    });
  }

  void updateMarkers() {
    allmarkers.clear();
    if (showUserLocation && userLocation != null) {
      final userMarker = Marker(
        height: 25,
        width: 25,
        point: LatLng(userLocation!.latitude, userLocation!.longitude),
        // Utiliza 'child' para especificar el widget dentro del marcador
        // En este caso, una imagen
        child: Image.asset(
          'images/gps_pointer.png',
        ),
      );
      allmarkers.add(userMarker);
    }
    fetchAndBuildMarkers();
  }

  void onTapContainer() {
    if (showUserLocation && userLocation != null) {
      final center = LatLng(userLocation!.latitude, userLocation!.longitude);
      mapController.move(center, 18.25);
    } else {
      getLocationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(41.27561, 1.98722),
            initialZoom: 17,
            maxZoom: 18.25,
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                LatLng(41, 1.65),
                LatLng(41.6, 2.35),
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
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: allmarkers,
            ),
          ],
        ),
        Positioned(
          bottom: 157.5,
          right: 32,
          child: GestureDetector(
            onTap: onTapContainer,
            child: Container(
              width: 57.5,
              height: 57.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).splashColor,
              ),
              child: Center(
                child: Icon(
                  showUserLocation
                      ? Icons.gps_fixed_rounded
                      : Icons.gps_off_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}