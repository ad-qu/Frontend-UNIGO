import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../components/input_widgets/red_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unigo/pages/entity/entity_home.dart';
import 'package:unigo/components/credential_screen/input_short_textfield.dart';
import 'package:unigo/components/credential_screen/description_big_textfield.dart';

void main() async {
  await dotenv.load();
}

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
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String? _idUser = "";
  String imageURL = "";
  File? _tempImageFile;
  String? _deleteConfirmationText = "";

  @override
  void initState() {
    getUserInfo();
    super.initState();
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

  Future createEntity() async {
    if (_tempImageFile != null) {
      await uploadImageToFirebase();
    }
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    try {
      Navigator.pop(
        // ignore: use_build_context_synchronously
        context,
        PageTransition(
          type: PageTransitionType.topToBottom,
          child: const EntityScreen(),
        ),
      );
      await Dio().post(
        'http://${dotenv.env['API_URL']}/entity/update/${widget.idEntity}',
        data: {
          "name": nameController.text,
          "description": descriptionController.text,
          "imageURL": imageURL,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future deleteEntity() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    try {
      String path =
          'http://${dotenv.env['API_URL']}/entity/delete/${widget.idEntity}';
      var response = await Dio().delete(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 56, 142, 60),
            showCloseIcon: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.5)),
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            content: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
              child: Text(
                "Challenge successfully deleted",
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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).splashColor,
            showCloseIcon: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.5)),
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            content: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
              child: Text(
                AppLocalizations.of(context)!.unable_to_proceed,
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
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).splashColor,
          showCloseIcon: false,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.5)),
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          content: Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
            child: Text(
              AppLocalizations.of(context)!.unable_to_proceed,
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
                'Eliminar entidad',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¿Estás seguro de que quieres eliminar esta entidad? \n\nAl eliminar la entidad, esta quedará inaccesible y no podrás utilizarla. \n\nPor favor, considera esta opción con cuidado antes de confirmar la eliminación.',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          // Guardar el valor ingresado para la confirmación
                          _deleteConfirmationText = value;
                        });
                      }
                    },
                    cursorColor: const Color.fromARGB(255, 222, 66, 66),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 25, 25, 25),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).textTheme.bodyMedium?.color,
                      hintText: 'Escribe "ELIMINAR" para confirmar',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 146, 146, 146),
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
                    foregroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 222, 66, 66),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (_deleteConfirmationText == 'ELIMINAR') {
                      deleteEntity(); // Llamar al método de eliminación
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.amber,
                          showCloseIcon: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 22.5),
                          content: const Text(
                            'Texto de confirmación incorrecto',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          closeIconColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 222, 66, 66),
                    ),
                  ),
                  child: const Text('Confirmar'),
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
                        showDeleteConfirmationDialog(); // Mostrar el diálogo de confirmación
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
                      "Editar entidad",
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
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color.fromARGB(255, 227, 227, 227),
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
                        //Username textfield
                        InputShortTextField(
                            controller: nameController,
                            labelText: widget.name,
                            obscureText: false),

                        const SizedBox(height: 15),

                        //Email address textfield
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //Sign up button
                    RedButton(
                      buttonText: "EDITAR",
                      onTap: createEntity,
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
                        text: "La entidad que modifiques deberá cumplir los ",
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.explanation2,
                        style: GoogleFonts.inter(
                            color: const Color.fromARGB(
                                255, 204, 49, 49)), // Cambia el color a rojo
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.explanation3,
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.explanation4,
                        style: GoogleFonts.inter(
                            color: const Color.fromARGB(
                                255, 204, 49, 49)), // Cambia el color a rojo
                      ),
                      TextSpan(
                        text: " de UNIGO!",
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
              decoration: const BoxDecoration(
                color: Colors.amber,
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
            "Choose an entity photo",
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
                    //pickImageFromGallery(ImageSource.camera);
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

                    //pickImageFromGallery(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                      semanticLabel: "Gallery",
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
