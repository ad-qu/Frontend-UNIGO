import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:unigo/models/challenge.dart';
import 'package:unigo/components/challenge/challenge_card.dart';
import 'package:unigo/pages/entity/itineraries/challenge_add.dart';

class ChallengeHome extends StatefulWidget {
  final String idItinerary;
  final String admin;

  const ChallengeHome({
    super.key,
    required this.idItinerary,
    required this.admin,
  });

  @override
  State<ChallengeHome> createState() => _ChallengeHomeState();
}

class _ChallengeHomeState extends State<ChallengeHome> {
  bool _isLoading = true;

  List<Challenge> challengeList = [];

  String? _idUser = "";

  @override
  void initState() {
    super.initState();

    getChallenges();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
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
                            AppLocalizations.of(context)!.challenges,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (widget.admin == _idUser)
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Theme.of(context).secondaryHeaderColor,
                                size: 27.5,
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.add,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
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
                            AppLocalizations.of(context)!.challenges,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleSmall?.color,
                              fontSize: 18,
                            ),
                          ),
                          if (widget.admin == _idUser)
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: ChallengeAdd(
                                        idItinerary: widget.idItinerary),
                                  ),
                                );
                                if (result == true) {
                                  getChallenges();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Theme.of(context).secondaryHeaderColor,
                                  size: 27.5,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.add,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                size: 27.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
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
                                        latitude: challengeList[index].latitude,
                                        longitude:
                                            challengeList[index].longitude,
                                        experience:
                                            challengeList[index].experience,
                                        idUser: _idUser!,
                                        admin: widget.admin,
                                        onChange: getChallenges,
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
                                height: MediaQuery.of(context).size.height / 2 +
                                    160,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center, // Centra el contenido verticalmente
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center, // Centra el contenido horizontalmente
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .itinerary_no_challenges,
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
                                            Icons.location_on_rounded,
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
                  ],
                ),
              ),
      ),
    );
  }
}
