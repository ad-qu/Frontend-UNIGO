// ignore_for_file: use_build_context_synchronously

import 'package:unigo/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItineraryMenu extends StatelessWidget {
  const ItineraryMenu({super.key});

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
            Navigator.pop(context);
          },
          child: Container(
            height: 40,
            color: Theme.of(context).dividerColor,
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
