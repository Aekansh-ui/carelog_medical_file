import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/body_parts.dart';
import '../../providers/members_provider.dart';
import '../../providers/reminders_provider.dart';
import '../../providers/visits_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/visit_card.dart';

class MemberHomeScreen extends ConsumerStatefulWidget {
  final String memberId;

  const MemberHomeScreen({super.key, required this.memberId});

  @override
  ConsumerState<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends ConsumerState<MemberHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    ref
        .read(visitsProvider.notifier)
        .loadRecentForMember(widget.memberId, 5);
    ref.read(remindersProvider.notifier).load();
    if (ref.read(membersProvider).members.isEmpty) {
      ref.read(membersProvider.notifier).loadMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersState = ref.watch(membersProvider);
    final visitsState = ref.watch(visitsProvider);
    final remindersState = ref.watch(remindersProvider);

    final mws = membersState.members
        .where((m) => m.member.id == widget.memberId)
        .firstOrNull;
    final recentVisits = visitsState.recentVisits;
    final upcomingCount = remindersState.upcoming.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(mws?.member.name ?? 'Member'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.go('/reminders'),
              ),
              if (upcomingCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        upcomingCount > 9 ? '9+' : '$upcomingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Insurance entry row
          SliverToBoxAdapter(
            child: _InsuranceRow(memberId: widget.memberId),
          ),
          // Body-part grid
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Medical Records'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.sm, 0, Spacing.sm, 0),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: Spacing.sm,
                mainAxisSpacing: Spacing.sm,
                childAspectRatio: 1.45,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final bp = kBodyParts[i];
                  return _BodyPartCard(
                    bodyPart: bp,
                    onTap: () => context.push(
                        '/speciality/${bp.id}?memberId=${widget.memberId}'),
                  );
                },
                childCount: kBodyParts.length,
              ),
            ),
          ),
          // Recent visits
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Recent Visits'),
          ),
          SliverToBoxAdapter(
            child: recentVisits.isEmpty
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(
                        Spacing.md, 0, Spacing.md, Spacing.md),
                    child: EmptyState(
                      icon: Icons.medical_services_outlined,
                      title: 'No visits yet',
                      subtitle:
                          'Tap a body part above to add your first visit',
                    ),
                  )
                : SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md),
                      itemCount: recentVisits.length,
                      itemBuilder: (_, i) {
                        final v = recentVisits[i];
                        return Padding(
                          padding:
                              const EdgeInsets.only(right: Spacing.sm),
                          child: VisitCard(
                            visit: v,
                            onTap: () =>
                                context.push('/visits/${v.id}'),
                            compact: true,
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: Spacing.xl)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Insurance entry row
// ---------------------------------------------------------------------------

class _InsuranceRow extends StatelessWidget {
  final String memberId;
  const _InsuranceRow({required this.memberId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/insurance/member/$memberId'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Spacing.md, Spacing.md, Spacing.md, 0),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.shield_outlined,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: Spacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Insurance', style: AppText.h3),
                  SizedBox(height: 2),
                  Text(
                    'Health & life policies, cards and helplines',
                    style: AppText.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body-part grid card
// ---------------------------------------------------------------------------

class _BodyPartCard extends StatelessWidget {
  final BodyPart bodyPart;
  final VoidCallback onTap;
  const _BodyPartCard({required this.bodyPart, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(bodyPart.icon, size: 32, color: AppColors.primary),
            const SizedBox(height: Spacing.xs),
            Text(
              bodyPart.label,
              style: AppText.label.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Spacing.xs),
              child: Text(
                bodyPart.description,
                style: AppText.caption,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
