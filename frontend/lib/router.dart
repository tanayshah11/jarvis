import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/animations.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/boot_transition_screen.dart';
import 'features/auth/screens/new_login_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/chat/screens/conversation_history_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/help/help_screen.dart';
import 'features/memory/screens/memory_hub_screen.dart';
import 'features/memory/screens/memory_search_screen.dart';
import 'features/memory/screens/memory_detail_screen.dart';
import 'features/integrations/screens/integrations_hub_screen.dart';

// Navigation keys for preserving state
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// iOS-native page transition
Page<dynamic> _buildCupertinoPage({
  required Widget child,
  required GoRouterState state,
  bool fullscreenDialog = false,
}) {
  return CupertinoPage(
    key: state.pageKey,
    child: child,
    fullscreenDialog: fullscreenDialog,
  );
}

/// Fade transition for auth screens
Page<dynamic> _buildFadePage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppAnimations.medium,
    reverseTransitionDuration: AppAnimations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Slide transition from right for sidebar navigation
Page<dynamic> _buildSlideFromRightPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppAnimations.normal,
    reverseTransitionDuration: AppAnimations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  );
}

/// Router provider with tab-based navigation
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isAuthRoute =
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/boot-transition' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/sign-up' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation.startsWith('/reset-password');
      final isOnboarding = state.matchedLocation == '/onboarding';

      // If not authenticated and not on auth route, redirect to login
      if (!isAuthenticated && !isAuthRoute && !isOnboarding) {
        return '/login';
      }

      // If authenticated and on auth route (but not splash or boot-transition)
      if (isAuthenticated && isAuthRoute &&
          state.matchedLocation != '/splash' &&
          state.matchedLocation != '/boot-transition') {
        // If user doesn't have a profile, go to onboarding
        if (!authState.hasProfile) {
          return '/onboarding';
        }
        return '/chat';
      }

      return null;
    },
    routes: [
      // ============================
      // Auth routes (no tab bar)
      // ============================
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            _buildFadePage(child: const SplashScreen(), state: state),
      ),
      GoRoute(
        path: '/boot-transition',
        pageBuilder: (context, state) =>
            _buildFadePage(child: const BootTransitionScreen(), state: state),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _buildFadePage(child: const NewLoginScreen(), state: state),
      ),
      GoRoute(
        path: '/sign-up',
        pageBuilder: (context, state) =>
            _buildFadePage(child: const SignUpScreen(), state: state),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) =>
            _buildFadePage(child: const ForgotPasswordScreen(), state: state),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return _buildFadePage(
            child: ResetPasswordScreen(token: token),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _buildFadePage(child: const OnboardingScreen(), state: state),
      ),

      // ============================
      // Main app - Chat with sidebar navigation
      // ============================
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) => _buildCupertinoPage(
          child: const ChatScreen(),
          state: state,
        ),
      ),

      // History (accessible from sidebar)
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => _buildSlideFromRightPage(
          child: const ConversationHistoryScreen(),
          state: state,
        ),
      ),

      // Memory (accessible from sidebar)
      GoRoute(
        path: '/memory',
        pageBuilder: (context, state) => _buildSlideFromRightPage(
          child: const MemoryHubScreen(),
          state: state,
        ),
        routes: [
          GoRoute(
            path: 'search',
            pageBuilder: (context, state) => _buildCupertinoPage(
              child: const MemorySearchScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'detail/:nodeId',
            pageBuilder: (context, state) {
              final nodeId = state.pathParameters['nodeId']!;
              return _buildCupertinoPage(
                child: MemoryDetailScreen(nodeId: nodeId),
                state: state,
                fullscreenDialog: true,
              );
            },
          ),
        ],
      ),

      // Settings (accessible from sidebar)
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _buildSlideFromRightPage(
          child: const SettingsScreen(),
          state: state,
        ),
        routes: [
          GoRoute(
            path: 'profile',
            pageBuilder: (context, state) => _buildCupertinoPage(
              child: const ProfileScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'help',
            pageBuilder: (context, state) => _buildCupertinoPage(
              child: const HelpScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'integrations',
            pageBuilder: (context, state) => _buildCupertinoPage(
              child: const IntegrationsHubScreen(),
              state: state,
            ),
          ),
        ],
      ),

      // Legacy routes (redirect to new paths)
      GoRoute(path: '/profile', redirect: (_, _) => '/settings/profile'),
      GoRoute(path: '/help', redirect: (_, _) => '/settings/help'),
      GoRoute(path: '/memory/search', redirect: (_, _) => '/memory/search'),
    ],
    errorBuilder: (context, state) => CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Error')),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: CupertinoTheme.of(
                context,
              ).textTheme.navLargeTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: CupertinoTheme.of(
                context,
              ).textTheme.textStyle.copyWith(color: CupertinoColors.systemGrey),
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: () => context.go('/chat'),
              child: const Text('Go to Chat'),
            ),
          ],
        ),
      ),
    ),
  );
});
