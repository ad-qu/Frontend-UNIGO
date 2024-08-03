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
import 'package:unigo/components/input_widgets/log_out_button.dart';
import 'package:unigo/components/language/language_button.dart';
import 'package:unigo/components/theme/theme_provider.dart';
import 'package:unigo/pages/discover/discover_home.dart';
import '../../models/user.dart' as user_ea;
import '../../components/profile_screen/user_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/pages/profile/edit_account.dart';
import 'package:unigo/pages/profile/edit_password.dart';

import '../../models/user.dart';

class ProfiletViewer extends StatefulWidget {
  final String idCardUser;
  const ProfiletViewer({
    super.key,
    required this.idCardUser,
  });

  @override
  _ProfiletViewerState createState() => _ProfiletViewerState();
}

class _ProfiletViewerState extends State<ProfiletViewer> {
  late bool _isLoading;
  String? _username = "";
  // ignore: unused_field
  String? _token = "";
  String? _followers = "";
  String? _following = "";
  int _level = 0;
  int _experience = 0;
  bool _seeFollowing = false;
  bool _seeFollowers = false;
  bool _seeOptions = true;
  List<user_ea.User> followingList = [];
  List<user_ea.User> followersList = [];
  List<dynamic> insigniasList = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  String imageURL = "";
  bool _isFollowingHighlighted = false;
  bool _isFollowersHighlighted = false;

  final TextStyle _highlightedText = const TextStyle(
      color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18);

  // ignore: prefer_const_constructors
  late TextStyle _normalText;
  late TextStyle _textStyleFollowers;
  late TextStyle _textStyleFollowing;

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
    getFollowing();
    getFollowers();
    getInsignias();
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

  Future getInsignias() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/user/get/insignia/${widget.idCardUser}';
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
      var insignias = response.data as List;
      setState(() {
        insigniasList = insignias;
      });
    } catch (e) {
      print('Error in insignias: $e');
    }
    print("He fet les insignies");
  }

  Future getFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/user/following/${widget.idCardUser}';
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
      var users = response.data as List;
      if (mounted) {
        setState(() {
          followingList =
              users.map((user) => user_ea.User.fromJson2(user)).toList();
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   elevation: 0,
      //   behavior: SnackBarBehavior.floating,
      //   backgroundColor: Colors.transparent,
      //   content: AwesomeSnackbarContent(
      //     title: 'Unable! $e',
      //     message: 'Try again later.',
      //     contentType: ContentType.failure,
      //   ),
      // ));
    }
  }

  Future getFollowers() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/user/followers/${widget.idCardUser}';
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
      var users = response.data as List;
      if (mounted) {
        setState(() {
          followersList =
              users.map((user) => user_ea.User.fromJson2(user)).toList();
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   elevation: 0,
      //   behavior: SnackBarBehavior.floating,
      //   backgroundColor: Colors.transparent,
      //   content: AwesomeSnackbarContent(
      //     title: 'Unable! $e',
      //     message: 'Try again later.',
      //     contentType: ContentType.failure,
      //   ),
      // ));
    }
  }

  void nothingDo() {}

  Widget showBadges() {
    print("Estic al podium");

    if (insigniasList.isEmpty) {
      return SizedBox(
        height: 10,
      );
    } else {
      return SizedBox(
        height: 37.5,
        width: insigniasList.length * 45.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: false,
          itemCount: insigniasList.length,
          itemBuilder: (BuildContext context, int index) {
            try {
              return Row(
                children: [
                  CircleAvatar(
                    radius: 17.5,
                    backgroundImage:
                        AssetImage('images/' + insigniasList[index] + '.png'),
                  ),
                  SizedBox(width: 5),
                ],
              );
            } catch (e) {
              return SizedBox();
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _normalText = TextStyle(
      color: MediaQuery.of(context).platformBrightness == Brightness.light
          ? Colors.black
          : Colors.white,
      fontWeight: FontWeight.normal,
      fontSize: 18,
    );

    _textStyleFollowers = _normalText;
    _textStyleFollowing =
        _isFollowingHighlighted ? _highlightedText : _normalText;
    _textStyleFollowers =
        _isFollowersHighlighted ? _highlightedText : _normalText;

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
                                          Text('Creada el 19/06/2024',
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
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 2.0),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: showBadges(),
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
                                GestureDetector(
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        _seeFollowing = !_seeFollowing;
                                        if (_seeFollowing) {
                                          _seeOptions = false;
                                          _isFollowingHighlighted = true;
                                          _isFollowersHighlighted = false;
                                          _seeFollowers = false;
                                        } else {
                                          _seeOptions = true;
                                          _isFollowingHighlighted = false;
                                        }
                                      });
                                    }
                                  },
                                  child: Text(
                                    "$_following\n${AppLocalizations.of(context)!.following}",
                                    // "$_following\nFollowing",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(width: 100),
                                GestureDetector(
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        _seeFollowers = !_seeFollowers;
                                        if (_seeFollowers) {
                                          _seeOptions = false;
                                          _isFollowersHighlighted = true;
                                          _isFollowingHighlighted = false;
                                          _seeFollowing = false;
                                        } else {
                                          _seeOptions = true;
                                          _isFollowersHighlighted = false;
                                        }
                                      });
                                    }
                                  },
                                  child: Text(
                                    "$_followers\n${AppLocalizations.of(context)!.followers}",
                                    // "$_followers\nFollowers",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            // Following scroll page
                            Visibility(
                              visible:
                                  _seeFollowing, // not visible if set false
                              child: SizedBox(
                                height: 325,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: followingList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    try {
                                      return MyUserCard(
                                        idUserSession: "",
                                        idCardUser: followingList[index].idUser,
                                        attr1: followingList[index]
                                                .imageURL
                                                ?.toString() ??
                                            '',
                                        attr2: followingList[index].username,
                                        attr3: followingList[index]
                                            .level
                                            .toString(),
                                        following: true,
                                      );
                                    } catch (e) {
                                      return const SizedBox();
                                    }
                                  },
                                ),
                              ),
                            ),
                            // Followers scroll view
                            Visibility(
                              visible:
                                  _seeFollowers, // not visible if set false
                              child: SizedBox(
                                height: 325,
                                child: ListView.builder(
                                  itemCount: followersList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    try {
                                      return MyUserCard(
                                        idUserSession: "",
                                        idCardUser: followersList[index].idUser,
                                        attr1: followingList[index]
                                                .imageURL
                                                ?.toString() ??
                                            '',
                                        attr2: followersList[index].username,
                                        attr3: followersList[index]
                                            .level
                                            .toString(),
                                        following: true,
                                      );
                                    } catch (e) {
                                      return const SizedBox(); // Return an empty SizedBox if the index is out of range
                                    }
                                  },
                                ),
                              ),
                            ),

                            Visibility(
                              visible: _seeOptions,
                              child: Column(
                                children: [
                                  const SizedBox(height: 17.5),

                                  //const SizedBox(height: 17.5),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    child: EditAccountButton(
                                        buttonText: "See history",
                                        onTap: nothingDo),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    child: EditPasswordButton(
                                        buttonText: "See badges",
                                        onTap: nothingDo),
                                  ),
                                  const SizedBox(height: 38),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    child: DeleteAccountButton(
                                        buttonText: "//", onTap: nothingDo),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    child: LogOutButton(
                                        buttonText: "Follow", onTap: nothingDo),
                                  ),
                                ],
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
    );
  }
}
