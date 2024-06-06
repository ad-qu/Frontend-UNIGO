import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class ChallengeLocationPicker extends StatelessWidget {
  const ChallengeLocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location Picker',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Location Picker'),
        ),
        body: FlutterLocationPicker(
          initZoom: 11,
          minZoomLevel: 5,
          maxZoomLevel: 16,
          trackMyPosition: true,
          searchBarBackgroundColor: Colors.white,
          selectedLocationButtonTextstyle: const TextStyle(fontSize: 18),
          mapLanguage: 'en',
          onError: (e) => print(e),
          selectLocationButtonLeadingIcon: const Icon(Icons.check),
          onPicked: (pickedData) {
            Navigator.pop(context, {
              'latitude': pickedData.latLong.latitude,
              'longitude': pickedData.latLong.longitude,
            });
          },
          onChanged: (pickedData) {
            print(pickedData.latLong.latitude);
            print(pickedData.latLong.longitude);
            print(pickedData.address);
            print(pickedData.addressData);
          },
          showContributorBadgeForOSM: true,
        ),
      ),
    );
  }
}
