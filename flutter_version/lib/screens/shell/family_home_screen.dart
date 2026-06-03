import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/members.dart' show colorFromHex;
import '../../constants/specialities.dart';
import '../../models/query_results.dart';
import '../../providers/members_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/member_card.dart';
import '../../widgets/section_header.dart';

class FamilyHomeScreen extends ConsumerStatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  ConsumerState<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends ConsumerState<FamilyHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    ref.read(membersProvider.notifier).loadMembers();
    ref.read(membersProvider.notifier).loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membersProvider);
    final members = state.members;
    final followUps = state.summary?.upcomingFollowUps ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Family'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/members/new'),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text(
              'Add',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: members.isEmpty
          ? EmptyState(
              icon: Icons.people_outline,
              title: 'No family members yet',
              subtitle: 'Tap "Add" to add your first family member',
              actionLabel: '+ Add Member',
              onAction: () => context.push('/members/new'),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.sm, Spacing.sm, Spacing.sm, 0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: Spacing.sm,
                      mainAxisSpacing: Spacing.sm,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final mws = members[i];
                        return MemberCard(
                          mws: mws,
                          onTap: () =>
                              context.push('/member/${mws.member.id}'),
                          onEdit: () => context
                              .push('/members/edit/${mws.member.id}'),
                        );
                      },
                      childCount: members.length,
                    ),
                  ),
                ),
                if (followUps.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SectionHeader(title: 'Upcoming Follow-ups'),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _FollowUpRow(item: followUps[i]),
                      childCount: followUps.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                    child: SizedBox(height: Spacing.xl)),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Follow-up row (upcoming follow-ups from summary)
// ---------------------------------------------------------------------------

class _FollowUpRow extends StatelessWidget {
  final UpcomingFollowUp item;
  const _FollowUpRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final spec = kSpecialities
        .where((s) => s.id == item.specialityId)
        .firstOrNull;
    final memberColor = item.memberColor != null
        ? colorFromHex(item.memberColor!)
        : AppColors.primary;

    return GestureDetector(
      onTap: () => context.push('/visits/${item.visitId}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Spacing.md, 0, Spacing.md, Spacing.sm),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadow.card,
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: Spacing.md),
              decoration: BoxDecoration(
                color: memberColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      item.memberName,
                      if (spec != null) spec.shortLabel,
                    ].join('  ·  '),
                    style: AppText.body
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.doctorName != null &&
                      item.doctorName!.isNotEmpty)
                    Text(item.doctorName!,
                        style: AppText.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  Text(
                    '${formatVisitDate(item.followUpDate)}  ·  ${formatDaysRemaining(item.followUpDate)}',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
