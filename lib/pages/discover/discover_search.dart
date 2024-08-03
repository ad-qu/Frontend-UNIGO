// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/pages/discover/discover_home.dart';
import 'package:unigo/pages/entity/entity_add.dart';
import 'package:unigo/pages/entity/entity_search.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../components/profile_screen/user_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  await dotenv.load();
}

class DiscoverSearchScreen extends StatefulWidget {
  const DiscoverSearchScreen({super.key});

  @override
  State<DiscoverSearchScreen> createState() => _DiscoverSearchScreenState();
}

class _DiscoverSearchScreenState extends State<DiscoverSearchScreen> {
  late bool _isLoading;
  List<User> notFriendsList = [];
  List<User> filteredUsers = [];
  String? _idUser = "";

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
    getNotFriends();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
  }

  Future getNotFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path = 'http://${dotenv.env['API_URL']}/user/unfollowing/$_idUser';
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

      setState(() {
        notFriendsList = users.map((user) => User.fromJson2(user)).toList();
        notFriendsList =
            notFriendsList.where((user) => user.active == true).toList();
        filteredUsers = notFriendsList;
      });
    } catch (e) {
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

  void _runFilter(String enteredKeyword) {
    setState(() {
      filteredUsers = notFriendsList.where((user) {
        final lowerCaseKeyword = enteredKeyword.toLowerCase();
        return user.username.toLowerCase().startsWith(lowerCaseKeyword) &&
            user.active == true;
      }).toList();
    });
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
                      padding: const EdgeInsets.fromLTRB(28, 20, 15, 47.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Color.fromARGB(255, 227, 227, 227),
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: TextFormField(
                                onChanged: (value) => _runFilter(value),
                                cursorColor:
                                    const Color.fromARGB(255, 222, 66, 66),
                                cursorWidth: 1,
                                style: Theme.of(context).textTheme.labelMedium,
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.filter_box,
                                  hintStyle: const TextStyle(
                                    color: Color.fromARGB(255, 138, 138, 138),
                                    fontSize: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 18, 17, 17),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  fillColor: Theme.of(context).cardColor,
                                  filled: true,
                                  suffixIcon: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                    child: Icon(
                                      Icons.search_rounded,
                                      size: 27,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 13),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 65,
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
                        height: 65,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(37.5),
                        ),
                      ),
                    ),
                  ],
                ))
            : Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 20, 15, 47.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const DiscoverScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Color.fromARGB(255, 227, 227, 227),
                                size: 25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: TextFormField(
                                onChanged: (value) => _runFilter(value),
                                cursorColor:
                                    const Color.fromARGB(255, 222, 66, 66),
                                cursorWidth: 1,
                                style: Theme.of(context).textTheme.labelMedium,
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.filter_box,
                                  hintStyle: const TextStyle(
                                    color: Color.fromARGB(255, 138, 138, 138),
                                    fontSize: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 18, 17, 17),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  fillColor: Theme.of(context).cardColor,
                                  filled: true,
                                  suffixIcon: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                    child: Icon(
                                      Icons.search_rounded,
                                      size: 27,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: CustomScrollView(
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  try {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: MyUserCard(
                                        idUserSession: _idUser!,
                                        idCardUser: filteredUsers[index].idUser,
                                        attr1: notFriendsList[index]
                                                .imageURL
                                                ?.toString() ??
                                            '',
                                        attr2: filteredUsers[index].username,
                                        attr3: filteredUsers[index]
                                            .level
                                            .toString(),
                                        following: false,
                                      ),
                                    );
                                  } catch (e) {
                                    return const SizedBox();
                                  }
                                },
                                childCount: filteredUsers.length,
                              ),
                            ),
                          ],
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
