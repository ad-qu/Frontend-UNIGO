import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/components/snackbar/snackbar_provider.dart';

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
            title: Text(AppLocalizations.of(context)!.delete_itinerary,
                style: Theme.of(context).textTheme.titleSmall),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.delete_itinerary_explanation,
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
                  await deleteItinerary();
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

  Future<void> deleteItinerary() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/itinerary/delete/${widget.idItinerary}';
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
      // ignore: use_build_context_synchronously

      SnackBarProvider().showErrorSnackBar(
        // ignore: use_build_context_synchronously
        context,
        // ignore: use_build_context_synchronously
        AppLocalizations.of(context)!.server_error,
        15,
        0,
        15,
        15,
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
