// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/components/itinerary/itinerary_more_button.dart';
import 'package:unigo/pages/entity/entity_profile.dart';
import 'package:unigo/pages/entity/itineraries/challenge_home.dart';
import 'package:unigo/pages/entity/itineraries/itinerary_home.dart';
import 'package:unigo/pages/profile/profile_home.dart';

void main() async {
  await dotenv.load();
}

class ItineraryCard extends StatefulWidget {
  final String? idUser;
  final String? entityAdmin;
  final String idItinerary;
  final String name;
  final String imageURL;
  final int number;

  const ItineraryCard({
    super.key,
    required this.idUser,
    required this.entityAdmin,
    required this.idItinerary,
    required this.name,
    required this.imageURL,
    required this.number,
  });

  @override
  State<ItineraryCard> createState() => _ItineraryCardState();
}

class _ItineraryCardState extends State<ItineraryCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 13),
      child: GestureDetector(
        onTap: () {
          if (widget.idUser == widget.entityAdmin) {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: ChallengeHome(idItinerary: widget.idItinerary),
              ),
            );
          } else {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: ChallengeHome(idItinerary: widget.idItinerary),
              ),
            );
          }
        },
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(37.5),
          ),
          width: MediaQuery.of(context).size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                width: 58,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
                  child: ClipOval(
                    child: widget.imageURL.isEmpty
                        ? Image.asset(
                            'assets/images/itinerary.png',
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.imageURL,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // La imagen ha terminado de cargar
                              } else {
                                return Container(
                                  color: Theme.of(context)
                                      .cardColor, // Fondo rojo mientras se carga la imagen
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor:
                                          Theme.of(context).hoverColor,
                                      strokeCap: StrokeCap.round,
                                      strokeWidth: 5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).splashColor),
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ), // Indicador de progreso mientras se carga
                                  ),
                                );
                              }
                            },
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return Image.asset(
                                'assets/images/itinerary.png',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.name.length > 12
                                ? '${widget.name.substring(0, 12)}...'
                                : widget.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '(${widget.number})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 7.5, 0),
                child: ItineraryMoreButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
