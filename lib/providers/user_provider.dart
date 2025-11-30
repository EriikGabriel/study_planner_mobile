import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null) {
    _initializeAuth();
  }

  void _initializeAuth() {
    try {
      state = FirebaseAuth.instance.currentUser;
      _authListener();
    } catch (e) {
      if (kDebugMode) {
        print('Firebase não inicializado (Widgetbook mode): $e');
      }
      state = null;
    }
  }

  void _authListener() {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        state = user;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao escutar mudanças de auth: $e');
      }
    }
  }

  // Set user and persist in SharedPreferences
  void setUser(User? user) {
    state = user;
    if (user != null) {
      _saveUserPrefs(user);
    } else {
      _clearUserPrefs();
    }
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao fazer signOut: $e');
      }
    }
    state = null;
    _clearUserPrefs();
  }

  // Persist user info locally
  Future<void> _saveUserPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uid', user.uid);
      if (user.email != null) await prefs.setString('email', user.email!);
    } catch (e) {
      if (kDebugMode) print('Erro ao salvar prefs do usuário: $e');
    }
  }

  Future<void> _clearUserPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('uid');
      await prefs.remove('email');
    } catch (e) {
      if (kDebugMode) print('Erro ao limpar prefs do usuário: $e');
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
