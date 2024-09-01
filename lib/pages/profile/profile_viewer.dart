// ignore_for_file: library_private_types_in_public_api
import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/components/input_widgets/delete_account_button.dart';
import 'package:unigo/components/input_widgets/edit_account_button.dart';
import 'package:unigo/components/input_widgets/edit_password_button.dart';
import 'package:unigo/components/input_widgets/history_button.dart';
import 'package:unigo/components/input_widgets/log_out_button.dart';
import 'package:unigo/components/language/language_button.dart';
import 'package:unigo/components/theme/theme_provider.dart';
import 'package:unigo/pages/discover/discover_home.dart';
import 'package:unigo/pages/profile/history_home.dart';
import '../../models/user.dart' as user_ea;
import '../../components/profile_screen/user_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/pages/profile/edit_account.dart';
import 'package:unigo/pages/profile/edit_password.dart';

import '../../models/user.dart';

class ProfiletViewer extends StatefulWidget {
  final String idCardUser;
  final bool isFollowed;
  const ProfiletViewer({
    super.key,
    required this.idCardUser,
    required this.isFollowed,
  });

  @override
  _ProfiletViewerState createState() => _ProfiletViewerState();
}

class _ProfiletViewerState extends State<ProfiletViewer> {
  late bool _isLoading;
  String? _username = "";
  String? _idUser = "";
  String? _name = "";

  // ignore: unused_field
  String? _token = "";
  String? _followers = "";
  String? _following = "";
  int _level = 0;
  int _experience = 0;
  FirebaseAuth auth = FirebaseAuth.instance;
  String imageURL = "";
  bool? followParameter;

  @override
  void initState() {
    _isLoading = true;
    Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
    getUserInfo();
    getFriendsInfo();

    followParameter = widget.isFollowed;
  }

  Widget imageProfile() {
    return Stack(
      children: [
        SizedBox(
          height: 65,
          width: 65,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: imageURL.isEmpty
                  ? Image.asset(
                      'images/default.png',
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      imageURL,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // La imagen ha terminado de cargar
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(2.5),
                            child: Container(
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor, // Fondo mientras se carga la imagen
                              child: CircularProgressIndicator(
                                backgroundColor: Theme.of(context).hoverColor,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).splashColor),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          'images/default.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getUserInfo() async {
    print(widget.idCardUser);
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    _idUser = prefs.getString('idUser');

    String path =
        'http://${dotenv.env['API_URL']}/user/profile/${widget.idCardUser}';
    try {
      var response = await Dio().get(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      var u = json.decode(response.toString());
      print("111111111111111111111111");

      print(u);
      // Accede a los valores del mapa con las llaves correctas
      _username = u['username'];
      imageURL = u['imageURL'];
      _level = u['level'];
      _experience = u['experience'];
      _name = u['name'];
    } catch (e) {
      print("ERROR");
      print(e);
    }
  }

  Future getFriendsInfo() async {
    try {
      var followersCount = await Dio().get(
          'http://${dotenv.env['API_URL']}/user/followers/count/${widget.idCardUser}');
      if (mounted) {
        setState(() {
          _followers = followersCount.toString();
        });
      }

      var followingCount = await Dio().get(
          'http://${dotenv.env['API_URL']}/user/following/count/${widget.idCardUser}');
      if (mounted) {
        setState(() {
          _following = followingCount.toString();
        });
      }
    } catch (e) {
      print('Error in the counting of friends: $e');
    }
  }

  Future followOrUnfollow() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    try {
      if (followParameter == true) {
        await Dio().post(
          'http://${dotenv.env['API_URL']}/user/follow/delete/$_idUser/${widget.idCardUser}',
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
          'http://${dotenv.env['API_URL']}/user/follow/add/$_idUser/${widget.idCardUser}',
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

  seeHistory() async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: HistoryHome(idUser: widget.idCardUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 1080,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dotenv.env['VERSION']!,
                              style: GoogleFonts.inter(
                                color: Theme.of(context).dividerColor,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Icon(
                                    Icons.light_mode_rounded,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Icon(
                                    Icons.language_rounded,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 13),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 13),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(37.5),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 13),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 260,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(37.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: 1080,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.leftToRight,
                                    child: const DiscoverScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(30)),
                                child: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Color.fromARGB(255, 227, 227, 227),
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 17.5),
                                  child: imageProfile(),
                                ),
                                const SizedBox(width: 17.5),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13.5, top: 2),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('$_username',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall),
                                          const SizedBox(height: 10),
                                          Text(_name ?? '',
                                              textAlign: TextAlign.left,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 29),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0),
                                            child: Text(
                                                '${AppLocalizations.of(context)!.level} $_level',
                                                textAlign: TextAlign.left,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Establece los bordes redondeados
                                    child: LinearProgressIndicator(
                                      minHeight: 6.5,
                                      value: _experience.toDouble() / 100,
                                      backgroundColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      color: const Color.fromARGB(
                                          255, 247, 199, 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$_following\n${AppLocalizations.of(context)!.following}",
                                  // "$_following\nFollowing",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 100),
                                Text(
                                  "$_followers\n${AppLocalizations.of(context)!.followers}",
                                  // "$_followers\nFollowers",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 17.5),

                      //const SizedBox(height: 17.5),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        child: HistoryButton(
                            buttonText: "See history", onTap: seeHistory),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 10),
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                followOrUnfollow();
                              });
                            },
                            child: followParameter ?? false
                                ? Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            width: 0),
                                        color: const Color.fromARGB(
                                            255, 19, 89, 168),
                                        borderRadius:
                                            BorderRadius.circular(17.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 30, 0),
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
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            width: 0),
                                        color: Colors.blue.shade700,
                                        borderRadius:
                                            BorderRadius.circular(17.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 30, 0),
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
                                                  "Seguir",
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
                                  )),
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
