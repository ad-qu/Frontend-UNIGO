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
import '../../components/profile_screen/user_card.dart';
import '../../components/entity/entity_card.dart';
import 'entity_home.dart';

class EntitySearchScreen extends StatefulWidget {
  const EntitySearchScreen({super.key});

  @override
  State<EntitySearchScreen> createState() => _EntitySearchScreenState();
}

class _EntitySearchScreenState extends State<EntitySearchScreen> {
  bool _isLoading = true;
  List<Entity> unFollowingList = [];
  List<Entity> filteredEntities = [];
  String? _idUser;
  bool _isCampusFilterEnabled = true;
  String? _campus;

  @override
  void initState() {
    super.initState();
    getUserInfo();
    fetchEntities();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
      _campus = prefs.getString('campus');
      print("User Campus: $_campus");
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
        print("Entities fetched: ${unFollowingList.length}");
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
      filteredEntities = unFollowingList.where((entity) {
        final lowerCaseKeyword = enteredKeyword.toLowerCase();
        final matchesKeyword =
            entity.name.toLowerCase().startsWith(lowerCaseKeyword);
        final matchesCampus =
            _isCampusFilterEnabled ? (entity.campus == _campus) : true;
        print(
            "Entity: ${entity.name}, Matches Keyword: $matchesKeyword, Matches Campus: $matchesCampus"); // Debugging line
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
                        padding: const EdgeInsets.fromLTRB(28, 20, 28, 47.5),
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
                              if (filteredEntities.isNotEmpty)
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      try {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: EntityCard(
                                            idUserSession: _idUser!,
                                            idEntity: filteredEntities[index]
                                                .idEntity,
                                            attr1: filteredEntities[index]
                                                    .imageURL
                                                    ?.toString() ??
                                                '',
                                            attr2: filteredEntities[index].name,
                                            attr3: filteredEntities[index]
                                                .description,
                                            attr4: filteredEntities[index]
                                                .verified,
                                            attr5:
                                                filteredEntities[index].admin,
                                            isFollowed: false,
                                            onRefresh: () {
                                              fetchEntities(); // Call refresh on fetchEntities
                                            },
                                          ),
                                        );
                                      } catch (e) {
                                        return const SizedBox();
                                      }
                                    },
                                    childCount: filteredEntities.length,
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
                                                'No hay más\nentidades a mostrar',
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
                                                Icons.view_agenda_rounded,
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
                                                          ' para encontrar\nentidades de otros campus universitarios',
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
