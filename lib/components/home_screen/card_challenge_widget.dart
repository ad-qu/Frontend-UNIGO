import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unigo/pages/map/qr_screen.dart';

class MyChallengeCard extends StatelessWidget {
  final int index;
  final String attr1;
  final String attr2;
  final String attr3;
  final String attr4;
  final List<String> attr5;

  const MyChallengeCard({
    super.key,
    required this.index,
    required this.attr1, //name of the challenge
    required this.attr2, //description of the challenge
    required this.attr3, //exp
    required this.attr4,
    required this.attr5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6.5, 0, 6.5, 15),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(255, 30, 30, 30), width: 1),
            color: const Color.fromARGB(255, 23, 23, 23),
            borderRadius: BorderRadius.circular(344)),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 25, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 17.5,
                backgroundImage: attr4 != ""
                    ? Image.network(attr4).image
                    : const AssetImage('images/default.png'),
              ),
              Text(
                attr1,
                style: GoogleFonts.inter(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 227, 227, 227),
                  fontSize: 15,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30)),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color.fromARGB(255, 227, 227, 227),
                  size: 23,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
