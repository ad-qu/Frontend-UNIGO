import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/components/challenge/challenge_menu.dart';
import 'package:unigo/components/challenge/challenge_more_button.dart';
import 'package:unigo/components/itinerary/itinerary_menu.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:unigo/pages/map/challenge_pop_up.dart';
import 'package:unigo/pages/map/qr_screen.dart';

class ChallengeCardHome extends StatefulWidget {
  final String idChallenge;
  final String name;
  final String description;
  final String latitude;
  final String longitude;
  final List<String>? question;
  final int experience;
  final String itinerary;
  final String? imageURL;

  const ChallengeCardHome({
    super.key,
    required this.idChallenge,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.question,
    required this.experience,
    required this.itinerary,
    this.imageURL,
  });

  @override
  State<ChallengeCardHome> createState() => _ChallengeCardHomeState();
}

class _ChallengeCardHomeState extends State<ChallengeCardHome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 13),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(37.5),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(37.5),
          ),
          child: Slidable(
            key: ValueKey(widget.idChallenge),
            startActionPane: ActionPane(
              extentRatio: 0.325,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
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
                              selectedChallengeId: widget.idChallenge,
                              nameChallenge: widget.name,
                              descrChallenge: widget.description,
                              expChallenge: widget.experience.toString(),
                              questions: widget.question,
                              imageURL: widget.imageURL,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  backgroundColor: Theme.of(context).dividerColor,
                  foregroundColor: Colors.white,
                  icon: Icons.info,
                  label: 'Info.',
                ),
              ],
            ),
            endActionPane: ActionPane(
              extentRatio: 0.325,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => MyQR(
                          idChallenge: widget.idChallenge,
                          questions: widget.question ?? [],
                          expChallenge: widget.experience.toString(),
                        ),
                      ),
                    );
                  },
                  backgroundColor: Theme.of(context).dividerColor,
                  foregroundColor: Colors.white,
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Escanear',
                ),
              ],
            ),
            child: Container(
              height: 131,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).dividerColor, width: 1),
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(37.5),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(27.5, 20, 27.5, 20),
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
                        Row(
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
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(27.5, 0, 27.5, 25),
                          child: Text(
                            widget.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
