import 'package:flutter/material.dart';

/// The "01 · Naive Overlay"-style AppBar title used by both the home list
/// and each demo screen. The number itself isn't translated — it's an
/// identifier tying the screen back to the talk's agenda, not language text.
String numberedTitle(String number, String title) => '$number · $title';

class DemoEntry {
  const DemoEntry({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final String number;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}
