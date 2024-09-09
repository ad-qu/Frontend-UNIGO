import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:unigo/models/news.dart';
import 'package:unigo/components/new/new_card.dart';
import 'package:unigo/pages/entity/entity_home.dart';
import 'package:unigo/pages/entity/news/news_add.dart';

class NewsScreen extends StatefulWidget {
  final String idUserSession;
  final String idEntity;
  final String admin;

  const NewsScreen({
    super.key,
    required this.idUserSession,
    required this.idEntity,
    required this.admin,
  });

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _isLoading = true;
  List<New> newsList = [];
  List<New> filteredNews = [];

  @override
  void initState() {
    super.initState();

    getNews();
  }

  Future<void> getNews() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";

    try {
      var response = await Dio().get(
        'http://${dotenv.env['API_URL']}/new/get/entityNews/${widget.idEntity}',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      var list = response.data as List;
      setState(() {
        newsList = list.map((news) => New.fromJson2(news)).toList();
        filteredNews = newsList;
        _isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
      setState(() {
        _isLoading = false; // Cambiamos el estado de carga a falso
      });
    }
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      filteredNews = newsList.where((news) {
        final lowerCaseKeyword = enteredKeyword.toLowerCase();
        return news.title.toLowerCase().startsWith(lowerCaseKeyword);
      }).toList();
    });
  }

  Future<void> _refreshNews() async {
    await getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Theme.of(context).secondaryHeaderColor,
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
                                cursorColor: Theme.of(context).splashColor,
                                cursorWidth: 1,
                                style: Theme.of(context).textTheme.labelMedium,
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.search_new,
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
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 18, 17, 17),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 12, 0),
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
                          if (widget.idUserSession == widget.admin)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Theme.of(context).secondaryHeaderColor,
                                  size: 30,
                                ),
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
                ),
              )
            : Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    // Barra superior de búsqueda
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 28, 47.5),
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
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Theme.of(context).secondaryHeaderColor,
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
                                cursorColor: Theme.of(context).splashColor,
                                cursorWidth: 1,
                                style: Theme.of(context).textTheme.labelMedium,
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.search_new,
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
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 18, 17, 17),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 12, 0),
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
                          if (widget.idUserSession == widget.admin)
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: NewsAddScreen(
                                        idEntity: widget.idEntity),
                                  ),
                                );
                                if (result == true) {
                                  getNews();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Mostrar noticias ya descargadas
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: CustomScrollView(
                          slivers: [
                            if (filteredNews.isNotEmpty)
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    try {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: NewCard(
                                          idUser: widget.idUserSession,
                                          idNew: filteredNews[index].idNew,
                                          admin: widget.admin,
                                          title: filteredNews[index].title,
                                          description:
                                              filteredNews[index].description,
                                          imageURL: filteredNews[index]
                                                  .imageURL
                                                  ?.toString() ??
                                              '',
                                          date: filteredNews[index].date,
                                          onChange: _refreshNews,
                                        ),
                                      );
                                    } catch (e) {
                                      return const SizedBox();
                                    }
                                  },
                                  childCount: filteredNews.length,
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
                                                  .no_news,
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
                                              Icons.newspaper_rounded,
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
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
