import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/feed/presentation/feed_screen.dart';
import '../../features/cpo_calculator/presentation/cpo_calculator_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/feed',
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/feed',
            builder: (context, state) => const TenderScreen(),
          ),
          GoRoute(
            path: '/calculator',
            builder: (context, state) => const CpoCalculatorScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

class ScaffoldWithBottomNavBar extends StatelessWidget {
  const ScaffoldWithBottomNavBar({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (int index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            label: 'Tenders',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate),
            label: 'CPO Calc',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/calculator')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/feed');
        break;
      case 1:
        GoRouter.of(context).go('/calculator');
        break;
      case 2:
        GoRouter.of(context).go('/settings');
        break;
    }
  }
}
extension on Color {
  Color? get shade800 => null;
}
