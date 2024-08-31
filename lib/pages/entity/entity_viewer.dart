import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/pages/entity/chat_screens/chat_screen.dart';
import 'package:unigo/pages/entity/entity_home.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/pages/entity/entity_people.dart';
import 'package:unigo/pages/entity/itineraries/itinerary_home.dart';
import 'package:unigo/pages/entity/news/news_home.dart';

class EntityProfileViewer extends StatefulWidget {
  final String idUserSession;
  final String idEntity;
  final String attr1;
  final String attr2;
  final String attr3;
  final String? attr4;
  final String attr5;
  final bool isFollowed;

  const EntityProfileViewer({
    super.key,
    required this.idUserSession,
    required this.idEntity,
    required this.attr1,
    required this.attr2,
    required this.attr3,
    required this.attr4,
    required this.attr5,
    required this.isFollowed,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EntityProfileViewerState createState() => _EntityProfileViewerState();
}

class _EntityProfileViewerState extends State<EntityProfileViewer> {
  bool? followParameter;

  @override
  void initState() {
    super.initState();
    followParameter = widget.isFollowed;
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

  Future followOrUnfollow() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    try {
      if (followParameter == true) {
        await Dio().post(
          'http://${dotenv.env['API_URL']}/entity/follow/delete/${widget.idUserSession}/${widget.idEntity}',
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          ),
        );
        setState(() {
          followParameter = false;
        });
      } else {
        await Dio().post(
          'http://${dotenv.env['API_URL']}/entity/follow/add/${widget.idUserSession}/${widget.idEntity}',
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          ),
        );
        setState(() {
          followParameter = true;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 1080,
            child: followParameter ?? false
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context, true);
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
                                padding:
                                    const EdgeInsets.fromLTRB(7.5, 0, 7.5, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        widget.attr2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
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
                                          color: Colors.blue
                                              .shade700, // Color de fondo azul
                                          shape:
                                              BoxShape.circle, // Forma circular
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 12,
                                            color: Colors
                                                .white, // Color del tick blanco
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: EntityPeople(
                                        idEntity: widget.idEntity,
                                        admin: widget.attr5!),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Icon(
                                  Icons.people_alt_rounded,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
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
                                  height: 172.5,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
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
                                                    text:
                                                        "${widget.attr2}.\n\n",
                                                  ),
                                                  TextSpan(
                                                    text: widget.attr3,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
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
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: NewsScreen(
                                                idUserSession:
                                                    widget.idUserSession,
                                                idEntity: widget.idEntity,
                                                admin: widget.attr5!),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    55, 247, 199, 18),
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
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 18,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: ChatScreen(
                                                idEntity: widget.idEntity),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    55, 204, 49, 49),
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
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 18,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: ItineraryHome(
                                              idEntity: widget.idEntity,
                                              admin: widget.attr5,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    55, 56, 142, 60),
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
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 18,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                              ),
                                            ],
                                          ),
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
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              followOrUnfollow();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 0),
                                color: const Color.fromARGB(255, 19, 89, 168),
                                borderRadius: BorderRadius.circular(17.5)),
                            child: Padding(
                              padding: const EdgeInsets.all(1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 30, 0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check,
                                          size: 20,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Text(
                                          "Siguiendo",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromARGB(
                                                255, 227, 227, 227),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context, true);
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
                                padding:
                                    const EdgeInsets.fromLTRB(7.5, 0, 7.5, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        widget.attr2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
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
                                          color: Colors.blue
                                              .shade700, // Color de fondo azul
                                          shape:
                                              BoxShape.circle, // Forma circular
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 12,
                                            color: Colors
                                                .white, // Color del tick blanco
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        const Color.fromARGB(255, 196, 150, 11),
                                    showCloseIcon: false,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(17.5)),
                                    margin: const EdgeInsets.fromLTRB(
                                        15, 0, 15, 42.1),
                                    content: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 2, 0, 2.5),
                                      child: Text(
                                        "Primero debes seguir a la entidad",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(30)),
                                child: const Icon(
                                  Icons.people_alt_rounded,
                                  color: Color.fromARGB(255, 138, 138, 138),
                                ),
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
                                  height: 172.5,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color.fromARGB(
                                            255, 196, 150, 11),
                                        showCloseIcon: false,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(17.5)),
                                        margin: const EdgeInsets.fromLTRB(
                                            15, 0, 15, 42.1),
                                        content: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 2, 0, 2.5),
                                          child: Text(
                                            "Primero debes seguir a la entidad",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                            ),
                                          ),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .dividerColor,
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
                                                  const Icon(
                                                    Icons.newspaper_rounded,
                                                    size: 20,
                                                    color: Color.fromARGB(
                                                        255, 138, 138, 138),
                                                  ),
                                                  const SizedBox(
                                                    width: 17,
                                                  ),
                                                  Text(
                                                    "Noticias",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              138,
                                                              138,
                                                              138),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 18,
                                                color: Color.fromARGB(
                                                    255, 138, 138, 138),
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
                                                color: Theme.of(context)
                                                    .dividerColor,
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
                                                  const Icon(
                                                    Icons.chat,
                                                    size: 20,
                                                    color: Color.fromARGB(
                                                        255, 138, 138, 138),
                                                  ),
                                                  const SizedBox(
                                                    width: 17,
                                                  ),
                                                  Text(
                                                    "Chat",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              138,
                                                              138,
                                                              138),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 18,
                                                color: Color.fromARGB(
                                                    255, 138, 138, 138),
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
                                                color: Theme.of(context)
                                                    .dividerColor,
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
                                                  const Icon(
                                                    Icons.route_rounded,
                                                    size: 20,
                                                    color: Color.fromARGB(
                                                        255, 138, 138, 138),
                                                  ),
                                                  const SizedBox(
                                                    width: 17,
                                                  ),
                                                  Text(
                                                    "Itinerarios",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              138,
                                                              138,
                                                              138),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 18,
                                                color: Color.fromARGB(
                                                    255, 138, 138, 138),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              followOrUnfollow();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 0),
                                color: Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(17.5)),
                            child: Padding(
                              padding: const EdgeInsets.all(1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 30, 0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 20,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Text(
                                          "Seguir entidad",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromARGB(
                                                255, 227, 227, 227),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
