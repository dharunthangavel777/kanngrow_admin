import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/admin_scaffold.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/users/users_screen.dart';
import '../features/ecommerce/ecommerce_screen.dart';
import '../features/ai_management/ai_management_screen.dart';
import '../features/chat_logs/chat_logs_screen.dart';
import '../features/ideas/ideas_screen.dart';
import '../features/validation/validation_screen.dart';
import '../features/roadmaps/roadmaps_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/subscriptions/subscriptions_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/feedback/feedback_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/platform_context/platform_context_screen.dart';
import '../features/user_intelligence/user_dna_dashboard_screen.dart';
import '../features/hot_news/hot_news_screen.dart';
import 'admin_auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final AdminAuthProvider adminAuthProvider = AdminAuthProvider();

final GoRouter adminRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: adminAuthProvider,
  redirect: (context, state) {
    final isLoggedIn = adminAuthProvider.isLoggedIn;
    final isGoingToLogin = state.matchedLocation == '/login';

    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }
    if (isLoggedIn && isGoingToLogin) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AdminScaffold(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/users', builder: (context, state) => const UsersScreen()),
        GoRoute(path: '/ecommerce', builder: (context, state) => const EcommerceScreen()),
        GoRoute(path: '/ai', builder: (context, state) => const AiManagementScreen()),
        GoRoute(path: '/chat', builder: (context, state) => const ChatLogsScreen()),
        GoRoute(path: '/ideas', builder: (context, state) => const IdeasScreen()),
        GoRoute(path: '/validation', builder: (context, state) => const ValidationScreen()),
        GoRoute(path: '/roadmaps', builder: (context, state) => const RoadmapsScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
        GoRoute(path: '/subscriptions', builder: (context, state) => const SubscriptionsScreen()),
        GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
        GoRoute(path: '/feedback', builder: (context, state) => const FeedbackScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/platform-context', builder: (context, state) => const PlatformContextScreen()),
        GoRoute(path: '/user-dna', builder: (context, state) => const UserDnaDashboardScreen()),
        GoRoute(path: '/hot-news', builder: (context, state) => const HotNewsScreen()),
      ],
    ),
  ],
);
