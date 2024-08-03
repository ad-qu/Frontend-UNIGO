// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/models/entity.dart';
import 'package:unigo/pages/entity/entity_home.dart';
import 'package:unigo/pages/entity/itineraries/challenge_qr_generator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChallengeMenu extends StatefulWidget {
  final String idChallenge;
  final VoidCallback onChange;

  const ChallengeMenu({
    super.key,
    required this.idChallenge,
    required this.onChange,
  });
  @override
  State<ChallengeMenu> createState() => _ChallengeMenuState();
}

class _ChallengeMenuState extends State<ChallengeMenu> {
  @override
  void initState() {
    super.initState();
  }

  void showDeleteConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(),
          ),
          AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35.0),
            ),
            title: Text('Eliminar reto',
                style: Theme.of(context).textTheme.titleSmall),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "¿Seguro que desea eliminar este reto?\n\nEsta decisión será permanente.",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).splashColor,
                  ),
                ),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await deleteChallenge();
                  Navigator.of(context).pop();
                  widget.onChange();
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).splashColor,
                  ),
                ),
                child: const Text('Confirmar'),
              ),
            ],
          )
        ]);
      },
    );
  }

  Future<void> deleteChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/challenge/delete/${widget.idChallenge}';
    try {
      var response = await Dio().delete(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 56, 142, 60),
            showCloseIcon: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.5)),
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            content: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
              child: Text(
                "Challenge successfully deleted",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).splashColor,
            showCloseIcon: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.5)),
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            content: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
              child: Text(
                AppLocalizations.of(context)!.unable_to_proceed,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).splashColor,
          showCloseIcon: false,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.5)),
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          content: Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
            child: Text(
              AppLocalizations.of(context)!.unable_to_proceed,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
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
            showDeleteConfirmation();
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
