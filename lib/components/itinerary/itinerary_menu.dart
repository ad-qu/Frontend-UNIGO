// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItineraryMenu extends StatefulWidget {
  final String idItinerary;
  final String name;
  final String imageURL;
  final VoidCallback onChange;

  const ItineraryMenu({
    super.key,
    required this.idItinerary,
    required this.name,
    required this.imageURL,
    required this.onChange,
  });
  @override
  State<ItineraryMenu> createState() => _ItineraryMenuState();
}

class _ItineraryMenuState extends State<ItineraryMenu> {
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
            title: Text('Eliminar itinerario',
                style: Theme.of(context).textTheme.titleSmall),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "¿Seguro que desea eliminar este itinerario?\n\nEsta decisión será permanente.",
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
                  await deleteItinerary();
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

  Future<void> deleteItinerary() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/itinerary/delete/${widget.idItinerary}';
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
          onTap: () async {
            showDeleteConfirmation();
          },
          child: Container(
            height: 40,
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
