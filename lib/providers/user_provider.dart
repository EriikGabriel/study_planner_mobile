import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

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

  void setUser(User? user) {
    state = user;
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
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
