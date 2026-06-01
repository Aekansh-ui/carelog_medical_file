import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';

void main() {
  // P5 will replace the placeholder home with the go_router shell, and the
  // bootstrap sequence (init Drift → seed → load settings) will run here.
  runApp(const ProviderScope(child: CareLogApp()));
}

class CareLogApp extends StatelessWidget {
  const CareLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _BootstrapPlaceholder(),
    );
  }
}

/// Temporary landing screen for P0. Confirms the theme is wired and the app
/// boots. Replaced by the navigation shell in P5.
class _BootstrapPlaceholder extends StatelessWidget {
  const _BootstrapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text('CareLog', style: AppText.h1.copyWith(color: AppColors.primary)),
            const SizedBox(height: Spacing.xs),
            const Text('Your health, organised', style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
