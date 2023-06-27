import 'package:dio/dio.dart';
import 'package:ea_frontend/mobile/home_screen/qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/challenge.dart';

class MyChallengePage extends StatefulWidget {
  final String? selectedChallengeId;
  final String? nameChallenge;
  final String? descrChallenge;
  final List<String>? questions;
  final String? expChallenge;

  const MyChallengePage(
      {Key? key,
      this.selectedChallengeId,
      this.nameChallenge,
      this.descrChallenge,
      this.expChallenge,
      this.questions})
      : super(key: key);

  @override
  State<MyChallengePage> createState() => _MyChallengePageState();
}

class _MyChallengePageState extends State<MyChallengePage> {
  Challenge? challenge;
  String? _token = "";
  String? _idChallenge = "";
  List<String>? _questions = [];
  String? _name = "";
  String? _descr = "";
  String? _expChallenge;
  String? _exp = "";
  bool isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    getChallengeInfo().then((_) {
      callApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Future<void> callApi() async {
    String path =
        'http://${dotenv.env['API_URL']}/challenge/get/${widget.selectedChallengeId}';
    
    var response = await Dio().get(
      path,
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      ),
    );
    var challengeData = response.data;
    var challenge = Challenge.fromJson(challengeData);
    setState(() {
      this.challenge = challenge;
    });
  }

  Widget _buildChild(BuildContext context) {
    if (challenge == null) {
      // Muestra un indicador de carga mientras se obtiene la información del desafío
      return const CircularProgressIndicator();
    } else {
      // Muestra la información del desafío
      return Container(
        height: 485,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 25, 25, 25),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 30),
                    child: Image.asset(
                      'images/marker_advanced.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 3, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: Color.fromARGB(255, 248, 188, 6),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            _expChallenge ?? '',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 25, 25, 25),
                              fontSize: 14,
                            ),
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
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                _descr ?? '',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.justify,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.5),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isButtonPressed = true;
                      });
                      print('Questions: $_questions');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyQR(
                                  idChallenge: _idChallenge ?? '',
                                  questions: _questions ?? [],
                                  expChallenge: _expChallenge ?? '',
                                )),
                      );
                      //Navigator.pushNamed(context, '/qr_screen');
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color.fromARGB(255, 222, 66, 66),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 24,
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
}
