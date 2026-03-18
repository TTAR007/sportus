import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activity_detail/activity_detail_screen.dart';
import '../features/activity_form/activity_form_screen.dart';
import '../features/activity_list/activity_list_screen.dart';
import '../features/profile/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ActivityListScreen(),
        routes: [
          GoRoute(
            path: 'activities/new',
            builder: (context, state) => const ActivityFormScreen(),
          ),
          GoRoute(
            path: 'activities/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ActivityDetailScreen(activityId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ActivityFormScreen(activityId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
