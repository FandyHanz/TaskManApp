import 'package:flutter/material.dart';

class SideNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelected;

  const SideNavigation({super.key, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
      ],
    );
  }
}