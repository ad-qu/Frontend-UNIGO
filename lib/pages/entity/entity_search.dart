// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user.dart';
import '../../models/entity.dart';
import '../../components/profile_screen/card_user_widget.dart';
import '../../components/entity/entity_card.dart';
import 'entity_home.dart';

void main() async {
  await dotenv.load();
}

class EntitySearchScreen extends StatefulWidget {
  const EntitySearchScreen({super.key});

  @override
  State<EntitySearchScreen> createState() => _EntitySearchScreenState();
}

class _EntitySearchScreenState extends State<EntitySearchScreen> {
  late bool _isLoading;
  List<Entity> unFollowingList = [];
  List<Entity> filteredEntities = [];
  String? _idUser;

  @override
  void didChangeDependencies() {
    _isLoading = true;
    Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        _isLoading = false;
      });
    });
    super.didChangeDependencies();
    getUserInfo();
    fetchEntities();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
  }

  Future<void> fetchEntities() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";

    String unfollowingPath =
        'http://${dotenv.env['API_URL']}/entity/unfollowing/$_idUser';

    try {
      var unfollowingResponse = await Dio().get(
        unfollowingPath,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      var unfollowing = unfollowingResponse.data as List;

      setState(() {
        unFollowingList =
            unfollowing.map((entity) => Entity.fromJson2(entity)).toList();
        filteredEntities = unFollowingList;
        print("bbbbbbbbbbbbbbbbbbbbbbbbb");
      });
    } catch (e) {
      print("ccccc");
    }
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      filteredEntities = (unFollowingList).where((entity) {
        final lowerCaseKeyword = enteredKeyword.toLowerCase();
        return entity.name.toLowerCase().startsWith(lowerCaseKeyword);
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
                        height: 155,
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
                        height: 155,
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
                                  child: const EntityScreen(),
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
                                    final Entity currentEntity =
                                        filteredEntities[index];
                                    final bool isFollowed =
                                        filteredEntities.any((entity) =>
                                            entity.idEntity ==
                                            currentEntity.idEntity);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: EntityCard(
                                        idUserSession: _idUser!,
                                        idEntity: currentEntity.idEntity,
                                        attr1: currentEntity.imageURL
                                                ?.toString() ??
                                            '',
                                        attr2: filteredEntities[index].name,
                                        attr3: currentEntity.description,
                                        attr4: currentEntity.verified,
                                        attr5: currentEntity.admin,
                                        isFollowed: isFollowed,
                                      ),
                                    );
                                  } catch (e) {
                                    return const SizedBox();
                                  }
                                },
                                childCount: filteredEntities.length,
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
