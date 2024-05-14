import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:unigo/screens/entity_screens/entity_screen.dart';

//Screens
import 'package:unigo/screens/map_screens/home_screen.dart';
import 'package:unigo/screens/profile_screens/profile_screen.dart';
import 'package:unigo/screens/discover_screens/discover_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'entity_screens/list_chat_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  //ignore: library_private_types_in_public_api
  _NavBarState createState() => _NavBarState();
}

int _currentIndex = 0;

final screens = [
  const HomeScreen(),
  //const HubScreen(),
  // Chat(),
  // const MyApp(),
  const DiscoverScreen(),
  const EntityScreen(),
  const ProfileScreen(),
];

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: GNav(
            gap: 10,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            color: Theme.of(context).secondaryHeaderColor,
            activeColor: Theme.of(context).secondaryHeaderColor,
            tabBackgroundColor: Theme.of(context).splashColor,
            duration: const Duration(milliseconds: 250),
            selectedIndex: _currentIndex,
            onTabChange: (index) => {setState(() => _currentIndex = index)},
            padding: const EdgeInsets.fromLTRB(12, 8.5, 10, 8.5),
            tabs: [
              GButton(
                icon: Icons.map_rounded,
                iconSize: 25,
                // text: 'Home',
                text: AppLocalizations.of(context)!.map,
              ),
              GButton(
                  icon: Icons.polyline_rounded, iconSize: 25, text: "Discover"),
              GButton(
                icon: Icons.view_agenda_rounded,
                iconSize: 25,
                // text: 'Discover',
                text: AppLocalizations.of(context)!.entities,
              ),
              GButton(
                icon: Icons.person_rounded,
                iconSize: 25,
                // text: 'Profile',
                text: AppLocalizations.of(context)!.profile,
              ),
            ]),
      ),
      bottomSheet: Divider(
        color: Theme.of(context).dividerColor,
        height: 0.05,
      ),
    );
  }
}
