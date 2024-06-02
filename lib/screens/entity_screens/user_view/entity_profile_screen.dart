// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unigo/screens/entity_screens/entity_screen.dart';
import 'package:unigo/screens/entity_screens/admin_view/news_screens/news_screen_admin.dart';
import 'package:unigo/screens/initial_screens/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/widgets/input_widgets/delete_account_button.dart';
import 'package:unigo/widgets/input_widgets/edit_account_button.dart';
import 'package:unigo/widgets/input_widgets/edit_password_button.dart';
import 'package:unigo/widgets/input_widgets/grey_button.dart';
import 'package:unigo/widgets/input_widgets/history_button.dart';
import 'package:unigo/widgets/input_widgets/log_out_button.dart';
import '../../../models/user.dart' as user_ea;
import '../../../widgets/profile_screen/card_user_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/screens/profile_screens/edit_account.dart';
import 'package:unigo/screens/profile_screens/edit_password.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:ui';

class EntityProfileScreenrewrw extends StatefulWidget {
  final String idEntity;
  final String attr1;
  final String attr2;
  final String attr3;
  final String? attr4;
  final String? attr5;

  const EntityProfileScreenrewrw({
    super.key,
    required this.idEntity,
    required this.attr1,
    required this.attr2,
    required this.attr3,
    required this.attr4,
    required this.attr5,
  });

  @override
  _EntityProfileScreenrewrwState createState() =>
      _EntityProfileScreenrewrwState();
}

class _EntityProfileScreenrewrwState extends State<EntityProfileScreenrewrw> {
  @override
  void initState() {
    super.initState();
  }

  Widget imageProfile() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: widget.attr1 != ""
              ? Image.network(widget.attr1).image
              : const AssetImage('images/entity.png'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 1080,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                            PageTransition(
                              type: PageTransitionType.topToBottom,
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(7.5, 0, 7.5, 0),
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
                                  width:
                                      8), // Espacio entre el texto y el icono
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
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(
                          Icons.people_alt_rounded,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          imageProfile(),
                          const SizedBox(height: 37.5),
                          Container(
                            height: 153.5,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(17.5),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 20, 0),
                                    child: RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                        children: [
                                          TextSpan(
                                            text: "${widget.attr2}.\n\n",
                                          ),
                                          TextSpan(
                                            text: widget.attr3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child:
                                          NewsScreen(idEntity: widget.idEntity),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              55, 196, 150, 11),
                                          width: 1),
                                      color: Theme.of(context).cardColor,
                                      borderRadius:
                                          BorderRadius.circular(17.5)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.newspaper_rounded,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                            ),
                                            const SizedBox(
                                              width: 17,
                                            ),
                                            Text(
                                              "Noticias",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            55, 204, 49, 49),
                                        width: 1),
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(17.5)),
                                child: Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.chat,
                                            size: 20,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                          const SizedBox(
                                            width: 17,
                                          ),
                                          Text(
                                            "Chat",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            55, 56, 142, 60),
                                        width: 1),
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(17.5)),
                                child: Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.route_rounded,
                                            size: 20,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                          const SizedBox(
                                            width: 17,
                                          ),
                                          Text(
                                            "Itinerarios",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).dividerColor, width: 1),
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(17.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.settings,
                                size: 20,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                              const SizedBox(
                                width: 17,
                              ),
                              Text(
                                "Ajustes",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      widget.idEntity,
                      style: GoogleFonts.inter(
                        color: Theme.of(context).dividerColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
