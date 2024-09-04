// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/components/itinerary/itinerary_card.dart';
import 'package:unigo/models/entity.dart';
import 'package:unigo/pages/entity/entity_add.dart';
import 'package:unigo/pages/entity/entity_search.dart';
import 'package:unigo/components/entity/entity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntityScreen extends StatefulWidget {
  const EntityScreen({super.key});

  @override
  State<EntityScreen> createState() => _EntityScreenState();
}

class _EntityScreenState extends State<EntityScreen> {
  bool _isLoading = true;
  List<Entity> entityList = [];
  String? _idUser = "";

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getEntities();
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

      print(
          "Response data: ${response.data}"); // Imprime la respuesta para verificar

      if (response.data is List) {
        var following = response.data as List;
        setState(() {
          entityList =
              following.map((entities) => Entity.fromJson2(entities)).toList();
          _isLoading = false;
        });
      } else if (response.data is Map) {
        // Maneja el caso cuando la respuesta es un mapa
        var mapData = response.data as Map<String, dynamic>;
        print("Map data: $mapData"); // Imprime el mapa para verificar
        // Ajusta esto según la estructura de tu mapa
        if (mapData.containsKey('entities') && mapData['entities'] is List) {
          var following = mapData['entities'] as List;
          setState(() {
            entityList = following
                .map((entities) => Entity.fromJson2(entities))
                .toList();
            _isLoading = false;
          });
        } else {
          // Maneja el caso cuando la respuesta del mapa no tiene la clave 'entities'
          setState(() {
            entityList = [];
            _isLoading = false;
          });
        }
      } else {
        // Maneja el caso cuando la respuesta no es ni una lista ni un mapa
        setState(() {
          entityList = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        entityList = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshEntities() async {
    await getEntities();
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
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
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
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.bottomToTop,
                                  child: const EntityAddScreen(),
                                ),
                              );
                              if (result == true) {
                                print(
                                    "Entity created successfully, updating list.");
                                setState(() {
                                  getEntities();
                                });
                              } else {
                                print(
                                    "Entity creation failed or was canceled.");
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
                                size: 30,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const EntitySearchScreen(),
                                ),
                              );
                              if (result == true) {
                                _refreshEntities(); // Refresh entities when coming back
                              }
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
                      child: CustomScrollView(
                        slivers: [
                          if (entityList.isNotEmpty)
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  try {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: EntityCard(
                                        idUserSession: _idUser!,
                                        idEntity: entityList[index].idEntity,
                                        attr1: entityList[index]
                                                .imageURL
                                                ?.toString() ??
                                            '',
                                        attr2: entityList[index].name,
                                        attr3: entityList[index].description,
                                        attr4: entityList[index].verified,
                                        attr5: entityList[index].admin,
                                        isFollowed: true,
                                        onRefresh: () {
                                          getEntities();
                                        },
                                      ),
                                    );
                                  } catch (e) {
                                    return const SizedBox();
                                  }
                                },
                                childCount: entityList.length,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'No sigues\nninguna entidad',
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
                                            color:
                                                Theme.of(context).shadowColor,
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
                                                  text: 'Presiona ',
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
                                                      ' para buscar entidades',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
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
                                                  text: 'o presiona ',
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
                                                  text: ' para crear una',
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
                  ],
                ),
              ),
      ),
    );
  }
}
