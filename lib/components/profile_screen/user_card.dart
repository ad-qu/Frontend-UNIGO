// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/pages/profile/profile_viewer.dart';

void main() async {
  await dotenv.load();
}

class MyUserCard extends StatefulWidget {
  final String idUserSession;
  final String idCardUser;
  final String attr1;
  final String attr2;
  final String attr3;
  final bool following;

  const MyUserCard(
      {Key? key,
      required this.idUserSession, //the id in shared preferences
      required this.idCardUser, //the id of the user that appears in the card
      required this.attr1, //photo url of the user
      required this.attr2, //username
      required this.attr3, //exp or level of the user
      required this.following //if true it means that the user is following the one it has started session
      })
      : super(key: key);

  @override
  State<MyUserCard> createState() => _MyUserCardState();
}

class _MyUserCardState extends State<MyUserCard> {
  late String buttonText;
  late bool isFollowing;

  @override
  void initState() {
    super.initState();
    setFollowingState();
  }

  void setFollowingState() {
    isFollowing = widget.following;
  }

  Future<void> followOrUnfollow() async {
    if (!isFollowing) {
      await startFollowing();
    } else {
      await stopFollowing();
    }
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  Future<void> startFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/user/follow/add/${widget.idUserSession}/${widget.idCardUser}';
    try {
      var response = await Dio().post(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 222, 66, 66),
          showCloseIcon: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
          content: const Text(
            'Unable to unfollow. Try again later',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> stopFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/user/follow/delete/${widget.idUserSession}/${widget.idCardUser}';
    try {
      var response = await Dio().post(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 222, 66, 66),
          showCloseIcon: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
          content: const Text(
            'Unable to unfollow. Try again later',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ProfiletViewer(idCardUser: widget.idCardUser),
                ),
              );
            },
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border:
                    Border.all(color: Theme.of(context).dividerColor, width: 1),
                borderRadius: BorderRadius.circular(35),
              ),
              width: MediaQuery.of(context).size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    width: 58,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
                      child: ClipOval(
                        child: widget.attr1.isEmpty
                            ? Image.asset(
                                'images/default.png',
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
                                    'images/default.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.attr2.length > 12
                                ? '${widget.attr2.substring(0, 12)}...'
                                : widget.attr2,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            'Level ${widget.attr3}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
