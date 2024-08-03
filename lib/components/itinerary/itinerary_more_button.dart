import 'package:popover/popover.dart';
import 'package:flutter/material.dart';
import 'package:unigo/components/itinerary/itinerary_menu.dart';

class ItineraryMoreButton extends StatefulWidget {
  final String idItinerary;
  final VoidCallback onChange;

  const ItineraryMoreButton({
    super.key,
    required this.idItinerary,
    required this.onChange,
  });
  @override
  State<ItineraryMoreButton> createState() => ItineraryMoreButtonState();
}

class ItineraryMoreButtonState extends State<ItineraryMoreButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) => ItineraryMenu(
              idItinerary: widget.idItinerary,
              onChange: () {
                widget.onChange();
                Navigator.of(context).pop();
              },
            ),
            width: 100,
            height: 81,
            direction: PopoverDirection.bottom,
            contentDyOffset: -7.5,
            arrowHeight: 10,
            arrowWidth: 15,
            arrowDxOffset: 0,
            radius: 20,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30)),
          child: Icon(
            Icons.more_horiz_rounded,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
      ),
    );
  }
}
