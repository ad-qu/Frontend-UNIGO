import 'package:popover/popover.dart';
import 'package:flutter/material.dart';
import 'package:unigo/components/challenge/challenge_menu.dart';
import 'package:unigo/components/itinerary/itinerary_menu.dart';
import 'package:unigo/components/language/language_menu.dart';

class ChallengeMoreButton extends StatelessWidget {
  const ChallengeMoreButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) => const ChallengeMenu(),
            width: 125,
            height: 122,
            direction: PopoverDirection.bottom,
            contentDyOffset: -7.5,
            arrowHeight: 10,
            arrowWidth: 15,
            arrowDxOffset: 0,
            radius: 20,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30)),
          child: Icon(
            Icons.more_horiz_rounded,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
      ),
    );
  }
}