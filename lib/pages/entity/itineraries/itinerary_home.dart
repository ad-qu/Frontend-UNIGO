// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/components/itinerary/itinerary_card.dart';
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
import 'package:unigo/pages/entity/itineraries/itinerary_add.dart';

void main() async {
  await dotenv.load();
}

class ItineraryHome extends StatefulWidget {
  final String idEntity;
  final String? admin;

  const ItineraryHome({super.key, required this.idEntity, required this.admin});

  @override
  State<ItineraryHome> createState() => _ItineraryHomeState();
}

class _ItineraryHomeState extends State<ItineraryHome> {
  late bool _isLoading;
  List<Itinerary> itineraryList = [];
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
        'http://${dotenv.env['API_URL']}/itinerary/get/entityItineraries/${widget.idEntity}';
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

  Future<void> _refreshEntities() async {
    await getItineraries();
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
                            "Itinerarios (${itineraryList.length})",
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
                            "Itinerarios (${itineraryList.length})",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.bottomToTop,
                                  child:
                                      ItineraryAdd(idEntity: widget.idEntity),
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
                            if (itineraryList.isNotEmpty)
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    try {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                        child: ItineraryCard(
                                          idUser: _idUser,
                                          entityAdmin: widget.admin,
                                          idItinerary:
                                              itineraryList[index].idItinerary,
                                          name: itineraryList[index].name,
                                          description:
                                              itineraryList[index].description,
                                          imageURL: itineraryList[index]
                                                  .imageURL
                                                  ?.toString() ??
                                              '',
                                          number: itineraryList[index].number,
                                        ),
                                      );
                                    } catch (e) {
                                      return const SizedBox();
                                    }
                                  },
                                  childCount: itineraryList.length,
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
                                                    'No itineraries were found\nPress ',
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
                                                text: ' to create an itinerary',
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
