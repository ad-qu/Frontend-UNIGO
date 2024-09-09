import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:flutter/material.dart';
import '../../components/map/map_gps.dart';
import '../../components/home_screen/sliding_up_panel.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final panelController = PanelController();

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
        child: SlidingUpPanelWidget(
          controller: controller,
        ),
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22.5),
        topRight: Radius.circular(22.5),
      ),
      body: const MapGPS(),
    ));
  }
}
