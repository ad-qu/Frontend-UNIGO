import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unigo/components/home_screen/card_challenge_widget.dart';
import 'package:unigo/components/itinerary/itinerary_card.dart';
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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    getUserInfo();
    getItineraries();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
  }

  Future getItineraries() async {
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
      // ignore: avoid_print
      print("Error $e");
    }
  }

  Widget buildDragHandle(context) => GestureDetector(
        onTap: togglePanel,
        child: Center(
          child: Container(
            width: 150,
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
            const SizedBox(height: 25),
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  buildItinerary(context, itineraryList, widget.controller,
                      _idUser, _pageController),
                  buildChallenge(context, itineraryList, widget.controller,
                      _idUser, _pageController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@override
Widget buildItinerary(BuildContext context, List<Itinerary> itineraryList,
    ScrollController sc, idUser, PageController pageController) {
  return CustomScrollView(
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
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: ItineraryCard(
                    idUser: idUser,
                    entityAdmin: "",
                    idItinerary: itineraryList[index].idItinerary,
                    name: itineraryList[index].name,
                    imageURL: itineraryList[index].imageURL?.toString() ?? '',
                    number: itineraryList[index].number,
                  ));
            },
            childCount: itineraryList.length,
          ),
        ),
      ),
    ],
  );
}

@override
Widget buildChallenge(BuildContext context, List<Itinerary> itineraryList,
    ScrollController sc, idUser, PageController pageController) {
  return CustomScrollView(
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
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 54,
                  height: 59,
                  color: Colors.amber,
                ),
              );
            },
            childCount: itineraryList.length,
          ),
        ),
      ),
    ],
  );
}

getChallengeInfo(String idChallenge) async {
  final prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('token') ?? "";

  String path = 'http://${dotenv.env['API_URL']}/challenge/get/$idChallenge';
  var response = await Dio().get(path,
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }));
  return response.data;
}
