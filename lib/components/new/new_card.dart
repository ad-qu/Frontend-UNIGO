// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/pages/entity/entity_profile.dart';
import 'package:unigo/pages/entity/entity_viewer.dart';
import 'package:unigo/pages/profile/profile_home.dart';

void main() async {
  await dotenv.load();
}

class NewCard extends StatefulWidget {
  final String idNew;
  final String title;
  final String description;
  final String? imageURL;
  final String date;

  const NewCard({
    super.key,
    required this.idNew,
    required this.title,
    required this.description,
    required this.imageURL,
    required this.date,
  });

  @override
  State<NewCard> createState() => _NewCardState();
}

class _NewCardState extends State<NewCard> {
  late String buttonText;
  late bool isFollowing;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(0, 2, 0, 10), // Ajusta el padding inferior
      child: Container(
        // Reducir la altura del contenedor principal
        height: widget.imageURL == null || widget.imageURL!.isEmpty ? 200 : 350,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(
              30), // Reduce el radio de borde si es necesario
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 20, 20, 15), // Ajusta el padding del título
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            widget.title,
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SizedBox(
                height: 90, // Reduce la altura del contenedor de la descripción
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      20, 7, 30, 20), // Ajusta el padding de la descripción
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines:
                        4, // Reduce el número máximo de líneas si es necesario
                    text: TextSpan(
                      style: Theme.of(context).textTheme.labelMedium,
                      children: [
                        TextSpan(
                          text: widget.description,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.imageURL != null && widget.imageURL!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    15, 10, 15, 15), // Ajusta el padding de la imagen
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 30,
                  height: 130, // Reduce la altura del contenedor de la imagen
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        15), // Reduce el radio del borde si es necesario
                    child: Image.network(
                      widget.imageURL!,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Container(
                            color: Theme.of(context).cardColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Theme.of(context).hoverColor,
                                strokeCap: StrokeCap.round,
                                strokeWidth:
                                    4, // Reduce el ancho de la barra de progreso
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).splashColor,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height:
                              130, // Asegúrate de que el tamaño coincida con el tamaño del contenedor de la imagen
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('images/new.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
