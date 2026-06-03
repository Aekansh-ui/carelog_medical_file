import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/specialities.dart';
import '../../providers/visits_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/visit_card.dart';

class VisitListScreen extends ConsumerStatefulWidget {
  final String specialityId;
  final String? memberId;

  const VisitListScreen({
    super.key,
    required this.specialityId,
    this.memberId,
  });

  @override
  ConsumerState<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends ConsumerState<VisitListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    ref.read(visitsProvider.notifier).loadBySpeciality(
          widget.specialityId,
          memberId: widget.memberId,
        );
  }

  String _newVisitQuery() {
    final params = <String>[
      'specialityId=${widget.specialityId}',
      if (widget.memberId != null) 'memberId=${widget.memberId}',
    ];
    return '?${params.join('&')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitsProvider);
    final visits = state.listVisits;
    final spec = kSpecialities
        .where((s) => s.id == widget.specialityId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(spec?.label ?? 'Visits')),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb strip
              _Breadcrumb(speciality: spec),
              Expanded(
                child: visits.isEmpty
                    ? EmptyState(
                        icon: spec?.icon ?? Icons.medical_services_outlined,
                        title: 'No visits yet',
                        subtitle:
                            'No ${spec?.label ?? ''} visits recorded.\nTap + to add the first one.',
                        actionLabel: 'Add Visit',
                        onAction: () =>
                            context.push('/visits/new${_newVisitQuery()}'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                            top: Spacing.sm, bottom: 88),
                        itemCount: visits.length,
                        itemBuilder: (_, i) => VisitCard(
                          visit: visits[i],
                          onTap: () =>
                              context.push('/visits/${visits[i].id}'),
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            right: Spacing.lg,
            bottom: Spacing.lg,
            child: FloatingActionButton(
              heroTag: 'visit_list_fab',
              onPressed: () =>
                  context.push('/visits/new${_newVisitQuery()}'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  final Speciality? speciality;
  const _Breadcrumb({this.speciality});

  @override
  Widget build(BuildContext context) {
    if (speciality == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.xs),
      color: AppColors.surface,
      child: Row(
        children: [
          Icon(speciality!.icon, size: 13, color: speciality!.color),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: speciality!.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              speciality!.shortLabel,
              style: TextStyle(
                  fontSize: 11,
                  color: speciality!.color,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
