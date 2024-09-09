import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:unigo/pages/entity/entity_home.dart';
import 'package:unigo/components/input_widgets/red_button.dart';
import 'package:unigo/components/snackbar/snackbar_provider.dart';

class ChallengeQRGenerator extends StatefulWidget {
  final String idChallenge;

  const ChallengeQRGenerator({
    super.key,
    required this.idChallenge,
  });

  @override
  State<ChallengeQRGenerator> createState() => _ChallengeQRGeneratorState();
}

class _ChallengeQRGeneratorState extends State<ChallengeQRGenerator> {
  String data = '';

  @override
  void initState() {
    super.initState();
    data = widget.idChallenge;
  }

  final GlobalKey _qrkey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/storage/emulated/0/Download/UNIGO!';

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary =
          _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);

      final whitePaint = Paint()..color = Colors.white;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
      canvas.drawRect(
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          whitePaint);
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      String fileName = 'qr_code';
      int i = 1;
      while (await File('$externalDir/$fileName.png').exists()) {
        fileName = 'qr_code_$i';
        i++;
      }

      dirExists = await File(externalDir).exists();

      if (!dirExists) {
        await Directory(externalDir).create(recursive: true);
        dirExists = true;
      }

      final file = await File('$externalDir/$fileName.png').create();
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;

      SnackBarProvider().showSuccessSnackBar(
          context, AppLocalizations.of(context)!.qr_saved, 30, 0, 30, 45);
    } catch (e) {
      if (!mounted) return;
      SnackBarProvider().showErrorSnackBar(
          context, AppLocalizations.of(context)!.server_error, 30, 0, 30, 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 17.5, 15, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const EntityScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30)),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.download_QR,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      size: 27.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: RepaintBoundary(
                key: _qrkey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      20), // Aquí defines el radio de los bordes redondeados
                  child: QrImageView(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    data: data,
                    version: QrVersions.auto,
                    size: 250.0,
                    gapless: true,
                    errorStateBuilder: (ctx, err) {
                      return const Center(
                        child: Text(
                          'Error',
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RedButton(
                    buttonText: AppLocalizations.of(context)!.save_button,
                    onTap: () {
                      _captureAndSavePng();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 15),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.download_folder,
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)!.download_red,
                      style: GoogleFonts.inter(
                        color: Theme.of(context).splashColor,
                      ), // Cambia el color a rojo
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
