import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:study_planner/components/protected_route.dart';
import 'package:study_planner/pages/activity_page.dart';
import 'package:study_planner/pages/login_page.dart';
import 'package:study_planner/pages/main_page.dart';
import 'package:study_planner/providers/theme_provider.dart';
import 'package:study_planner/providers/user_provider.dart';

import 'firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Erro ao inicializar o Firebase: $e');
  }

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'pt_br',
    supportedLocales: ['en', 'pt_br'],
  );

  runApp(LocalizedApp(delegate, ProviderScope(child: MainApp())));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final user = ref.watch(userProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final initFuture = themeNotifier.initialized;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: FutureBuilder<void>(
        future: initFuture,
        builder: (context, snapshot) {
          // while loading show a simple splash to avoid flicker
          if (snapshot.connectionState != ConnectionState.done) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo image (keeps same path used elsewhere)
                      Image.asset(
                        'assets/images/logo.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              theme: themeData,
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // If user is already logged in (Firebase preserves session), go to main
            home: user != null ? const MainPage() : const LoginPage(),
            routes: {
              '/login': (ctx) => const LoginPage(),
              '/main': (ctx) => const ProtectedRoute(child: MainPage()),
              '/activity': (ctx) => const ProtectedRoute(child: ActivityPage()),
            },
            theme: themeData,
          );
        },
      ),
    );
  }
}
