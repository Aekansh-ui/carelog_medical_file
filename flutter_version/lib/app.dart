import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class CareLogApp extends StatelessWidget {
  const CareLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
