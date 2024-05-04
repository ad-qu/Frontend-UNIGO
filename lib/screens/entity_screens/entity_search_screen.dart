// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unigo/models/entity.dart';
import 'package:unigo/widgets/entity_screen/card_entity.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../widgets/profile_screen/card_user_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  await dotenv.load();
}

class EntitySearchScreen extends StatefulWidget {
  const EntitySearchScreen({super.key});

  @override
  State<EntitySearchScreen> createState() => _EntitySearchScreenState();
}

class _EntitySearchScreenState extends State<EntitySearchScreen> {
  List<Entity> entityList = [];
  List<Entity> notFollowedEntityList = [];
  List<Entity> filteredEntities = [];
  String? _idUser = "";

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getEntities();
    getNotFollowedEntities();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
  }

  Future getEntities() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path = 'http://${dotenv.env['API_URL']}/entity/following/$_idUser';
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

      var following = response.data as List;

      setState(() {
        entityList =
            following.map((entities) => Entity.fromJson2(entities)).toList();
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

  Future getNotFollowedEntities() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path = 'http://${dotenv.env['API_URL']}/entity/unfollowing/$_idUser';
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

      var entities = response.data as List;

      setState(() {
        notFollowedEntityList =
            entities.map((entity) => Entity.fromJson2(entity)).toList();
        notFollowedEntityList = notFollowedEntityList.toList();
        filteredEntities = notFollowedEntityList + entityList;
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
      filteredEntities = (notFollowedEntityList + entityList).where((entity) {
        final lowerCaseKeyword = enteredKeyword.toLowerCase();
        return entity.name.toLowerCase().startsWith(lowerCaseKeyword);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: TextFormField(
                          onChanged: (value) => _runFilter(value),
                          cursorColor: const Color.fromARGB(255, 222, 66, 66),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 25, 25, 25)),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.filter_box,
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 146, 146, 146)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(18.5, 14, 0, 0),
                            suffixIcon: Icon(
                              Icons.search_rounded,
                              color: Color.fromARGB(255, 222, 66, 66),
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
                                child: MyEntityCard(
                                  idUserSession: _idUser!,
                                  idEntity: filteredEntities[index].idEntity,
                                  attr1: filteredEntities[index]
                                          .imageURL
                                          ?.toString() ??
                                      '',
                                  attr2: filteredEntities[index].name,
                                  attr3: filteredEntities[index].description,
                                  attr4: filteredEntities[index].verified,
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
