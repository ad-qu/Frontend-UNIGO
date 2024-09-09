import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:unigo/pages/entity/itineraries/challenge_qr_generator.dart';

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
            title: Text(AppLocalizations.of(context)!.delete_challenge,
                style: Theme.of(context).textTheme.titleSmall),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.delete_chalenge_explanation,
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
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () async {
                  await deleteChallenge();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  widget.onChange();
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).splashColor,
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.confirm),
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
      await Dio().delete(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                AppLocalizations.of(context)!.download_QR,
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
                AppLocalizations.of(context)!.delete_button,
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
