import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unigo/components/snackbar/snackbar_provider.dart';
import 'package:unigo/pages/profile/followers_screen.dart';
import 'package:unigo/pages/profile/following_screen.dart';
import 'package:unigo/pages/profile/history_home.dart';
import 'package:unigo/pages/startup/login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/components/input_widgets/delete_account_button.dart';
import 'package:unigo/components/input_widgets/edit_account_button.dart';
import 'package:unigo/components/input_widgets/edit_password_button.dart';
import 'package:unigo/components/input_widgets/history_button.dart';
import 'package:unigo/components/input_widgets/log_out_button.dart';
import 'package:unigo/components/language/language_button.dart';
import 'package:unigo/components/theme/theme_provider.dart';

import 'package:page_transition/page_transition.dart';

import 'dart:ui';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:restart_app/restart_app.dart';
import 'package:unigo/pages/profile/edit_account.dart';
import 'package:unigo/pages/profile/edit_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  String? _idUser = "";
  String? _name = "";
  String? _surname = "";
  String? _username = "";
  String? _deleteUsername = "";
  // ignore: unused_field
  String? _token = "";
  // ignore: unused_field
  String? _campus = "";
  String? _followers = "";
  String? _following = "";
  int _level = 0;
  int _exp = 0;

  List<dynamic> insigniasList = [];

  String imageURL = "";
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    getUserInfo();
    getFriendsInfo();
  }

  Future clearInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Widget imageProfile() {
    return Stack(
      children: [
        SizedBox(
          height: 65,
          width: 65,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: imageURL.isEmpty
                  ? Image.asset(
                      'images/default.png',
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      imageURL,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // La imagen ha terminado de cargar
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(2.5),
                            child: Container(
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor, // Fondo mientras se carga la imagen
                              child: CircularProgressIndicator(
                                backgroundColor: Theme.of(context).hoverColor,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).splashColor),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          'images/default.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 15.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 215,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.select_a_photo,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 45,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).splashColor,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    pickImageFromGallery(ImageSource.camera);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 40,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).splashColor,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    pickImageFromGallery(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> pickImageFromGallery(ImageSource source) async {
    try {
      final storage = FirebaseStorage.instance;
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(source: source);
      if (pickedImage != null) {
        var file = File(pickedImage.path);
        var snapshot =
            await storage.ref().child('users/$_username/avatar').putFile(file);
        var downloadURL = await snapshot.ref.getDownloadURL();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('imageURL', downloadURL);
        final String token = prefs.getString('token') ?? "";
        String path = 'http://${dotenv.env['API_URL']}/user/update/$_idUser';
        var response = await Dio().post(path,
            data: {"imageURL": downloadURL},
            options: Options(
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            ));
        // ignore: avoid_print
        setState(() {
          imageURL = downloadURL;
        });
        print(response);
        if (mounted) {}
      }
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Failed to pick the image: $e');
    }
  }

  Future getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _token = prefs.getString('token');
        _idUser = prefs.getString('idUser');
        _name = prefs.getString('name');
        _surname = prefs.getString('surname');
        _username = prefs.getString('username');
        imageURL = prefs.getString('imageURL') ?? '';
        try {
          _level = prefs.getInt('level')!;
          _exp = prefs.getInt('experience')!;
          _campus = prefs.getString('campus')!;
        } catch (e) {
          // ignore: avoid_print
          print(e);
          _level = 0;
          _exp = 0;
        }
      });
    }
  }

  Future getFriendsInfo() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // ignore: unused_local_variable
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var followersCount = await Dio().get(
          'http://${dotenv.env['API_URL']}/user/followers/count/${_idUser!}');
      if (mounted) {
        setState(() {
          _followers = followersCount.toString();
        });
      }

      var followingCount = await Dio().get(
          'http://${dotenv.env['API_URL']}/user/following/count/${_idUser!}');
      if (mounted) {
        setState(() {
          _following = followingCount.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // ignore: avoid_print
      print('Error in the counting of friends: $e');
    }
  }

  Future logOut() async {
    auth.signOut();
    GoogleSignIn().signOut();
    FirebaseFirestore.instance.clearPersistence;
    clearInfo();
    Restart.restartApp();
  }

  Future getInsignias() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path = 'http://${dotenv.env['API_URL']}/user/get/insignia/$_idUser';
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
      var insignias = response.data as List;
      setState(() {
        insigniasList = insignias;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error in insignias: $e');
    }
    // ignore: avoid_print
    print("He fet les insignies");
  }

  seeHistory() async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: HistoryHome(idUser: _idUser!),
      ),
    );
  }

  editAccount() async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: const EditAccountScreen(),
      ),
    );
  }

  editPassword() async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: const EditPasswordScreen(),
      ),
    );
  }

  showDisableConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(),
            ),
            AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
              title: Text(AppLocalizations.of(context)!.delete_account,
                  style: Theme.of(context).textTheme.titleSmall),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.delete_account_explanation,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _deleteUsername = value;
                        });
                      }
                    },
                    cursorColor: Theme.of(context).splashColor,
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).dividerColor,
                      hintText: _username,
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 138, 138, 138),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17.5),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(18.5, 14, 0, 0),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).splashColor,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () {
                    if (_username == _deleteUsername) {
                      disableAccount();
                      auth.signOut();
                      GoogleSignIn().signOut();
                      clearInfo();
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          type: PageTransitionType.leftToRight,
                          child: const LoginScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                      SnackBarProvider().showWarningSnackBar(
                        context,
                        AppLocalizations.of(context)!.wrong_username,
                        30,
                        0,
                        30,
                        30,
                      );
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).splashColor,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  disableAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    String path = 'http://${dotenv.env['API_URL']}/user/disable/$_idUser';
    try {
      var response = await Dio().post(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        SnackBarProvider().showSuccessSnackBar(
          // ignore: use_build_context_synchronously
          context,
          // ignore: use_build_context_synchronously
          AppLocalizations.of(context)!.account_deleted,
          30,
          0,
          30,
          30,
        );
      } else {
        SnackBarProvider().showErrorSnackBar(
          // ignore: use_build_context_synchronously
          context,
          // ignore: use_build_context_synchronously
          AppLocalizations.of(context)!.server_error,
          30,
          0,
          30,
          30,
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 222, 66, 66),
          showCloseIcon: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
          content: const Text(
            'Unable to delete your account. Try again later',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget showBadges() {
    List<String> badgeLevels = [];
    // Asumiendo que las imágenes están disponibles solo para los niveles 2, 4, y 6.
    for (int level = 2; level <= _level; level += 2) {
      if (level <= 6) {
        badgeLevels.add('images/$level.png');
      }
    }

    if (badgeLevels.isEmpty) {
      return const SizedBox(
        height: 10,
      );
    } else {
      return SizedBox(
        height: 30, // Altura ajustada para el tamaño de las insignias
        width: badgeLevels.length * 35.0, // Ancho ajustado para cada insignia
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: false,
          itemCount: badgeLevels.length,
          itemBuilder: (BuildContext context, int index) {
            try {
              return Row(
                children: [
                  Container(
                    width: 20.0, // Ancho ajustado de la insignia
                    height: 20.0, // Altura ajustada de la insignia
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(badgeLevels[index]),
                        fit: BoxFit.contain, // Ajusta la imagen sin cortarla
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              );
            } catch (e) {
              return const SizedBox();
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 1080,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dotenv.env['VERSION']!,
                              style: GoogleFonts.inter(
                                color: Theme.of(context).dividerColor,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Icon(
                                    Icons.light_mode_rounded,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Icon(
                                    Icons.language_rounded,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 13),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 13),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
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
                          height: 350,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(37.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: 1080,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dotenv.env['VERSION']!,
                              style: GoogleFonts.inter(
                                color: Theme.of(context).dividerColor,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Provider.of<ThemeProvider>(context,
                                            listen: false)
                                        .toggleTheme();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Icon(
                                      Icons.light_mode_rounded,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const LanguageButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 17.5),
                                  child: imageProfile(),
                                ),
                                const SizedBox(width: 17.5),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 13.5, top: 2),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('$_name $_surname',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall),
                                          const SizedBox(height: 10),
                                          Text('$_username',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 29),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0),
                                            child: Text(
                                                '${AppLocalizations.of(context)!.level} $_level',
                                                textAlign: TextAlign.left,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Padding(
                                    //   padding:
                                    //       const EdgeInsets.only(right: 2.0),
                                    //   child: Align(
                                    //     alignment: Alignment.centerRight,
                                    //     child: showBadges(),
                                    //   ),
                                    // ),
                                  ],
                                ),
                                const SizedBox(height: 8.5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Establece los bordes redondeados
                                    child: LinearProgressIndicator(
                                      minHeight: 6.5,
                                      value: _exp.toDouble() / 100,
                                      backgroundColor: Theme.of(context)
                                          .dialogBackgroundColor,
                                      color: Theme.of(context).highlightColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: const FollowingScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "$_following\n${AppLocalizations.of(context)!.following}",
                                    // "$_following\nFollowing",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(width: 100),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: const FollowerScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "$_followers\n${AppLocalizations.of(context)!.followers}",
                                    // "$_followers\nFollowers",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                const SizedBox(height: 17.5),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                  child: HistoryButton(
                                      buttonText:
                                          AppLocalizations.of(context)!.history,
                                      onTap: seeHistory),
                                ),
                                const SizedBox(height: 38),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                  child: EditAccountButton(
                                      buttonText: AppLocalizations.of(context)!
                                          .edit_account,
                                      onTap: editAccount),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                  child: EditPasswordButton(
                                      buttonText: AppLocalizations.of(context)!
                                          .edit_password,
                                      onTap: editPassword),
                                ),
                                const SizedBox(height: 38),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                  child: DeleteAccountButton(
                                      buttonText: AppLocalizations.of(context)!
                                          .delete_account,
                                      onTap: showDisableConfirmation),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                  child: LogOutButton(
                                      buttonText:
                                          AppLocalizations.of(context)!.log_out,
                                      onTap: logOut),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
