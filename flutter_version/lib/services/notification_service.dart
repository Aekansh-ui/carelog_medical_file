import 'dart:io';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Wraps flutter_local_notifications to schedule D-1 and D-0 follow-up alerts.
/// Scheduling is only supported on Android and iOS; all other platforms are
/// silently no-ops (returns empty ID strings).
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
      ),
    );
    _initialized = true;
  }

  /// Requests OS notification permission. Returns true if granted.
  Future<bool> requestPermission() async {
    await init();
    if (Platform.isAndroid) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await impl?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await impl?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    if (Platform.isMacOS) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      return await impl?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  /// Schedules D-1 (day-before) and D-0 (day-of) notifications at [reminderTime]
  /// ('HH:MM', 24-hour). Returns the notification IDs as strings; an empty
  /// string means the trigger was in the past or scheduling is unsupported.
  Future<({String d1Id, String d0Id})> scheduleFollowUp({
    required String visitId,
    required String followUpDate,
    required String reminderTime,
  }) async {
    await init();

    // Scheduled notifications only work on Android / iOS.
    if (!Platform.isAndroid && !Platform.isIOS) {
      return (d1Id: '', d0Id: '');
    }

    final parts = reminderTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final followUp = DateTime.parse(followUpDate);
    final now = tz.TZDateTime.now(tz.local);

    final d1Base = followUp.subtract(const Duration(days: 1));
    final d1Trigger = tz.TZDateTime(
        tz.local, d1Base.year, d1Base.month, d1Base.day, hour, minute);
    final d0Trigger = tz.TZDateTime(
        tz.local, followUp.year, followUp.month, followUp.day, hour, minute);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'carelog_reminders',
        'Follow-up Reminders',
        channelDescription: 'Medical follow-up reminders from CareLog',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final rng = Random();
    String d1Id = '';
    String d0Id = '';

    if (d1Trigger.isAfter(now)) {
      final id = rng.nextInt(0x7FFFFFFF);
      await _plugin.zonedSchedule(
        id: id,
        title: 'Follow-up Tomorrow',
        body: 'You have a medical follow-up appointment tomorrow.',
        scheduledDate: d1Trigger,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: visitId,
      );
      d1Id = id.toString();
    }

    if (d0Trigger.isAfter(now)) {
      final id = rng.nextInt(0x7FFFFFFF);
      await _plugin.zonedSchedule(
        id: id,
        title: 'Follow-up Today',
        body: 'You have a medical follow-up appointment today.',
        scheduledDate: d0Trigger,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: visitId,
      );
      d0Id = id.toString();
    }

    return (d1Id: d1Id, d0Id: d0Id);
  }

  Future<void> cancelNotifications(String d1Id, String d0Id) async {
    await init();
    if (d1Id.isNotEmpty) {
      final id = int.tryParse(d1Id);
      if (id != null) await _plugin.cancel(id: id);
    }
    if (d0Id.isNotEmpty) {
      final id = int.tryParse(d0Id);
      if (id != null) await _plugin.cancel(id: id);
    }
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}

final notificationService = NotificationService();
