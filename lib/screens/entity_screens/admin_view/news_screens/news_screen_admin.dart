// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unigo/models/new.dart';
import 'package:unigo/screens/entity_screens/entity_screen.dart';

void main() async {
  await dotenv.load();
}

class NewsScreen extends StatefulWidget {
  final String idEntity;

  const NewsScreen({
    super.key,
    required this.idEntity,
  });

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late bool _isLoading;
  List<New> newsList = [];
  List<New> filteredNews = [];

  @override
  void didChangeDependencies() {
    _isLoading = true;
    Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        _isLoading = false;
      });
    });
    super.didChangeDependencies();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    try {
      var newsResponse = await Dio().get(
        'http://${dotenv.env['API_URL']}/new/get/entityNews/${widget.idEntity}',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      var news = newsResponse.data as List;

      setState(() {
        print("asdasdasdasdadadasdasdad");
        newsList = news.map((news) => New.fromJson2(news)).toList();

        print("bbbbbbbbbbbbbbbbbbbbbbbbb");
      });
    } catch (e) {
      print("ccccc");
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
                      padding: const EdgeInsets.fromLTRB(28, 20, 15, 47.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Color.fromARGB(255, 227, 227, 227),
                              size: 25,
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
                                cursorColor:
                                    const Color.fromARGB(255, 222, 66, 66),
                                cursorWidth: 1,
                                style: Theme.of(context).textTheme.labelMedium,
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.filter_box,
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
                          const SizedBox(width: 25),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 227, 227, 227),
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 13),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
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
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(37.5),
                        ),
                      ),
                    ),
                  ],
                ))
            : Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 20, 28, 47.5),
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
                              child: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Color.fromARGB(255, 227, 227, 227),
                                size: 25,
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
                                cursorColor:
                                    const Color.fromARGB(255, 222, 66, 66),
                                cursorWidth: 1,
                                style: Theme.of(context).textTheme.labelMedium,
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.filter_box,
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
                          const SizedBox(width: 25),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 227, 227, 227),
                              size: 30,
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
                                    // return Padding(
                                    //   padding: const EdgeInsets.symmetric(
                                    //       horizontal: 16.0),
                                    //   child: MyNewCard(
                                    //     idEntity: filteredNews.idEntity,
                                    //     attr1:
                                    //         filteredNews.imageURL?.toString() ??
                                    //             '',
                                    //     attr2: filteredNews[index].name,
                                    //     attr3: filteredNews.description,
                                    //     attr4: filteredNews.verified,
                                    //     attr5: filteredNews.admin,
                                    //   ),
                                    // );
                                  } catch (e) {
                                    return const SizedBox();
                                  }
                                },
                                childCount: filteredNews.length,
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
