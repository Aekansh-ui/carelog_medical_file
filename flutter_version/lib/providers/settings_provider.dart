import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class SettingsState {
  final String currency;
  final bool notificationsEnabled;
  final String reminderTime;

  const SettingsState({
    this.currency = 'INR',
    this.notificationsEnabled = false,
    this.reminderTime = '09:00',
  });

  SettingsState copyWith({
    String? currency,
    bool? notificationsEnabled,
    String? reminderTime,
  }) =>
      SettingsState(
        currency: currency ?? this.currency,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        reminderTime: reminderTime ?? this.reminderTime,
      );
}

// ---------------------------------------------------------------------------
// Preference keys
// ---------------------------------------------------------------------------

const _keyCurrency = 'currency';
const _keyNotificationsEnabled = 'notificationsEnabled';
const _keyReminderTime = 'reminderTime';

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  /// Loads persisted settings from SharedPreferences.
  /// Call once during app bootstrap (P5 wires this into main.dart).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      currency: prefs.getString(_keyCurrency) ?? 'INR',
      notificationsEnabled: prefs.getBool(_keyNotificationsEnabled) ?? false,
      reminderTime: prefs.getString(_keyReminderTime) ?? '09:00',
    );
  }

  /// Persists [key] → [value] and updates state.
  ///
  /// Supported keys: `'currency'` (String), `'notificationsEnabled'` (bool),
  /// `'reminderTime'` (String, HH:MM format).
  Future<void> setSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (key) {
      case _keyCurrency:
        await prefs.setString(key, value as String);
        state = state.copyWith(currency: value);
      case _keyNotificationsEnabled:
        await prefs.setBool(key, value as bool);
        state = state.copyWith(notificationsEnabled: value);
      case _keyReminderTime:
        await prefs.setString(key, value as String);
        state = state.copyWith(reminderTime: value);
    }
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
