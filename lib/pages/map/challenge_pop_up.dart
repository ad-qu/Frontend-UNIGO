import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:unigo/models/challenge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/pages/map/qr_screen.dart';

class ChallengePopUp extends StatefulWidget {
  final String? selectedChallengeId;
  final String? nameChallenge;
  final String? descrChallenge;
  final List<String>? questions;
  final String? expChallenge;
  final String? imageURL;

  const ChallengePopUp(
      {Key? key,
      this.selectedChallengeId,
      this.nameChallenge,
      this.descrChallenge,
      this.expChallenge,
      this.questions,
      this.imageURL})
      : super(key: key);

  @override
  State<ChallengePopUp> createState() => _ChallengePopUpState();
}

class _ChallengePopUpState extends State<ChallengePopUp> {
  Challenge? challenge;
  String? _token = "";
  String? _idChallenge = "";
  List<String>? _questions = [];
  String? _name = "";
  String? _descr = "";
  String? _expChallenge;
  // ignore: unused_field
  String? _exp = "";
  bool isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    getChallengeInfo().then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  Future<void> getChallengeInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _idChallenge = widget.selectedChallengeId;
      _questions = widget.questions;
      _name = widget.nameChallenge;
      _descr = widget.descrChallenge;
      _expChallenge = widget.expChallenge;
      _exp = prefs.getString('exp');
    });
  }

  Widget _buildChild(BuildContext context) {
    return Container(
      height: 485,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 30),
                  child: ClipOval(
                    child: (widget.imageURL == null || widget.imageURL!.isEmpty)
                        ? Image.asset(
                            height: 100,
                            width: 100,
                            'assets/images/challenge.png',
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            height: 100,
                            width: 100,
                            widget.imageURL!,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Container(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor:
                                          Theme.of(context).hoverColor,
                                      strokeCap: StrokeCap.round,
                                      strokeWidth: 5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).splashColor,
                                      ),
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              }
                            },
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return Image.asset(
                                'assets/images/challenge.png',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 3, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_rate_rounded,
                              color: Theme.of(context).highlightColor,
                              size: 14.5,
                            ),
                            const SizedBox(width: 5.5),
                            Text(
                              "${widget.expChallenge}",
                              style: TextStyle(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 7.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.5),
          Text(
            _name ?? '',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32.5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              _descr ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).splashColor,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyQR(
                                  idChallenge: _idChallenge ?? '',
                                  questions: _questions ?? [],
                                  expChallenge: _expChallenge ?? '',
                                )),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
