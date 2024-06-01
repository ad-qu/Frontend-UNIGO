// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/screens/entity_screens/admin_view/entity_profile_screen_admin.dart';
import 'package:unigo/screens/profile_screens/profile_screen.dart';

void main() async {
  await dotenv.load();
}

class MyEntityCard extends StatefulWidget {
  final String idUserSession;
  final String idEntity;
  final String attr1;
  final String attr2;
  final String attr3;
  final String? attr4;
  final bool isFollowed;
  final String? attr5;

  const MyEntityCard(
      {super.key,
      required this.idUserSession, //the id in shared preferences
      required this.idEntity, //the id of the user that appears in the card
      required this.attr1, //photo url
      required this.attr2, //username
      required this.attr3, //desc
      required this.attr4, //verified
      required this.isFollowed, //if true it means that the user is following
      required this.attr5}); //admin

  @override
  State<MyEntityCard> createState() => _MyEntityCardState();
}

class _MyEntityCardState extends State<MyEntityCard> {
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
      child: GestureDetector(
        onTap: () {
          if (widget.idUserSession == widget.attr5) {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: EntityProfileScreen(
                  idEntity: widget.idEntity,
                  attr1: widget.attr1,
                  attr2: widget.attr2,
                  attr3: widget.attr3,
                  attr4: widget.attr4,
                  attr5: widget.attr5,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const ProfileScreen(),
              ),
            );
          }
        },
        child: Container(
          height:
              155, // Aumentamos la altura para dar espacio al nuevo contenedor azul
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
                    height: 75,
                    width: 75,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: ClipOval(
                        child: widget.attr1.isEmpty
                            ? Image.asset(
                                'images/entity.png',
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                widget.attr1,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
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
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Image.asset(
                                    'images/entity.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  if (widget.isFollowed == false)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 7, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                widget.attr2,
                                style: Theme.of(context).textTheme.titleSmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                                width: 8), // Espacio entre el texto y el icono
                            if (widget.attr4 == "true")
                              Container(
                                width: 16.5, // Ancho del contenedor
                                height: 16.5, // Alto del contenedor
                                decoration: BoxDecoration(
                                  color: Colors
                                      .blue.shade700, // Color de fondo azul
                                  shape: BoxShape.circle, // Forma circular
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 12,
                                    color:
                                        Colors.white, // Color del tick blanco
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.isFollowed == true)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 7, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                widget.attr2,
                                style: Theme.of(context).textTheme.titleSmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                                width: 8), // Espacio entre el texto y el icono
                            if (widget.attr4 == "true")
                              Container(
                                width: 16.5, // Ancho del contenedor
                                height: 16.5, // Alto del contenedor
                                decoration: BoxDecoration(
                                  color: Colors
                                      .blue.shade700, // Color de fondo azul
                                  shape: BoxShape.circle, // Forma circular
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 12,
                                    color:
                                        Colors.white, // Color del tick blanco
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.isFollowed == false)
                    GestureDetector(
                      onTap: () {
                        print("aaaaaaaaaaaaaa");
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20.5, 20.5, 20.5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Theme.of(context)
                                .dividerColor, // Color de fondo azul
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
                              child: Icon(
                                Icons.add,
                                size: 18,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.isFollowed == true)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 25, 15, 25),
                      child: Container(
                        height: 5.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7.5)),
                          color: Theme.of(context)
                              .cardColor, // Color de fondo azul
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                            child: Icon(
                              Icons.add,
                              size: 14,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )),
              SizedBox(
                height: 77.5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(35, 0, 35, 17.5),
                  child: Center(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.labelMedium,
                        children: [
                          TextSpan(
                            text: widget.attr3,
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
      ),
    );
  }
}
