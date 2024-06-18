import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:unigo/pages/entity/entity_home.dart';

// Screens
import 'package:unigo/pages/map/map.dart';
import 'package:unigo/pages/profile/profile_home.dart';
import 'package:unigo/pages/discover/discover_home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart'; // Importa este paquete para SystemNavigator

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final screens = [
    const Map(),
    const DiscoverScreen(),
    const EntityScreen(),
    const ProfileScreen(),
  ];

  Future<bool> _onPopScope() async {
    final currentNavigatorState = _navigatorKeys[_currentIndex].currentState!;
    if (currentNavigatorState.canPop()) {
      return !await currentNavigatorState.maybePop();
    } else {
      SystemNavigator.pop();
      return false;
    }
  }

  void _resetToRoot(int index) {
    _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        bool value = await _onPopScope();
        if (value) {
          navigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens.asMap().entries.map((entry) {
            int index = entry.key;
            Widget screen = entry.value;
            return Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (settings) {
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => screen,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                );
              },
            );
          }).toList(),
        ),
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
            onTabChange: (index) {
              if (index != _currentIndex) {
                _resetToRoot(_currentIndex);
              }
              setState(() => _currentIndex = index);
            },
            padding: const EdgeInsets.fromLTRB(12, 8.5, 10, 8.5),
            tabs: [
              GButton(
                icon: Icons.map_rounded,
                iconSize: 25,
                text: AppLocalizations.of(context)!.map,
              ),
              GButton(
                icon: Icons.polyline_rounded,
                iconSize: 25,
                text: AppLocalizations.of(context)!.discover,
              ),
              GButton(
                icon: Icons.view_agenda_rounded,
                iconSize: 25,
                text: AppLocalizations.of(context)!.entities,
              ),
              GButton(
                icon: Icons.person_rounded,
                iconSize: 25,
                text: AppLocalizations.of(context)!.profile,
              ),
            ],
          ),
        ),
        bottomSheet: Divider(
          color: Theme.of(context).dividerColor,
          height: 0.05,
        ),
      ),
    );
  }
}
