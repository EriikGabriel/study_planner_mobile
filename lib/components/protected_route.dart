import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_planner/pages/login_page.dart';
import 'package:study_planner/providers/user_provider.dart';

/// A small widget that protects a child route by checking if the user is logged in.
/// If no user is present, it returns the `LoginPage` instead.
class ProtectedRoute extends ConsumerWidget {
  final Widget child;

  const ProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    // If user is logged in, show the requested page.
    if (user != null) return child;

    // Otherwise show the login page. Using this approach means the route
    // remains the same but the login UI is shown — navigation will still
    // behave correctly if the user logs in and navigates.
    return const LoginPage();
  }
}
