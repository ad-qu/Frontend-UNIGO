import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/pages/entity/entity_home.dart';

class ChallengeLocationPicker extends StatelessWidget {
  const ChallengeLocationPicker({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 17.5, 15, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const EntityScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30)),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ),
                  Text(
                    "Ubicación",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      size: 27.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FlutterLocationPicker(
                initZoom: 17,
                minZoomLevel: 5,
                maxZoomLevel: 18.25,
                maxBounds: LatLngBounds(
                  const LatLng(41, 1.65),
                  const LatLng(41.6, 2.35),
                ),
                trackMyPosition: false,
                showCurrentLocationPointer: false,
                //Searchbar
                showSearchBar: false,
                searchbarBorderRadius: BorderRadius.circular(17.5),
                initPosition: const LatLong(41.27561, 1.98722),
                searchbarInputBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17.5)),
                searchBarBackgroundColor: Theme.of(context).cardColor,
                searchbarInputFocusBorderp: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17.5)),
                //mapLoadingBackgroundColor: Colors.amber,
                loadingWidget: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        backgroundColor: Theme.of(context).hoverColor,
                        strokeCap: StrokeCap.round,
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).splashColor),
                      ),
                    ],
                  ),
                ),
                //Buttons

                showZoomController: false,
                showLocationController: false,

                //SelectLocationButton
                selectLocationButtonHeight: 55,
                selectLocationButtonText: "SELECCIONAR UBICACIÓN",
                selectLocationButtonPositionLeft: 20,
                selectLocationButtonPositionRight: 20,
                selectLocationButtonPositionBottom: 20,
                selectedLocationButtonTextstyle:
                    Theme.of(context).textTheme.labelLarge ??
                        GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 227, 227, 227),
                        ),
                selectLocationButtonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      return Theme.of(context).splashColor;
                    },
                  ),
                  overlayColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      return Colors
                          .transparent; // Deshabilita el feedback visual
                    },
                  ),
                  shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
                    (states) {
                      return RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17.5),
                      );
                    },
                  ),
                ),

                //Marker
                markerIconOffset: -25,
                markerIcon: Icon(
                  Icons.location_on,
                  color: Theme.of(context).splashColor,
                  size: 50,
                ),

                onPicked: (pickedData) {
                  Navigator.pop(context, {
                    'latitude': pickedData.latLong.latitude,
                    'longitude': pickedData.latLong.longitude,
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
