import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_planner/theme/app_theme.dart';

class ThemeProvider extends StateNotifier<ThemeData> {
  final Completer<void> _initCompleter = Completer<void>();

  ThemeProvider() : super(lightTheme) {
    _loadPreferences();
  }

  /// A future that completes when the provider finished loading preferences.
  Future<void> get initialized => _initCompleter.future;
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load primary color
    final colorValue = prefs.getInt('primaryColor');
    if (colorValue != null) {
      final color = Color(colorValue);
      setPrimaryColor(color);
    }

    // Load theme mode (dark / light) - prefer server (per-account) when available
    bool? isDark;
    // First try to read local preference
    isDark = prefs.getBool('isDarkMode');

    // If user logged in, try to read from realtime DB (per-account setting)
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      try {
        final safeEmail = user!.email!.replaceAll('.', '_');
        final snapshot = await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(safeEmail)
            .child('settings')
            .child('isDarkMode')
            .get();

        if (snapshot.exists && snapshot.value != null) {
          // Realtime Database returns booleans as dynamic, handle strings too
          final v = snapshot.value;
          if (v is bool) {
            isDark = v;
          } else if (v is String) {
            isDark = v.toLowerCase() == 'true';
          }
          // persist locally the server value
          final prefs2 = await SharedPreferences.getInstance();
          await prefs2.setBool('isDarkMode', isDark ?? false);
        }
      } catch (e) {
        if (kDebugMode) print('Erro ao carregar tema do servidor: $e');
      }
    }

    if (isDark != null) {
      setTheme(isDark);
    }

    // mark initialization complete
    if (!_initCompleter.isCompleted) {
      _initCompleter.complete();
    }
  }

  void toggleTheme() {
    if (state.brightness == Brightness.dark) {
      state = lightTheme.copyWith(
        primaryColor: state.primaryColor,
        colorScheme: lightTheme.colorScheme.copyWith(
          primary: state.primaryColor,
        ),
      );
      // persist locally
      SharedPreferences.getInstance().then((prefs) async {
        await prefs.setBool('isDarkMode', false);
      });
      // persist to DB if logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email != null) {
        final safeEmail = user!.email!.replaceAll('.', '_');
        FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(safeEmail)
            .child('settings')
            .update({'isDarkMode': false});
      }
    } else {
      state = darkTheme.copyWith(
        primaryColor: state.primaryColor,
        colorScheme: darkTheme.colorScheme.copyWith(
          primary: state.primaryColor,
        ),
      );
      // persist locally
      SharedPreferences.getInstance().then((prefs) async {
        await prefs.setBool('isDarkMode', true);
      });
      // persist to DB if logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email != null) {
        final safeEmail = user!.email!.replaceAll('.', '_');
        FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(safeEmail)
            .child('settings')
            .update({'isDarkMode': true});
      }
    }
  }

  void setTheme(bool isDarkMode) {
    if (isDarkMode) {
      state = darkTheme.copyWith(
        primaryColor: state.primaryColor,
        colorScheme: darkTheme.colorScheme.copyWith(
          primary: state.primaryColor,
        ),
      );
      SharedPreferences.getInstance().then((prefs) async {
        await prefs.setBool('isDarkMode', true);
      });
      // Persist to realtime DB for logged in users
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email != null) {
        final safeEmail = user!.email!.replaceAll('.', '_');
        FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(safeEmail)
            .child('settings')
            .update({'isDarkMode': true});
      }
    } else {
      state = lightTheme.copyWith(
        primaryColor: state.primaryColor,
        colorScheme: lightTheme.colorScheme.copyWith(
          primary: state.primaryColor,
        ),
      );
      SharedPreferences.getInstance().then((prefs) async {
        await prefs.setBool('isDarkMode', false);
      });
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email != null) {
        final safeEmail = user!.email!.replaceAll('.', '_');
        FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(safeEmail)
            .child('settings')
            .update({'isDarkMode': false});
      }
    }
  }

  void setPrimaryColor(Color color) async {
    if (state.brightness == Brightness.dark) {
      state = darkTheme.copyWith(
        primaryColor: color,
        colorScheme: darkTheme.colorScheme.copyWith(primary: color),
      );
    } else {
      state = lightTheme.copyWith(
        primaryColor: color,
        colorScheme: lightTheme.colorScheme.copyWith(primary: color),
      );
    }
    // persist primary color
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
  }
}

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeData>((ref) {
  return ThemeProvider();
});
