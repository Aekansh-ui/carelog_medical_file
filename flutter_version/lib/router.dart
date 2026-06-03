import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/shell/family_home_screen.dart';
import 'screens/shell/reports_screen.dart';
import 'screens/shell/reminders_screen.dart';
import 'screens/shell/settings_screen.dart';
import 'screens/member/member_home_screen.dart';
import 'screens/member/member_form_screen.dart';
import 'screens/visit/speciality_select_screen.dart';
import 'screens/visit/visit_list_screen.dart';
import 'screens/visit/visit_detail_screen.dart';
import 'screens/visit/visit_form_screen.dart';
import 'screens/insurance/insurance_list_screen.dart';
import 'screens/insurance/policy_detail_screen.dart';
import 'screens/insurance/insurance_form_screen.dart';
import 'screens/search_screen.dart';
import 'theme/app_theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ── Bottom-tab shell ──────────────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _NavShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, _) => const FamilyHomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/reminders', builder: (_, _) => const RemindersScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/settings', builder: (_, _) => const SettingsScreen()),
        ]),
      ],
    ),

    // ── Member routes ─────────────────────────────────────────────────────────
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/member/:memberId',
      builder: (_, state) =>
          MemberHomeScreen(memberId: state.pathParameters['memberId']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/members/new',
      pageBuilder: (_, _) => const MaterialPage(
        fullscreenDialog: true,
        child: MemberFormScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/members/edit/:memberId',
      pageBuilder: (_, state) => MaterialPage(
        fullscreenDialog: true,
        child: MemberFormScreen(memberId: state.pathParameters['memberId']),
      ),
    ),

    // ── Speciality + Visit routes ─────────────────────────────────────────────
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/speciality/:bodyPartId',
      builder: (_, state) => SpecialitySelectScreen(
        bodyPartId: state.pathParameters['bodyPartId']!,
        memberId: state.uri.queryParameters['memberId'],
      ),
    ),
    // Literal sub-paths declared before the param catch-all /visits/:visitId
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/visits/new',
      pageBuilder: (_, state) => MaterialPage(
        fullscreenDialog: true,
        child: VisitFormScreen(
          memberId: state.uri.queryParameters['memberId'],
          bodyPartId: state.uri.queryParameters['bodyPartId'],
          specialityId: state.uri.queryParameters['specialityId'],
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/visits/edit/:visitId',
      pageBuilder: (_, state) => MaterialPage(
        fullscreenDialog: true,
        child: VisitFormScreen(visitId: state.pathParameters['visitId']),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/visits/list/:specialityId',
      builder: (_, state) => VisitListScreen(
        specialityId: state.pathParameters['specialityId']!,
        memberId: state.uri.queryParameters['memberId'],
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/visits/:visitId',
      builder: (_, state) =>
          VisitDetailScreen(visitId: state.pathParameters['visitId']!),
    ),

    // ── Insurance routes ──────────────────────────────────────────────────────
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/insurance/new',
      pageBuilder: (_, state) => MaterialPage(
        fullscreenDialog: true,
        child: InsuranceFormScreen(
            memberId: state.uri.queryParameters['memberId']),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/insurance/edit/:policyId',
      pageBuilder: (_, state) => MaterialPage(
        fullscreenDialog: true,
        child: InsuranceFormScreen(policyId: state.pathParameters['policyId']),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/insurance/member/:memberId',
      builder: (_, state) =>
          InsuranceListScreen(memberId: state.pathParameters['memberId']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/insurance/policy/:policyId',
      builder: (_, state) =>
          PolicyDetailScreen(policyId: state.pathParameters['policyId']!),
    ),

    // ── Search ────────────────────────────────────────────────────────────────
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/search',
      builder: (_, _) => const SearchScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Bottom-tab shell widget
// ---------------------------------------------------------------------------

class _NavShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const _NavShell({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(
            i,
            initialLocation: i == shell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Family',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Reminders',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
