// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../components/map/map_gps.dart';
import '../../components/home_screen/panel_widget.dart';

void main() async {
  await dotenv.load();
}

class Map extends StatefulWidget {
  //const LoginScreen({super.key, required String title});
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final panelController = PanelController();
  bool isPanelOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const panelHeightClosed = 43.0;
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.785;
    return Scaffold(
        body: SlidingUpPanel(
      backdropOpacity: 0.5,
      controller: panelController,
      maxHeight: panelHeightOpen,
      minHeight: panelHeightClosed,
      parallaxEnabled: true,
      parallaxOffset: .5,
      backdropEnabled: true,
      panelBuilder: (controller) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22.5),
          topRight: Radius.circular(22.5),
        ),
        child: PanelWidget(
          controller: controller,
          panelController: panelController,
          // onPanelStateChanged: (bool isOpen) {
          //   setState(() {
          //     isPanelOpen = isOpen;
          //   });
          // },
        ),
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22.5),
        topRight: Radius.circular(22.5),
      ),
      body: MapGPS(),
    ));
  }
}