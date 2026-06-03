import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/database_provider.dart';
import 'providers/settings_provider.dart';
import 'services/seed.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Init Drift — creates the AppDatabase instance and opens the SQLite file.
  final db = container.read(databaseProvider);

  // Seed demo data on first launch (each function is idempotent via prefs flag).
  await seedIfNeeded(db);
  await seedFamilyIfNeeded(db);
  await seedInsuranceIfNeeded(db);

  // Load persisted settings (currency, notifications, reminder time).
  await container.read(settingsProvider.notifier).load();

  runApp(UncontrolledProviderScope(container: container, child: const CareLogApp()));
}
