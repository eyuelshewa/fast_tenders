import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:fast_tenders/screens/feed_screen.dart';
import 'package:fast_tenders/screens/cpo_calculator_screen.dart';
import 'package:fast_tenders/screens/profile_screen.dart';
import 'package:fast_tenders/screens/login_screen.dart';
import 'package:fast_tenders/screens/signup_screen.dart';
import 'package:fast_tenders/screens/forgot_password_screen.dart';
import 'package:fast_tenders/screens/tender_detail_screen.dart';
import 'package:fast_tenders/screens/buisness_profile_screen.dart';
import 'package:fast_tenders/screens/notification_screen.dart';
import 'package:fast_tenders/screens/saved_tenders_screen.dart';
import 'package:fast_tenders/screens/generic_tender_list_screen.dart';
import 'package:core/core.dart';

import '../../l10n/app_localizations.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Stream<AuthState> authStateChanges) {
    _subscription = authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final authRefreshListenableProvider = Provider<AuthRefreshListenable>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthRefreshListenable(authRepository.authStateChanges);
});

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final refreshListenable = ref.watch(authRefreshListenableProvider);

  return GoRouter(
    initialLocation: '/feed',
    navigatorKey: _rootNavigatorKey,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isLoggedIn = authRepository.currentUser != null;
      final isAuthRoute =
          state.uri.toString() == '/login' ||
          state.uri.toString() == '/signup' ||
          state.uri.toString() == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/feed';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/business-profile',
        builder: (context, state) => const BusinessProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/saved-tenders',
        builder: (context, state) => const SavedTendersScreen(),
      ),
      GoRoute(
        path: '/my-tenders',
        builder: (context, state) => const GenericTenderListScreen(
          type: TenderListType.myTenders,
          title: 'My Tenders',
        ),
      ),
      GoRoute(
        path: '/free-tenders',
        builder: (context, state) => const GenericTenderListScreen(
          type: TenderListType.freeTenders,
          title: 'Free Tenders',
        ),
      ),
      GoRoute(
        path: '/unread-tenders',
        builder: (context, state) => const GenericTenderListScreen(
          type: TenderListType.unread,
          title: 'Unread Tenders',
        ),
      ),
      GoRoute(
        path: '/trashed-tenders',
        builder: (context, state) => const GenericTenderListScreen(
          type: TenderListType.trashed,
          title: 'Trashed Tenders',
        ),
      ),
      GoRoute(
        path: '/tender-details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final tenders = extra['tenders'] as List<Tender>;
          final initialIndex = extra['initialIndex'] as int;
          return TenderDetailScreen(
            tenders: tenders,
            initialIndex: initialIndex,
          );
        },
      ),
      // Stateful Navigation for Bottom Bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                builder: (context, state) => const TenderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calculator',
                builder: (context, state) => const CpoCalculatorScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithBottomNavBar extends StatelessWidget {
  const ScaffoldWithBottomNavBar({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list_alt),
            label: AppLocalizations.of(context)!.navTenders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calculate),
            label: AppLocalizations.of(context)!.navCpo,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.navProfile,
          ),
        ],
      ),
    );
  }
}
