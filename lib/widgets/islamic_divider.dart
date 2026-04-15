// lib/widgets/islamic_divider.dart
// A decorative ornamental divider for use between sections.

import 'package:flutter/material.dart';

class IslamicDivider extends StatelessWidget {
  final Color color;
  final String ornament;

  const IslamicDivider({
    super.key,
    this.color = const Color(0xFF1B5E20),
    this.ornament = '✦',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: color.withOpacity(0.3),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ornament,
              style: TextStyle(
                color: color.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: color.withOpacity(0.3),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
