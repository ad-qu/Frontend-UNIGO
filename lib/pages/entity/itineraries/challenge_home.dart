// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/components/challenge/challenge_card.dart';
import 'package:unigo/components/itinerary/itinerary_card.dart';
import 'package:unigo/models/challenge%20(deprecated).dart';
import 'package:unigo/models/challenge.dart';
import 'package:unigo/models/entity.dart';
import 'package:unigo/models/itinerary.dart';
import 'package:unigo/pages/entity/entity_add.dart';
import 'package:unigo/pages/entity/entity_home.dart';
import 'package:unigo/pages/entity/entity_profile.dart';
import 'package:unigo/pages/entity/entity_search.dart';
import 'package:unigo/components/entity/entity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/pages/entity/itineraries/challenge_add.dart';
import 'package:unigo/pages/entity/itineraries/itinerary_add.dart';

void main() async {
  await dotenv.load();
}

class ChallengeHome extends StatefulWidget {
  final String idItinerary;

  const ChallengeHome({super.key, required this.idItinerary});

  @override
  State<ChallengeHome> createState() => _ChallengeHomeState();
}

class _ChallengeHomeState extends State<ChallengeHome> {
  late bool _isLoading;
  List<Challenge> challengeList = [];

  @override
  void initState() {
    _isLoading = true;
    Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
    getChallenges();
  }

  Future getChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/challenge/get/itineraryChallenges/${widget.idItinerary}';
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
      var list = response.data as List;

      setState(() {
        challengeList =
            list.map((challenge) => Challenge.fromJson2(challenge)).toList();
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error $e");
    }
  }

  Future<void> _refreshEntities() async {
    await getChallenges();
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
                      padding: const EdgeInsets.fromLTRB(15, 17.5, 15, 15),
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
                            "Retos (${challengeList.length})",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 227, 227, 227),
                              size: 27.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 13),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 277.5,
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
                        height: 277.5,
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
                      padding: const EdgeInsets.fromLTRB(15, 17.5, 15, 15),
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
                            "Retos (${challengeList.length})",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.bottomToTop,
                                  child: ChallengeAdd(
                                      idItinerary: widget.idItinerary),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color.fromARGB(255, 227, 227, 227),
                                size: 27.5,
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
                        onRefresh: _refreshEntities,
                        child: CustomScrollView(
                          slivers: [
                            if (challengeList.isNotEmpty)
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    try {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                        child: ChallengeCard(
                                          idChallenge:
                                              challengeList[index].idChallenge,
                                          name: challengeList[index].name,
                                          description:
                                              challengeList[index].description,
                                          latitude:
                                              challengeList[index].latitude,
                                          longitude:
                                              challengeList[index].longitude,
                                          experience:
                                              challengeList[index].experience,
                                        ),
                                      );
                                    } catch (e) {
                                      return const SizedBox();
                                    }
                                  },
                                  childCount: challengeList.length,
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
                                                    'No challenges were found\nPress ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              WidgetSpan(
                                                child: Icon(
                                                  Icons.add,
                                                  size:
                                                      16, // Ajusta el tamaño del ícono según sea necesario
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' to create a challenge',
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
