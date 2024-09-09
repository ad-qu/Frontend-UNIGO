import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/user.dart';
import '../../components/profile_screen/user_card.dart';

class FollowerScreen extends StatefulWidget {
  const FollowerScreen({
    super.key,
  });

  @override
  State<FollowerScreen> createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<FollowerScreen> {
  bool _isLoading = true;
  List<User> peopleList = [];
  List<User> filteredUsers = [];
  String? _idUser = "";

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getFollowing();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
  }

  Future getFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path = 'http://${dotenv.env['API_URL']}/user/followers/$_idUser';
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
        peopleList = users.map((user) => User.fromJson2(user)).toList();
        peopleList = peopleList.where((user) => user.active == true).toList();

        filteredUsers = peopleList;
        _isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
      setState(() {
        _isLoading = false; // Cambiamos el estado de carga a falso
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.followers,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              size: 27.5,
                            ),
                          )
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
                ))
            : Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
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
                          Text(
                            AppLocalizations.of(context)!.followers,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              size: 27.5,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: CustomScrollView(
                          slivers: [
                            if (peopleList.isNotEmpty)
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return IgnorePointer(
                                      ignoring:
                                          true, // Esto desactiva la interacción
                                      child: Padding(
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
                                          attr2: filteredUsers[index].username,
                                          attr3: filteredUsers[index]
                                              .level
                                              .toString(),
                                          following: false,
                                        ),
                                      ),
                                    );
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
                                                  .account_no_followers,
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
                                              Icons.people_alt_rounded,
                                              size: 125,
                                              color:
                                                  Theme.of(context).shadowColor,
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
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
