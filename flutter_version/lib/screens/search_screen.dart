import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../models/query_results.dart';
import '../providers/visits_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/visit_card.dart';

// ---------------------------------------------------------------------------
// Match-hint helper
// ---------------------------------------------------------------------------

const _searchableFields = [
  (key: 'doctorName', label: 'Doctor name'),
  (key: 'clinicName', label: 'Clinic name'),
  (key: 'symptoms', label: 'Symptoms'),
  (key: 'diagnosis', label: 'Diagnosis'),
  (key: 'notes', label: 'Notes'),
];

String? _matchHint(Visit visit, String query) {
  final q = query.toLowerCase().trim();
  if (q.isEmpty) return null;
  for (final f in _searchableFields) {
    final String? val = switch (f.key) {
      'doctorName' => visit.doctorName,
      'clinicName' => visit.clinicName,
      'symptoms' => visit.symptoms,
      'diagnosis' => visit.diagnosis,
      'notes' => visit.notes,
      _ => null,
    };
    if (val != null && val.toLowerCase().contains(q)) {
      return 'Matched in: ${f.label}';
    }
  }
  return 'Matched in: visit content';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(visitsProvider.notifier).loadRecent(10);
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    ref.read(visitsProvider.notifier).clearSearch();
    super.dispose();
  }

  void _onChanged(String text) {
    setState(() => _query = text);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_query == text) {
        ref.read(visitsProvider.notifier).search(text.trim());
      }
    });
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitsProvider);
    final isSearching = _query.trim().isNotEmpty;
    final results = state.searchResults;
    final recent = state.recentVisits;

    return Scaffold(
      // Custom header replacing the AppBar — full primary color
      body: Column(
        children: [
          // ── Custom search header ─────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + Spacing.xs,
              bottom: Spacing.xs,
              left: Spacing.xs,
              right: Spacing.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 18,
                            color: Colors.white70),
                        const SizedBox(width: Spacing.xs),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: _onChanged,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Search visits…',
                              hintStyle: TextStyle(
                                  color: Colors.white60, fontSize: 15),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textInputAction: TextInputAction.search,
                            autocorrect: false,
                          ),
                        ),
                        if (_query.isNotEmpty)
                          GestureDetector(
                            onTap: _clear,
                            child: const Icon(Icons.cancel,
                                size: 17, color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Results / recent list ─────────────────────────────────────────
          Expanded(
            child: isSearching
                ? _buildResults(results)
                : _buildRecent(recent),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<VisitWithMember> results) {
    if (results.isEmpty && _query.trim().isNotEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No visits found',
        subtitle: 'No visits found for "${_query.trim()}"',
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: Spacing.xs, bottom: Spacing.xl),
      itemCount: results.isEmpty ? 0 : results.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.md, Spacing.sm, Spacing.md, Spacing.xs),
            child: Text(
              'Results for "${_query.trim()}"',
              style: AppText.h3,
            ),
          );
        }
        final vwm = results[i - 1];
        final hint = _matchHint(vwm.visit, _query.trim());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VisitCard.withMember(
              vwm,
              onTap: () => context.push('/visits/${vwm.visit.id}'),
            ),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.only(
                    left: Spacing.lg, bottom: Spacing.xs),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.manage_search,
                          size: 11, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        hint,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecent(List<Visit> recent) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: Spacing.xs, bottom: Spacing.xl),
      itemCount: recent.isEmpty ? 1 : recent.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.md, Spacing.sm, Spacing.md, Spacing.xs),
            child: const Text('Recent Visits', style: AppText.h3),
          );
        }
        final v = recent[i - 1];
        return VisitCard(
          visit: v,
          onTap: () => context.push('/visits/${v.id}'),
        );
      },
    );
  }
}
