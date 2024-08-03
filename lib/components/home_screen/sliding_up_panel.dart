import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unigo/components/challenge/challenge_card.dart';
import 'package:unigo/components/challenge/challenge_card_home.dart';
import 'package:unigo/components/home_screen/card_challenge_widget.dart';
import 'package:unigo/components/itinerary/itinerary_card.dart';
import 'package:unigo/components/itinerary/itinerary_card_home.dart';
import 'package:unigo/models/challenge.dart';
import 'package:unigo/models/itinerary.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await dotenv.load();
}

class SlidingUpPanelWidget extends StatefulWidget {
  const SlidingUpPanelWidget({
    super.key,
    required this.controller,
  });

  final ScrollController controller;

  @override
  State<SlidingUpPanelWidget> createState() => _SlidingUpPanelWidgetState();
}

class _SlidingUpPanelWidgetState extends State<SlidingUpPanelWidget> {
  String? _idUser;
  List<Itinerary> itineraryList = <Itinerary>[];
  List<Challenge> challengeList = <Challenge>[];
  List<Challenge> filteredChallengeList = <Challenge>[];
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getItineraries();
    getChallenges();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
  }

  Future<void> getItineraries() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/itinerary/get/userItineraries/$_idUser';
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
        itineraryList =
            list.map((itinerary) => Itinerary.fromJson2(itinerary)).toList();
      });
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> getChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path =
        'http://${dotenv.env['API_URL']}/challenge/get/availableChallenges/$_idUser';
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
      print("Error $e");
    }
  }

  void filterChallengesByItinerary(String itineraryId) {
    setState(() {
      filteredChallengeList = challengeList
          .where((challenge) => challenge.itinerary == itineraryId)
          .toList();
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildDragHandle(context) => GestureDetector(
        onTap: togglePanel,
        child: Center(
          child: Container(
            width: 75,
            height: 3.75,
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  void togglePanel() => PanelController().isPanelOpen
      ? PanelController().close()
      : PanelController().open();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            buildDragHandle(context),
            const SizedBox(height: 30),
            Divider(
              color: Theme.of(context).dividerColor,
              height: 0.05,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildItinerary(context, itineraryList, widget.controller,
                      _idUser, _pageController),
                  buildChallenge(context, filteredChallengeList,
                      widget.controller, _idUser, _pageController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItinerary(BuildContext context, List<Itinerary> itineraryList,
      ScrollController sc, String? idUser, PageController pageController) {
    return Column(
      children: [
        const SizedBox(height: 45),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Itinerarios ",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleSmall?.color,
                fontSize: 18,
              ),
            ),
            Text(
              "(${itineraryList.length})",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).textTheme.titleSmall?.color,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 37.5),
        Expanded(
          child: CustomScrollView(
            controller: sc,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          filterChallengesByItinerary(
                              itineraryList[index].idItinerary);
                        },
                        child: ItineraryCardHome(
                          idUser: idUser,
                          idItinerary: itineraryList[index].idItinerary,
                          name: itineraryList[index].name,
                          imageURL:
                              itineraryList[index].imageURL?.toString() ?? '',
                          entityAdmin: "",
                          number: itineraryList[index].number,
                        ),
                      );
                    },
                    childCount: itineraryList.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildChallenge(BuildContext context, List<Challenge> challengeList,
      ScrollController sc, String? idUser, PageController pageController) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Row(
          children: [
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 70, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Retos ",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleSmall?.color,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "(${filteredChallengeList.length})",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).textTheme.titleSmall?.color,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Expanded(
          child: CustomScrollView(
            controller: sc,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: ChallengeCardHome(
                          idChallenge: challengeList[index].idChallenge,
                          name: challengeList[index].name,
                          description: challengeList[index].description,
                          latitude: challengeList[index].latitude,
                          longitude: challengeList[index].longitude,
                          question: challengeList[index].question,
                          experience: challengeList[index].experience,
                          itinerary: challengeList[index].itinerary,
                          imageURL: challengeList[index].imageURL,
                        ),
                      );
                    },
                    childCount: challengeList.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
