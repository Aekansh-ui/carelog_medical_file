import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/export_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _reminderTimeCtrl = TextEditingController();
  bool _reminderTimeError = false;
  bool _exportBusy = false;
  bool _deleteBusy = false;
  String? _storageUsed;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _reminderTimeCtrl.text = settings.reminderTime;
    _loadStorageUsed();
  }

  @override
  void dispose() {
    _reminderTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStorageUsed() async {
    final db = ref.read(databaseProvider);
    final visits = await db.select(db.visits).get();
    final members = await db.select(db.members).get();
    final reminders = await db.select(db.reminders).get();
    final policies = await db.select(db.insurancePolicies).get();
    final total = visits.length + members.length + reminders.length + policies.length;
    if (mounted) {
      setState(() =>
          _storageUsed = '$total record${total == 1 ? '' : 's'} stored locally');
    }
  }

  void _onReminderTimeChanged(String val) {
    final valid = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(val);
    setState(() => _reminderTimeError = !valid);
    if (valid) {
      ref.read(settingsProvider.notifier).setSetting('reminderTime', val);
    }
  }

  Future<void> _exportAll() async {
    setState(() => _exportBusy = true);
    try {
      final db = ref.read(databaseProvider);
      await exportService.exportAllData(db);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportBusy = false);
    }
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
            'This will permanently delete all visits, reminders, insurance policies, '
            'and family members. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleteBusy = true);
    try {
      final db = ref.read(databaseProvider);
      // Delete order respects FK constraints: children before parents.
      await db.delete(db.insuranceDocuments).go();
      await db.delete(db.insurancePolicies).go();
      await db.delete(db.reminders).go();
      await db.delete(db.attachments).go();
      await db.delete(db.visits).go();
      // Keep the Self member; only delete added family members.
      await (db.delete(db.members)
            ..where((m) => m.id.isNotValue(
                '11111111-1111-1111-1111-111111111111')))
          .go();
      // Cancel all scheduled notifications.
      await notificationService.cancelAll();
      // Clear seed flags so seed re-runs on next launch.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('@CareLog_seeded_v1');
      await prefs.remove('@CareLog_seeded_family_v1');
      await prefs.remove('@CareLog_seeded_insurance_v1');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted.')),
        );
        _loadStorageUsed();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _deleteBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md, vertical: Spacing.md),
        children: [
          // ── Currency ──────────────────────────────────────────────────────
          _SectionHeader(title: 'Currency'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Default Currency', style: AppText.body),
                const SizedBox(height: Spacing.sm),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'INR', label: Text('₹ INR')),
                    ButtonSegment(value: 'USD', label: Text('\$ USD')),
                  ],
                  selected: {settings.currency},
                  onSelectionChanged: (sel) => ref
                      .read(settingsProvider.notifier)
                      .setSetting('currency', sel.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.12),
                    selectedForegroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // ── Notifications ─────────────────────────────────────────────────
          _SectionHeader(title: 'Notifications'),
          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  tileColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Reminders',
                      style: AppText.body),
                  subtitle: const Text('Send follow-up notifications',
                      style: AppText.caption),
                  value: settings.notificationsEnabled,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                  onChanged: (val) => ref
                      .read(settingsProvider.notifier)
                      .setSetting('notificationsEnabled', val),
                ),
                if (settings.notificationsEnabled) ...[
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: Spacing.sm),
                  TextFormField(
                    controller: _reminderTimeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Reminder Time (HH:MM)',
                      hintText: '09:00',
                      errorText: _reminderTimeError
                          ? 'Use 24-hour format, e.g. 09:00'
                          : null,
                      prefixIcon: const Icon(Icons.access_time_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d:]')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    onChanged: _onReminderTimeChanged,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // ── Storage ───────────────────────────────────────────────────────
          _SectionHeader(title: 'Storage'),
          _Card(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storage_outlined,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Local Storage', style: AppText.body),
                      Text(
                        _storageUsed ?? 'Calculating…',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // ── Data ──────────────────────────────────────────────────────────
          _SectionHeader(title: 'Data'),
          _Card(
            child: Column(
              children: [
                ListTile(
                  tileColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.download_outlined,
                        size: 18, color: AppColors.secondary),
                  ),
                  title: const Text('Export All Data', style: AppText.body),
                  subtitle: const Text('Save as PDF and share',
                      style: AppText.caption),
                  trailing: _exportBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right,
                          color: AppColors.textSecondary),
                  onTap: _exportBusy ? null : _exportAll,
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  tileColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_forever_outlined,
                        size: 18, color: AppColors.error),
                  ),
                  title: const Text('Delete All Data',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.error)),
                  subtitle: const Text('Permanently remove all records',
                      style: AppText.caption),
                  trailing: _deleteBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error),
                        )
                      : const Icon(Icons.chevron_right,
                          color: AppColors.textSecondary),
                  onTap: _deleteBusy ? null : _confirmDeleteAll,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // ── About ─────────────────────────────────────────────────────────
          _SectionHeader(title: 'About'),
          _Card(
            child: Column(
              children: [
                _AboutRow(
                    icon: Icons.favorite_outline,
                    label: 'CareLog',
                    value: 'v1.0.0'),
                const Divider(height: 1, color: AppColors.border),
                const _AboutRow(
                    icon: Icons.lock_outline,
                    label: 'Privacy',
                    value: 'All data stored on-device'),
                const Divider(height: 1, color: AppColors.border),
                const _AboutRow(
                    icon: Icons.wifi_off_outlined,
                    label: 'Connectivity',
                    value: 'Works offline'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Spacing.xs, bottom: Spacing.sm),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.textSecondary)),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _AboutRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: Spacing.sm),
          Expanded(child: Text(label, style: AppText.body)),
          Text(value, style: AppText.caption),
        ],
      ),
    );
  }
}
