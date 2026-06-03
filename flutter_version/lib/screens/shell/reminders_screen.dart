import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/query_results.dart';
import '../../providers/reminders_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart' as du;
import '../../widgets/empty_state.dart';
import '../../widgets/reminder_card.dart';
import '../../widgets/section_header.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() => ref.read(remindersProvider.notifier).load();

  // ── Mark done ──────────────────────────────────────────────────────────────

  Future<void> _markDone(ReminderWithVisit rwv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Done'),
        content: const Text(
            'This will mark the follow-up as done and move it to the past section.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Mark Done')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(remindersProvider.notifier).deactivate(rwv.reminder.id);
  }

  // ── Reschedule ─────────────────────────────────────────────────────────────

  Future<void> _reschedule(ReminderWithVisit rwv) async {
    final current =
        _parseDate(rwv.reminder.followUpDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(DateTime.now())
          ? DateTime.now()
          : current,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    final newDate =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    if (newDate == rwv.reminder.followUpDate) return;

    await ref
        .read(remindersProvider.notifier)
        .reschedule(rwv.reminder.id, rwv.reminder.visitId, newDate);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rescheduled to ${du.formatVisitDate(newDate)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _delete(ReminderWithVisit rwv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text(
            'The visit will not be deleted — only this follow-up reminder.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(remindersProvider.notifier)
        .deleteReminder(rwv.reminder.id);
  }

  DateTime? _parseDate(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(remindersProvider);
    final upcoming = state.upcoming;
    final past = state.past;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: upcoming.isEmpty && past.isEmpty
          ? EmptyState(
              icon: Icons.calendar_month_outlined,
              title: 'No reminders',
              subtitle:
                  'Follow-up dates you add to visits will appear here.',
            )
          : ListView(
              padding: const EdgeInsets.only(
                  top: Spacing.sm, bottom: Spacing.xl),
              children: [
                // ── UPCOMING section ───────────────────────────────────
                const SectionHeader(title: 'UPCOMING'),
                if (upcoming.isEmpty)
                  _SectionEmpty(
                    icon: Icons.calendar_today_outlined,
                    label: 'No upcoming reminders',
                  )
                else
                  ...upcoming.map((rwv) => ReminderCard(
                        rwv: rwv,
                        onTap: () =>
                            context.push('/visits/${rwv.reminder.visitId}'),
                        onMarkDone: () => _markDone(rwv),
                        onReschedule: () => _reschedule(rwv),
                        onDelete: () => _delete(rwv),
                      )),

                const SizedBox(height: Spacing.sm),

                // ── PAST section ────────────────────────────────────────
                const SectionHeader(title: 'PAST'),
                if (past.isEmpty)
                  _SectionEmpty(
                    icon: Icons.calendar_month_outlined,
                    label: 'No past reminders',
                  )
                else
                  ...past.map((rwv) => _PastReminderRow(
                        rwv: rwv,
                        onTap: () =>
                            context.push('/visits/${rwv.reminder.visitId}'),
                        onDelete: () => _delete(rwv),
                      )),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionEmpty extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionEmpty({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textDisabled),
          const SizedBox(width: Spacing.sm),
          Text(label,
              style: AppText.body.copyWith(color: AppColors.textDisabled)),
        ],
      ),
    );
  }
}

/// Compact read-only row for past / deactivated reminders.
class _PastReminderRow extends StatelessWidget {
  final ReminderWithVisit rwv;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _PastReminderRow(
      {required this.rwv, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final reminder = rwv.reminder;
    final done = reminder.isActive == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Spacing.md, 0, Spacing.md, Spacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md, vertical: Spacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              done
                  ? Icons.check_circle_outline
                  : Icons.event_busy_outlined,
              size: 18,
              color: AppColors.textDisabled,
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rwv.doctorName ?? 'Unknown Doctor',
                    style: AppText.body
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${done ? 'Done' : 'Overdue'} · ${du.formatVisitDate(reminder.followUpDate)}',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 16, color: AppColors.textDisabled),
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
