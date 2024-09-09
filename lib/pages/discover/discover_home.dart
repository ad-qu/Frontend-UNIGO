import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/user.dart';
import '../../components/profile_screen/user_card.dart';
import 'package:unigo/pages/discover/discover_search.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  bool _isLoading = true;
  List<User> followingList = [];
  String? _idUser = "";

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getFriends();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
  }

  Future getFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path = 'http://${dotenv.env['API_URL']}/user/following/$_idUser';

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

      List<dynamic> users;

      if (response.data is List) {
        users = response.data as List;
      } else if (response.data is Map) {
        var mapData = response.data as Map<String, dynamic>;
        users = mapData['users'] as List<dynamic>? ?? [];
      } else {
        users = [];
      }
      setState(() {
        followingList = users.map((user) => User.fromJson2(user)).toList();
        followingList =
            followingList.where((user) => user.active == true).toList();
        _isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 16.5, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.search,
                              size: 27,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).hoverColor,
                          strokeCap: StrokeCap.round,
                          strokeWidth: 5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).splashColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              )
            : Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 16.5, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const DiscoverSearchScreen(),
                                ),
                              );

                              if (result == true) {
                                getFriends();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.search,
                                size: 27,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          if (followingList.isNotEmpty)
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  try {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: MyUserCard(
                                        idUserSession: _idUser!,
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
                                        onRefresh: () {
                                          getFriends();
                                        },
                                      ),
                                    );
                                  } catch (e) {
                                    return const SizedBox();
                                  }
                                },
                                childCount: followingList.length,
                              ),
                            )
                          else
                            SliverToBoxAdapter(
                              child: Container(
                                height: MediaQuery.of(context).size.height / 2 +
                                    160,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .do_not_follow_accounts,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .shadowColor),
                                          ),
                                          const SizedBox(height: 16),
                                          Icon(
                                            Icons.polyline_rounded,
                                            size: 125,
                                            color:
                                                Theme.of(context).shadowColor,
                                          ),
                                          const SizedBox(height: 16),
                                          RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              style: GoogleFonts.inter(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .press,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                WidgetSpan(
                                                  child: Icon(
                                                    Icons.search,
                                                    size:
                                                        16, // Ajusta el tamaño del ícono según sea necesario
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .to_find_accounts,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
