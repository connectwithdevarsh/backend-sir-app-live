import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NavItemData {
  final int index;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavItemData({
    required this.index,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// PremiumBottomNav renders a floating, pill-shaped glassmorphic navigation bar
/// with animated selected states, custom iconography, and safe-area support.
class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavItemData> _items = [
    NavItemData(
      index: 0,
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    NavItemData(
      index: 1,
      label: 'Material',
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories_rounded,
    ),
    NavItemData(
      index: 2,
      label: 'Sir',
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 14),
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppTheme.primaryCyan.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryCyan.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.map((item) {
              final bool isSelected = currentIndex == item.index;

              return InkWell(
                onTap: () => onTap(item.index),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 18 : 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryCyan.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryCyan.withValues(alpha: 0.45)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 22,
                          color: isSelected
                              ? AppTheme.primaryCyan
                              : AppTheme.textMuted,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            item.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryCyan,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
