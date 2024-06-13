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
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 13),
      child: Container(
        height:
            175, // Aumentamos la altura para dar espacio al nuevo contenedor azul
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(37.5),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 34,
                    height: 150,
                    child: (widget.imageURL == null || widget.imageURL!.isEmpty)
                        ? Container(
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('images/new.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(
                                  17.5), // Radio de los bordes
                            ),
                          )
                        : Image.network(
                            widget.imageURL ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // La imagen ha terminado de cargar
                              } else {
                                return Container(
                                  color: Theme.of(context)
                                      .cardColor, // Fondo rojo mientras se carga la imagen
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        backgroundColor:
                                            Theme.of(context).hoverColor,
                                        strokeCap: StrokeCap.round,
                                        strokeWidth: 5,
                                        valueColor: AlwaysStoppedAnimation<
                                            Color>(Theme.of(
                                                context)
                                            .splashColor)), // Indicador de progreso mientras se carga
                                  ),
                                );
                              }
                            },
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                height: 150,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage('images/new.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      17.5), // Radio de los bordes
                                ),
                              );
                            },
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 62.5, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              widget.title,
                              style: Theme.of(context).textTheme.titleSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                              width: 8), // Espacio entre el texto y el icono
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 97.5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(35, 0, 35, 17.5),
                child: Center(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
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
          ],
        ),
      ),
    );
  }
}
