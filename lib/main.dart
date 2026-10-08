import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  runApp(const BeyondWidgetsApp());
}

class BeyondWidgetsApp extends StatelessWidget {
  const BeyondWidgetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00E5A0)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
