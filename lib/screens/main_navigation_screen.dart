import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_bottom_nav.dart';
import 'faculty_profile_screen.dart';
import 'home_screen.dart';
import 'material_screen.dart';

/// MainNavigationScreen serves as the root navigation controller for AIPE LAB.
/// Uses IndexedStack to preserve tab states and PopScope for smart Android back navigation.
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    MaterialScreen(),
    FacultyProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          // If user is on Material or Sir tab, return to Home tab first
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Stack(
          children: [
            // IndexedStack preserves state across Home, Material, and Sir screens
            IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),

            // Floating Premium Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PremiumBottomNav(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
