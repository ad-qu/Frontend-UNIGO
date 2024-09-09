import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackBarProvider {
  // SnackBar de error
  void showErrorSnackBar(BuildContext context, String message, double left,
      double top, double right, double bottom) {
    final margin = EdgeInsets.fromLTRB(left, top, right, bottom);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).splashColor,
        showCloseIcon: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.5),
        ),
        margin: margin,
        content: Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
          child: Text(
            message,
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

  // SnackBar de éxito
  void showSuccessSnackBar(BuildContext context, String message, double left,
      double top, double right, double bottom) {
    final margin = EdgeInsets.fromLTRB(left, top, right, bottom);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).hintColor,
        showCloseIcon: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.5),
        ),
        margin: margin,
        content: Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: Theme.of(context).secondaryHeaderColor),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // SnackBar de advertencia
  void showWarningSnackBar(BuildContext context, String message, double left,
      double top, double right, double bottom) {
    final margin = EdgeInsets.fromLTRB(left, top, right, bottom);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).highlightColor,
        showCloseIcon: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.5),
        ),
        margin: margin,
        content: Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: Theme.of(context).scaffoldBackgroundColor),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
