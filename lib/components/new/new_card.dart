import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unigo/pages/entity/news/news_viewer.dart';

class NewCard extends StatefulWidget {
  final String idUser;
  final String idNew;
  final String admin;
  final String title;
  final String description;
  final String? imageURL;
  final String date;
  final VoidCallback onChange;

  const NewCard({
    super.key,
    required this.idUser,
    required this.idNew,
    required this.admin,
    required this.title,
    required this.description,
    required this.imageURL,
    required this.date,
    required this.onChange,
  });

  @override
  State<NewCard> createState() => _NewCardState();
}

class _NewCardState extends State<NewCard> {
  late String buttonText;
  late bool isFollowing;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: NewsViewer(
              idUser: widget.idUser,
              idNew: widget.idNew,
              admin: widget.admin,
              title: widget.title,
              description: widget.description,
              imageURL: widget.imageURL,
              date: widget.date,
              onChange: widget.onChange,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 10),
        child: Container(
          height:
              widget.imageURL == null || widget.imageURL!.isEmpty ? 200 : 350,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              widget.title,
                              style: Theme.of(context).textTheme.titleSmall,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 7, 30, 20),
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.labelMedium,
                        children: [
                          TextSpan(
                            text: widget.description,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.imageURL != null && widget.imageURL!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 130,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.imageURL!,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: 350,
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor,
                                borderRadius: BorderRadius.circular(17.5),
                              ),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 130,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('images/new.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          );
                        },
                      ),
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
