import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class DropAtBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DropAtBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItemData(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItemData(Icons.directions_bus_outlined, Icons.directions_bus_rounded, 'Shuttle'),
    _NavItemData(Icons.history_outlined, Icons.history_rounded, 'Rides'),
    _NavItemData(Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 16,
        right: 16,
      ),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: DropAtColors.primary.withOpacity(0.05),
                  blurRadius: 40,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _items.length;
                return Stack(
                  children: [
                    // Animated sliding indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      left: currentIndex * itemWidth + (itemWidth - 56) / 2,
                      top: 8,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: DropAtColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: DropAtColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: DropAtColors.primary.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Nav items
                    Row(
                      children: List.generate(_items.length, (index) {
                        final item = _items[index];
                        final isActive = currentIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onTap(index),
                            behavior: HitTestBehavior.opaque,
                            child: _NavItemWidget(
                              icon: item.inactiveIcon,
                              activeIcon: item.activeIcon,
                              label: item.label,
                              isActive: isActive,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String label;
  const _NavItemData(this.inactiveIcon, this.activeIcon, this.label);
}

class _NavItemWidget extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;

  const _NavItemWidget({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isActive ? activeIcon : icon,
              key: ValueKey(isActive),
              color: isActive
                  ? DropAtColors.primaryDark
                  : DropAtColors.black.withOpacity(0.45),
              size: isActive ? 26 : 23,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isActive ? 10.5 : 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive
                  ? DropAtColors.primaryDark
                  : DropAtColors.black.withOpacity(0.45),
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
