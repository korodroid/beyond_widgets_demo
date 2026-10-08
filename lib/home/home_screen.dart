import 'package:flutter/material.dart';

import '../demos/camera_pipeline_sync/camera_pipeline_sync_screen.dart';
import '../demos/coordinate_transform/coordinate_transform_screen.dart';
import '../demos/interactive_overlay/interactive_overlay_screen.dart';
import '../demos/naive_overlay/naive_overlay_screen.dart';
import '../demos/rendering_performance/rendering_performance_screen.dart';
import '../l10n/generated/app_localizations.dart';
import 'demo_entry.dart';

List<DemoEntry> buildDemoEntries(AppLocalizations l10n) => <DemoEntry>[
      DemoEntry(
        number: '01',
        title: l10n.demo01Title,
        subtitle: l10n.demo01Subtitle,
        builder: (_) => const NaiveOverlayScreen(),
      ),
      DemoEntry(
        number: '02',
        title: l10n.demo02Title,
        subtitle: l10n.demo02Subtitle,
        builder: (_) => const CoordinateTransformScreen(),
      ),
      DemoEntry(
        number: '03',
        title: l10n.demo03Title,
        subtitle: l10n.demo03Subtitle,
        builder: (_) => const CameraPipelineSyncScreen(),
      ),
      DemoEntry(
        number: '04',
        title: l10n.demo04Title,
        subtitle: l10n.demo04Subtitle,
        builder: (_) => const RenderingPerformanceScreen(),
      ),
      DemoEntry(
        number: '05',
        title: l10n.demo05Title,
        subtitle: l10n.demo05Subtitle,
        builder: (_) => const InteractiveOverlayScreen(),
      ),
    ];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = buildDemoEntries(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: ListView.separated(
        itemCount: entries.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return ListTile(
            leading: CircleAvatar(child: Text(entry.number)),
            title: Text(entry.title),
            subtitle: Text(entry.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: entry.builder),
            ),
          );
        },
      ),
    );
  }
}
