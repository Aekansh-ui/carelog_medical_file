import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/insurance_provider.dart';
import '../../providers/members_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/insurance_card.dart';

class InsuranceListScreen extends ConsumerStatefulWidget {
  final String memberId;

  const InsuranceListScreen({super.key, required this.memberId});

  @override
  ConsumerState<InsuranceListScreen> createState() =>
      _InsuranceListScreenState();
}

class _InsuranceListScreenState extends ConsumerState<InsuranceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() =>
      ref.read(insuranceProvider.notifier).loadForMember(widget.memberId);

  @override
  Widget build(BuildContext context) {
    final policies = ref.watch(insuranceProvider).policies;
    final member = ref
        .watch(membersProvider)
        .members
        .where((m) => m.member.id == widget.memberId)
        .firstOrNull
        ?.member;

    final title = member != null ? '${member.name} · Insurance' : 'Insurance';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          policies.isEmpty
              ? EmptyState(
                  icon: Icons.shield_outlined,
                  title: 'No insurance added',
                  subtitle:
                      'Add ${member?.name ?? "this member"}\'s health or life insurance so the details are handy when you need them.',
                  actionLabel: 'Add Insurance',
                  onAction: () => context
                      .push('/insurance/new?memberId=${widget.memberId}'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                      top: Spacing.sm, bottom: 88),
                  itemCount: policies.length,
                  itemBuilder: (_, i) => InsuranceCard(
                    pwdc: policies[i],
                    onTap: () => context
                        .push('/insurance/policy/${policies[i].policy.id}'),
                  ),
                ),
          Positioned(
            right: Spacing.lg,
            bottom: Spacing.lg,
            child: FloatingActionButton(
              heroTag: 'insurance_list_fab',
              onPressed: () => context
                  .push('/insurance/new?memberId=${widget.memberId}'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
