import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/components/snackbar/snackbar_provider.dart';

import 'package:unigo/pages/navbar.dart';
import '../../components/input_widgets/red_button.dart';
import 'package:unigo/pages/entity/entity_home.dart';
import 'package:unigo/components/credential_screen/input_short_textfield.dart';
import 'package:unigo/components/credential_screen/description_big_textfield.dart';

class EntityEditScreen extends StatefulWidget {
  final String idEntity;
  final String name;
  final String description;
  final String? imageURL;
  const EntityEditScreen({
    super.key,
    required this.idEntity,
    required this.name,
    required this.description,
    required this.imageURL,
  });

  @override
  State<EntityEditScreen> createState() => _EntityEditScreenState();
}

class _EntityEditScreenState extends State<EntityEditScreen> {
  bool _isUploading = false;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // ignore: unused_field
  String? _idUser = "";
  String imageURL = "";
  File? _tempImageFile;

  @override
  void initState() {
    super.initState();

    getUserInfo();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUser = prefs.getString('idUser');
    });
  }

  Future<void> pickAnImage(ImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _tempImageFile = File(pickedImage.path);
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to pick the image: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future editEntity() async {
    if (nameController.text == '' &&
        descriptionController.text == '' &&
        _tempImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).splashColor,
          showCloseIcon: false,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.5)),
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 60),
          content: Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
            child: Text(
              AppLocalizations.of(context)!.empty_fields,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _isUploading = true;
      });

      String namePlaceHolder, surnamePlaceHolder;
      if (nameController.text != '') {
        namePlaceHolder = nameController.text;
      } else {
        namePlaceHolder = widget.name;
      }
      if (descriptionController.text != '') {
        surnamePlaceHolder = descriptionController.text;
      } else {
        surnamePlaceHolder = widget.description;
      }

      if (_tempImageFile != null) {
        await uploadImageToFirebase();
      } else {
        imageURL = widget.imageURL ?? '';
      }

      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? "";
      try {
        await Dio().post(
          'http://${dotenv.env['API_URL']}/entity/update/${widget.idEntity}',
          data: {
            "name": namePlaceHolder,
            "description": surnamePlaceHolder,
            "imageURL": imageURL,
          },
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          ),
        );
        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const EntityScreen(),
          ),
          (Route<dynamic> route) =>
              false, // Elimina todas las pantallas anteriores
        );
      } catch (e) {
        // ignore: avoid_print
        print(e);
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future deleteEntity() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    try {
      String path =
          'http://${dotenv.env['API_URL']}/entity/delete/${widget.idEntity}';
      await Dio().delete(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
    } catch (e) {
      SnackBarProvider().showErrorSnackBar(
          // ignore: use_build_context_synchronously
          context,
          // ignore: use_build_context_synchronously
          AppLocalizations.of(context)!.server_error,
          30,
          0,
          30,
          60);
    }
  }

  void showDeleteConfirmationDialog() async {
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
              title: Text(
                AppLocalizations.of(context)!.delete_entity,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.delete_entity_explanation,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.labelMedium,
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
                    deleteEntity();
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageTransition(
                        type: PageTransitionType.leftToRight,
                        child: const NavBar(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).splashColor,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: 1080,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 17.5, 15, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDeleteConfirmationDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.delete_rounded,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.edit_entity,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleSmall?.color,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                          PageTransition(
                            type: PageTransitionType.topToBottom,
                            child: const EntityScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Theme.of(context).secondaryHeaderColor,
                          size: 27.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        imageEntity(),
                        const SizedBox(
                          height: 37.5,
                        ),
                        InputShortTextField(
                            controller: nameController,
                            labelText: widget.name,
                            obscureText: false),
                        const SizedBox(height: 15),
                        DescriptionBigTextField(
                            controller: descriptionController,
                            labelText: widget.description,
                            obscureText: false),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Stack(
                  children: [
                    //Sign up button
                    RedButton(
                      buttonText: AppLocalizations.of(context)!.edit_button,
                      onTap: editEntity,
                    ),
                    if (_isUploading)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: MediaQuery.of(context).size.width - 95,
                        child: Center(
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              backgroundColor: Theme.of(context)
                                  .secondaryHeaderColor
                                  .withOpacity(0.5),
                              strokeCap: StrokeCap.round,
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).secondaryHeaderColor),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 15),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.remember_entity2,
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.explanation2,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).splashColor,
                        ), // Cambia el color a rojo
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.explanation3,
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.explanation4,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).splashColor,
                        ), // Cambia el color a rojo
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.of_UNIGO,
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

  Widget imageEntity() {
    return Stack(
      children: [
        _tempImageFile != null
            ? CircleAvatar(
                radius: 40,
                backgroundImage: FileImage(_tempImageFile!),
              )
            : CircleAvatar(
                radius: 40,
                backgroundImage: widget.imageURL != ""
                    ? Image.network(widget.imageURL!).image
                    : const AssetImage('images/entity.png'),
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
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20.0,
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
                    pickAnImage(ImageSource.camera);
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
                    pickAnImage(ImageSource.gallery);
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

  Future<void> uploadImageToFirebase() async {
    try {
      final storage = FirebaseStorage.instance;

      var snapshot = await storage
          .ref()
          .child('entities/${nameController.text}/picture')
          .putFile(_tempImageFile!);
      var downloadURL = await snapshot.ref.getDownloadURL();

      if (mounted) {
        setState(() {
          imageURL = downloadURL;
        });
      }
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Failed to pick the image: $e');
    }
  }
}
