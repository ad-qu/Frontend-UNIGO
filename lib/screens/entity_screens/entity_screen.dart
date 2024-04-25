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

class EntityScreen extends StatefulWidget {
  const EntityScreen({super.key});

  @override
  State<EntityScreen> createState() => _EntityScreenState();
}

class _EntityScreenState extends State<EntityScreen> {
  List<Entity> entityList = [];
  List<User> notFriendsList = [];
  List<User> filteredUsers = [];
  String? _idUser = "";

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getEntities();
    //getNotFriends();
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

  Future getNotFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/user/friends/unfollowing/$_idUser';
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
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.add,
                      size: 30,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30)),
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
                                  idEntity: entityList[index].idEntity,
                                  attr1:
                                      entityList[index].imageURL?.toString() ??
                                          '',
                                  attr2: entityList[index].name,
                                  attr3: entityList[index].description,
                                  attr4: entityList[index].verified,
                                ),
                              );
                            } catch (e) {
                              return const SizedBox();
                            }
                          },
                          childCount: entityList.length,
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
