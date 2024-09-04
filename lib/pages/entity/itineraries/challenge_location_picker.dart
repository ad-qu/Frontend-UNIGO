import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/components/input_widgets/red_button.dart';

class ChallengeLocationPicker extends StatefulWidget {
  const ChallengeLocationPicker({super.key});

  @override
  State<ChallengeLocationPicker> createState() =>
      _ChallengeLocationPickerState();
}

class _ChallengeLocationPickerState extends State<ChallengeLocationPicker> {
  late MapController mapController;
  String? latitude;
  String? longitude;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
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
    }
  }

  void centerUniversityLocation() {
    if (latitude != null && longitude != null) {
      LatLng center = LatLng(double.parse(latitude!), double.parse(longitude!));
      mapController.move(center, 17);
    } else {
      LatLng defaultCenter = const LatLng(41.38365114691718, 2.115667142329124);
      mapController.move(defaultCenter, 17);
    }
  }

  void selectLocation() {
    LatLng center = mapController.camera.center;
    Navigator.of(context)
        .pop({'latitude': center.latitude, 'longitude': center.longitude});
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder(
        future: getCampusLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      double.parse(latitude!),
                      double.parse(longitude!),
                    ),
                    initialZoom: 16.5,
                    maxZoom: 20,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                      tileBuilder: isDarkMode ? _darkModeTileBuilder : null,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                    child: Icon(
                      Icons.location_on,
                      color: Theme.of(context).splashColor,
                      size: 50,
                    ),
                  ),
                ),
                Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: RedButton(
                        buttonText: "SELECCIONA UBICACIÓN",
                        onTap: selectLocation)),
                Positioned(
                  top: 55,
                  left: 25,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
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
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
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
