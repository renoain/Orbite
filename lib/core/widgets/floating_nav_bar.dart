import 'dart:ui';

import 'package:flutter/material.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.explore, 'Explore'),
    (Icons.school, 'Learn'),
    (Icons.quiz, 'Trivia'),
    (Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final selectedColor = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: bottomInset > 0 ? bottomInset : 16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final selected = index == currentIndex;
                final color = selected ? selectedColor : Colors.white60;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: _items[index].$2,
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_items[index].$1, color: color, size: 24),
                          const SizedBox(height: 2),
                          Text(
                            _items[index].$2,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
