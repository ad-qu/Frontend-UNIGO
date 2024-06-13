import 'package:dio/dio.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/pages/discover/discover_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/profile_screen/card_user_widget.dart';

void main() async {
  await dotenv.load();
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late bool _isLoading;
  List<User> followingList = [];
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
      var users = response.data as List;

      setState(() {
        followingList = users.map((user) => User.fromJson2(user)).toList();
        followingList =
            followingList.where((user) => user.active == true).toList();
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

  Future<void> _refreshFriends() async {
    await getFriends();
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
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const DiscoverSearchScreen(),
                                ),
                              );
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
                      child: RefreshIndicator(
                        displacement: 0,
                        backgroundColor: Theme.of(context).cardColor,
                        color: Theme.of(context).secondaryHeaderColor,
                        onRefresh: _refreshFriends,
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
                                          idCardUser:
                                              followingList[index].idUser,
                                          attr1: followingList[index]
                                                  .imageURL
                                                  ?.toString() ??
                                              '',
                                          attr2: followingList[index].username,
                                          attr3: followingList[index]
                                              .level
                                              .toString(),
                                          following: true,
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
                                  height:
                                      100, // Ajusta la altura según sea necesario
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: RichText(
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
                                                    'No accounts you follow were found\nPress ',
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
                                                text:
                                                    ' to find accounts to follow',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
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
                  ],
                ),
              ),
      ),
    );
  }
}
