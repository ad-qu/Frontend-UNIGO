import 'package:dio/dio.dart';
import 'package:unigo/pages/startup/welcome.dart';
import 'package:unigo/pages/navbar.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // During 1500 ms, we verify if the credentials are available to Log In and if the response code is 222 to proceed
  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idUser = prefs.getString("idUser");
    String? email = prefs.getString("email");
    String? password = prefs.getString("password");
    print(idUser);
    print(email);
    print(password);

    if (idUser == null) {
      _goToWelcomeScreen();
    } else {
      print("23123123123131");
      try {
        var response = await Dio().post(
          'http://${dotenv.env['API_URL']}/auth/logIn',
          data: {"email": email, "password": password},
        );

        // If the response code is 222, authentication is successful, otherwise navigate to Welcome Screen
        if (response.statusCode == 222) {
          Map<String, dynamic> data = response.data;
          final token = data['token'];
          final idUser = data['_id'];
          final name = data['name'];
          final surname = data['surname'];
          final username = data['username'];
          final imageURL = data['imageURL'];
          final campus = data['campus'];
          final latitude = data['latitude'];
          final longitude = data['longitude'];
          final level = data['level'];
          final experience = data['experience'];

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', token);
          prefs.setString('idUser', idUser);
          prefs.setString('name', name);
          prefs.setString('surname', surname);
          prefs.setString('username', username);
          prefs.setString('email', email!);
          prefs.setString('password', password!);
          prefs.setString('campus', campus ?? '');
          prefs.setString('latitude', latitude ?? '');
          prefs.setString('longitude', longitude ?? '');
          prefs.setString('imageURL', imageURL ?? '');
          prefs.setInt('level', level);
          prefs.setInt('experience', experience);
          print(latitude);
          print(longitude);
          print("233123123123123");
          _goToHomeScreen();
        } else {
          _goToWelcomeScreen();
        }
      } catch (e) {
        _goToWelcomeScreen();
      }
    }
  }

  void _goToWelcomeScreen() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: const WelcomeScreen(),
      ),
    );
  }

  void _goToHomeScreen() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: const NavBar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).splashColor),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
