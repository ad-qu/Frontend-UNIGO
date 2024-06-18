// ignore_for_file: use_build_context_synchronously

import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unigo/pages/entity/itineraries/challenge_qr_generator.dart';

class ChallengeMenu extends StatefulWidget {
  final String idChallenge;

  const ChallengeMenu({
    super.key,
    required this.idChallenge,
  });
  @override
  State<ChallengeMenu> createState() => _ChallengeMenuState();
}

class _ChallengeMenuState extends State<ChallengeMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            Navigator.pop(context);
          },
          child: Container(
            height: 39,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Text(
                'Editar',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
          ),
        ),
        Divider(color: Theme.of(context).dividerColor, height: 1),
        GestureDetector(
          onTap: () async {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: ChallengeQRGenerator(idChallenge: widget.idChallenge),
              ),
            );
          },
          child: Container(
            height: 40,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Text(
                'Descargar QR',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
          ),
        ),
        Divider(color: Theme.of(context).dividerColor, height: 1),
        GestureDetector(
          onTap: () async {
            Navigator.pop(context);
          },
          child: Container(
            height: 39,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Text(
                'Eliminar',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
