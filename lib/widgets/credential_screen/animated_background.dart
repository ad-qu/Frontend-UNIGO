import 'package:flutter/material.dart';
import 'package:animate_gradient/animate_gradient.dart';

class BackgroundWidget extends StatefulWidget {
  final Widget child;

  const BackgroundWidget({Key? key, required this.child}) : super(key: key);

  @override
  _BackgroundWidgetState createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimateGradient(
      primaryColors: const [
        Color.fromARGB(255, 25, 25, 25),
        Color.fromARGB(255, 25, 25, 25),
        Color.fromARGB(255, 25, 25, 25),
        Color.fromARGB(255, 25, 25, 25),
      ],
      secondaryColors: const [
        Color.fromARGB(255, 92, 30, 30),
        Color.fromARGB(255, 65, 27, 27),
        Color.fromARGB(255, 36, 20, 20),
        Color.fromARGB(255, 20, 20, 20),
      ],
      child: Stack(
        children: [
          widget.child,
        ],
      ),
    );
  }
}
