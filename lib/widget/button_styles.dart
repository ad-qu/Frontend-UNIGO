import 'package:flutter/material.dart';

final ButtonStyle myButtonStyle = ButtonStyle(
  foregroundColor: MaterialStateProperty.all<Color>(
    Color.fromARGB(255, 255, 255, 255),
  ),
  backgroundColor: MaterialStateProperty.all<Color>(
    Color.fromRGBO(0, 115, 216, 0.988),
  ),
  shape: MaterialStateProperty.all<OutlinedBorder>(
    RoundedRectangleBorder(
        side: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
  ),
  padding: MaterialStateProperty.all<EdgeInsets>(
    EdgeInsets.all(13.0),
  ),
  textStyle: MaterialStateProperty.all<TextStyle>(
    TextStyle(
      fontFamily: 'NerkoOne',
      fontSize: 20.0,
      color: Color.fromRGBO(255, 255, 255, 1),
    ),
  ),
);