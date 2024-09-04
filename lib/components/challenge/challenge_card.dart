import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unigo/components/challenge/challenge_menu.dart';
import 'package:unigo/components/challenge/challenge_more_button.dart';
import 'package:unigo/components/itinerary/itinerary_menu.dart';

class ChallengeCard extends StatefulWidget {
  final String idChallenge;
  final String name;
  final String description;
  final String latitude;
  final String longitude;
  final int experience;
  final String idUser;
  final String admin;
  final VoidCallback onChange;

  const ChallengeCard(
      {super.key,
      required this.idChallenge,
      required this.name,
      required this.description,
      required this.latitude,
      required this.longitude,
      required this.experience,
      required this.idUser,
      required this.admin,
      required this.onChange});

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 13),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(37.5),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 10, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  if (widget.admin == widget.idUser)
                    ChallengeMoreButton(
                      idChallenge: widget.idChallenge,
                      onChange: widget.onChange,
                    )
                  else
                    const SizedBox(height: 54)
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 8, 30, 20),
                    child: Text(
                      widget.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 25, 25),
                  child: MiniMap(
                    latitude: double.parse(widget.latitude),
                    longitude: double.parse(widget.longitude),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 34, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 65,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor, // Color del borde
                            width: 1, // Ancho del borde
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 4, 3.5, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star_rate_rounded,
                                color: Color.fromARGB(255, 247, 199, 18),
                                size: 14.5,
                              ),
                              const SizedBox(width: 5.5),
                              Text(
                                "${widget.experience}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MiniMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MiniMap({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width - 84,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: AbsorbPointer(
          absorbing: true,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(latitude, longitude),
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
                    point: LatLng(latitude, longitude),
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
