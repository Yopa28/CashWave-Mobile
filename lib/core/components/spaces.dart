import 'package:flutter/material.dart';

/// Vertical spacing helper.
///
/// Example:
/// ```dart
/// const SpaceHeight(16),
/// ```
class SpaceHeight extends StatelessWidget {
  final double height;

  const SpaceHeight(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

/// Horizontal spacing helper.
///
/// Example:
/// ```dart
/// const SpaceWidth(12),
/// ```
class SpaceWidth extends StatelessWidget {
  final double width;

  const SpaceWidth(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
