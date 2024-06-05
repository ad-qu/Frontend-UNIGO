import 'package:flutter/material.dart';

class ChallengeCard extends StatefulWidget {
  final String idChallenge;
  final String name;
  final String description;
  final String latitude;
  final String longitude;
  final int experience;

  const ChallengeCard({
    super.key,
    required this.idChallenge,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.experience,
  });

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
        height: 285,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(37.5),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Asegura la alineación a la izquierda
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      widget.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 7,
                  widget.description,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Latitude: ${widget.latitude}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Longitude: ${widget.longitude}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 25, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: const Color.fromARGB(255, 247, 199, 18),
                        size: 15,
                      ),
                      SizedBox(width: 7.5),
                      Text(
                        "${widget.experience}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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
