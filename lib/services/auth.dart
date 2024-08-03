// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unigo/pages/navbar.dart';
import '../../models/user.dart' as unigo;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  // SignIn with Google
  signInWithGoogle(context) async {
    try {
      // Empezamos el logIn con Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtenemos los detalles de la request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Obtenemos las credenciales del AuthProvider
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print(googleUser);
      // Hacemos Sign In con los credenciales que nos da google
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      print('------------- Google Auth -------------');

      // Print user info
      print('User ID: ${user!.uid}');
      print('Display Name: ${user.displayName}');
      print('Email: ${user.email}');

      if (userCredential.additionalUserInfo!.isNewUser == true) {
        SignUpViaGoogle(user, context);
        print("New user");
      } else {
        SignInViaGoogle(user, context);
        print("Old user");
      }
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft, child: const NavBar()));
    } catch (error) {
      print(error);
    }
  }

  // ignore: non_constant_identifier_names
  SignUpViaGoogle(User user, context) async {
    String? displayName = user.displayName;
    List<String> nameParts = displayName!.split(" ");
    String name = nameParts.isNotEmpty ? nameParts[0] : "";
    String surname = nameParts.length > 1 ? nameParts[1] : "";

    try {
      var response = await Dio().post(
        "http://${dotenv.env['API_URL']}/auth/googleAuthSignUp",
        data: {
          "name": name,
          "surname": surname,
          "username": Random().nextInt(99999 - 10000 + 1) + 10000,
          "email": user.email,
          "password": user.uid
        },
      );

      print(response);

      if (response.statusCode == 200) {
        print('User registration successful');
        Map<String, dynamic> payload = Jwt.parseJwt(response.toString());
        unigo.User u = unigo.User.fromJson(payload);

        print('Token: $payload');

        var data = json.decode(response.toString());

        print(data['token']);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', data['token']);
        prefs.setString('idUser', u.idUser);
        prefs.setString('name', u.name);
        prefs.setString('surname', u.surname);
        prefs.setString('username', u.username);
        try {
          // prefs.setInt('exp', u.exp!);
          prefs.setInt('level', u.level!);
          prefs.setInt('experience', u.experience!);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 222, 66, 66),
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: Text(
                'Error $e',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        print(
            'User registration failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering user: $e');
    }
  }

  // ignore: non_constant_identifier_names
  SignInViaGoogle(User user, context) async {
    try {
      var response = await Dio().post(
        'http://${dotenv.env['API_URL']}/auth/login',
        data: {
          "email": user.email,
          "password": user.uid,
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> payload = Jwt.parseJwt(response.toString());
        unigo.User u = unigo.User.fromJson(payload);
        var data = json.decode(response.toString());
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', data['token']);
        prefs.setString('idUser', u.idUser);
        prefs.setString('name', u.name);
        prefs.setString('surname', u.surname);
        prefs.setString('username', u.username);
        prefs.setString('email', user.email!);
        prefs.setString('password', user.uid);
        prefs.setString('imageURL', u.imageURL ?? '');
        try {
          // prefs.setInt('exp', u.exp!);
          prefs.setInt('level', u.level!);
          prefs.setInt('experience', u.experience!);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 222, 66, 66),
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
              content: Text(
                'Error $e',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {}
  }
}
