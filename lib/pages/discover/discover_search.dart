// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
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

class DiscoverSearchScreen extends StatefulWidget {
  const DiscoverSearchScreen({super.key});

  @override
  State<DiscoverSearchScreen> createState() => _DiscoverSearchScreenState();
}

class _DiscoverSearchScreenState extends State<DiscoverSearchScreen> {
  bool _isLoading = true;
  List<User> notFriendsList = [];
  List<User> filteredUsers = [];
  String? _idUser = "";
  String? _campus = "";
  bool _isCampusFilterEnabled = true;

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getNotFriends();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
      _campus = prefs.getString('campus');
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
        print("Entities fetched: ${filteredUsers.length}");
        _isLoading = false;
        _runFilter("");
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      filteredUsers = notFriendsList.where((user) {
        final lowerCaseKeyword = enteredKeyword.toLowerCase();
        final matchesKeyword =
            user.username.toLowerCase().startsWith(lowerCaseKeyword) &&
                user.active == true;
        final matchesCampus =
            _isCampusFilterEnabled ? (user.campus == _campus) : true;
        print(
            "User: ${user.name}, Matches Keyword: $matchesKeyword, Matches Campus: $matchesCampus"); // Debugging line
        return matchesKeyword && matchesCampus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.pop(context, true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                                  cursorColor:
                                      const Color.fromARGB(255, 222, 66, 66),
                                  cursorWidth: 1,
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .filter_box,
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
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20, 18, 17, 17),
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
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 12, 0),
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
                        padding: const EdgeInsets.fromLTRB(28, 20, 28, 47.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context, true);
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
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .filter_box,
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
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20, 18, 17, 17),
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
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 12, 0),
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
                            const SizedBox(width: 25),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isCampusFilterEnabled =
                                      !_isCampusFilterEnabled;
                                  _runFilter(""); // Apply filter when toggle
                                });
                              },
                              child: Icon(
                                _isCampusFilterEnabled
                                    ? Icons.filter_alt_rounded
                                    : Icons.filter_alt_off_rounded,
                                color: Theme.of(context).secondaryHeaderColor,
                                size: 25,
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
                              if (filteredUsers.isNotEmpty)
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      try {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: MyUserCard(
                                            idUserSession: _idUser!,
                                            idCardUser:
                                                filteredUsers[index].idUser,
                                            attr1: filteredUsers[index]
                                                    .imageURL
                                                    ?.toString() ??
                                                '',
                                            attr2:
                                                filteredUsers[index].username,
                                            attr3: filteredUsers[index]
                                                .level
                                                .toString(),
                                            following: false,
                                            onRefresh: () {
                                              getNotFriends();
                                            },
                                          ),
                                        );
                                      } catch (e) {
                                        return const SizedBox();
                                      }
                                    },
                                    childCount: filteredUsers.length,
                                  ),
                                )
                              else
                                SliverToBoxAdapter(
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2 +
                                            160,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'No hay más\ncuentas a mostrar',
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
                                                color: Theme.of(context)
                                                    .shadowColor,
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
                                                      text:
                                                          'Prueba a presionar ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium,
                                                    ),
                                                    WidgetSpan(
                                                      child: Icon(
                                                        Icons.filter_list_alt,
                                                        size:
                                                            16, // Ajusta el tamaño del ícono según sea necesario
                                                        color: Theme.of(context)
                                                            .secondaryHeaderColor,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          ' para encontrar\ncuentas de otros campus universitarios',
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
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
