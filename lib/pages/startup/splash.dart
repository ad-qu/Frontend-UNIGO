// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:unigo/pages/startup/welcome.dart';
import 'package:unigo/pages/navbar.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';

void main() async {
  await dotenv.load();
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    // Esperar 2000 milisegundos (2 segundos)
    await Future.delayed(const Duration(milliseconds: 2000), () {});

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString("idUser");
    String? email = prefs.getString("email");
    String? password = prefs.getString("password");

    if (username == null) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const WelcomeScreen(),
        ),
      );
    } else {
      var response = await Dio().post(
        'http://${dotenv.env['API_URL']}/auth/login',
        data: {"email": email, "password": password},
      );
      if (response.toString() == "NOT_FOUND_USER") {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const WelcomeScreen(),
          ),
        );
      } else {
        Map<String, dynamic> payload = Jwt.parseJwt(response.toString());
        User u = User.fromJson(payload);
        var data = json.decode(response.toString());
        prefs.setString('token', data['token']);
        prefs.setString('idUser', u.idUser);
        prefs.setString('name', u.name);
        prefs.setString('surname', u.surname);
        prefs.setString('username', u.username);

        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const NavBar(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Agregue el color de fondo aquí
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/icon/logo.png',
                    height: 100,
                  ),
                ],
              ),
            ),
            CircularProgressIndicator(
                backgroundColor: Theme.of(context).hoverColor,
                strokeCap: StrokeCap.round,
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).splashColor)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
