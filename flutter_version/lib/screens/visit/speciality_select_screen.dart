import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/body_parts.dart';
import '../../constants/body_speciality_map.dart';
import '../../constants/specialities.dart';
import '../../providers/visits_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/speciality_card.dart';

class SpecialitySelectScreen extends ConsumerStatefulWidget {
  final String bodyPartId;
  final String? memberId;

  const SpecialitySelectScreen({
    super.key,
    required this.bodyPartId,
    this.memberId,
  });

  @override
  ConsumerState<SpecialitySelectScreen> createState() =>
      _SpecialitySelectScreenState();
}

class _SpecialitySelectScreenState
    extends ConsumerState<SpecialitySelectScreen> {
  bool _showAll = false;
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCounts());
  }

  Future<void> _loadCounts() async {
    final counts = await ref
        .read(visitsProvider.notifier)
        .countsBySpeciality(memberId: widget.memberId);
    if (mounted) setState(() => _counts = counts);
  }

  List<Speciality> get _displayed {
    if (_showAll) return kSpecialities;
    return specialitiesForBodyPart(widget.bodyPartId);
  }

  @override
  Widget build(BuildContext context) {
    final bodyPart = bodyPartById(widget.bodyPartId);
    final displayed = _displayed;

    return Scaffold(
      appBar: AppBar(
        title: Text(bodyPart?.label ?? 'Speciality'),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.md, Spacing.md, Spacing.md, Spacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ToggleChip(
                        active: _showAll,
                        label: 'Show All Specialities',
                        onTap: () =>
                            setState(() => _showAll = !_showAll),
                      ),
                      if (!_showAll) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${displayed.length} specialit${displayed.length == 1 ? 'y' : 'ies'} for ${bodyPart?.label ?? 'this area'}',
                          style: AppText.caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.sm, 0, Spacing.sm, 88),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: Spacing.xs,
                    mainAxisSpacing: Spacing.xs,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final spec = displayed[i];
                      return SpecialityCard(
                        speciality: spec,
                        visitCount: _counts[spec.id] ?? 0,
                        onTap: () {
                          final q = widget.memberId != null
                              ? '?memberId=${widget.memberId}'
                              : '';
                          context.push(
                              '/visits/list/${spec.id}$q');
                        },
                      );
                    },
                    childCount: displayed.length,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: Spacing.lg,
            bottom: Spacing.lg,
            child: FloatingActionButton(
              heroTag: 'speciality_fab',
              onPressed: () {
                final q = _buildNewVisitQuery(null);
                context.push('/visits/new$q');
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _buildNewVisitQuery(String? specialityId) {
    final params = <String, String>{
      'bodyPartId': widget.bodyPartId,
      if (widget.memberId != null) 'memberId': widget.memberId!,
      if (specialityId != null) 'specialityId': specialityId, // ignore: use_null_aware_elements
    };
    if (params.isEmpty) return '';
    return '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
  }
}

class _ToggleChip extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;

  const _ToggleChip(
      {required this.active, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
