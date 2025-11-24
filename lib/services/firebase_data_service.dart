import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Service to manage user data in Firebase Realtime Database
class FirebaseDataService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save user profile and academic data to Firebase Realtime Database
  /// Structure:
  /// users/
  ///   {userId}/
  ///     profile/
  ///       email
  ///       displayName
  ///       createdAt
  ///     disciplines/
  ///       {disciplineId}/
  ///         codigo
  ///         nome
  ///         creditos
  ///         professor
  ///         turma
  ///     schedules/
  ///       {scheduleId}/
  ///         discipline
  ///         day
  ///         startTime
  ///         endTime
  static Future<bool> saveUserProfileAndDisciplines({
    required String email,
    required String displayName,
    required Map<String, dynamic> apiResponse,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) print('❌ No authenticated user');
        return false;
      }

      final userId = user.uid;
      final now = DateTime.now().toIso8601String();

      // Create user profile
      final profileRef = _database.ref('users/$userId/profile');
      await profileRef.set({
        'email': email,
        'displayName': displayName,
        'createdAt': now,
        'updatedAt': now,
      });

      if (kDebugMode) print('✅ User profile saved');

      // Save disciplines/subjects
      await _saveDisciplines(userId, apiResponse);

      // Save schedules if available
      await _saveSchedules(userId, apiResponse);

      if (kDebugMode) print('✅ All user data saved successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error saving user data: $e');
      return false;
    }
  }

  /// Save disciplines from API response to Firebase
  static Future<void> _saveDisciplines(
    String userId,
    Map<String, dynamic> apiResponse,
  ) async {
    try {
      List<Map<String, dynamic>> disciplines = [];

      // Parse disciplines from API response
      if (apiResponse.containsKey('data')) {
        final data = apiResponse['data'];
        if (data is List) {
          for (final item in data) {
            disciplines.add({
              'codigo': item['codigo']?.toString() ?? 'N/A',
              'nome': item['nome']?.toString() ?? 'Sem nome',
              'creditos': item['creditos']?.toString() ?? '0',
              'professor': item['professor']?.toString() ?? 'N/A',
              'turma': item['turma']?.toString() ?? 'N/A',
              'addedAt': DateTime.now().toIso8601String(),
            });
          }
        }
      }

      // Save each discipline
      final disciplinesRef = _database.ref('users/$userId/disciplines');
      for (int i = 0; i < disciplines.length; i++) {
        final disciplineId = 'disc_${DateTime.now().millisecondsSinceEpoch}_$i';
        await disciplinesRef.child(disciplineId).set(disciplines[i]);
      }

      if (kDebugMode) print('✅ ${disciplines.length} disciplines saved');
    } catch (e) {
      if (kDebugMode) print('❌ Error saving disciplines: $e');
    }
  }

  /// Save schedules from API response to Firebase
  static Future<void> _saveSchedules(
    String userId,
    Map<String, dynamic> apiResponse,
  ) async {
    try {
      List<Map<String, dynamic>> schedules = [];

      // Parse schedules from API response if available
      if (apiResponse.containsKey('horarios')) {
        final horarios = apiResponse['horarios'];
        if (horarios is List) {
          for (final item in horarios) {
            schedules.add({
              'disciplina': item['disciplina']?.toString() ?? 'N/A',
              'dia': item['dia']?.toString() ?? 'N/A',
              'horaInicio': item['horaInicio']?.toString() ?? '00:00',
              'horaFim': item['horaFim']?.toString() ?? '00:00',
              'sala': item['sala']?.toString() ?? 'N/A',
              'addedAt': DateTime.now().toIso8601String(),
            });
          }
        }
      }

      // Save each schedule
      if (schedules.isNotEmpty) {
        final schedulesRef = _database.ref('users/$userId/schedules');
        for (int i = 0; i < schedules.length; i++) {
          final scheduleId =
              'sched_${DateTime.now().millisecondsSinceEpoch}_$i';
          await schedulesRef.child(scheduleId).set(schedules[i]);
        }
        if (kDebugMode) print('✅ ${schedules.length} schedules saved');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error saving schedules: $e');
    }
  }

  /// Get user profile from Firebase
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final ref = _database.ref('users/$userId/profile');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting user profile: $e');
      return null;
    }
  }

  /// Get all disciplines for a user
  static Future<List<Map<String, dynamic>>> getUserDisciplines(
    String userId,
  ) async {
    try {
      final ref = _database.ref('users/$userId/disciplines');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        return data.values
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ Error getting disciplines: $e');
      return [];
    }
  }

  /// Get all schedules for a user
  static Future<List<Map<String, dynamic>>> getUserSchedules(
    String userId,
  ) async {
    try {
      final ref = _database.ref('users/$userId/schedules');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        return data.values
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ Error getting schedules: $e');
      return [];
    }
  }

  /// Update user profile
  static Future<bool> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final ref = _database.ref('users/$userId/profile');
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await ref.update(updates);
      if (kDebugMode) print('✅ User profile updated');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error updating profile: $e');
      return false;
    }
  }

  /// Delete user data from Firebase (when needed)
  static Future<bool> deleteUserData(String userId) async {
    try {
      final ref = _database.ref('users/$userId');
      await ref.remove();
      if (kDebugMode) print('✅ User data deleted');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error deleting user data: $e');
      return false;
    }
  }
}
