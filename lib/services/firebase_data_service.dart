import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseDataService {
  static Future<bool> saveUserProfileAndDisciplines({
    required String email,
    required String displayName,
    required Map<String, dynamic> apiResponse,
  }) async {
    try {
      final db = FirebaseDatabase.instance.ref();

      final safeEmail = email.replaceAll(".", "_");

      await db.child("users").child(safeEmail).set({
        "displayName": displayName,
        "subjects": apiResponse["data"], // salva direto o JSON
        "createdAt": DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print("Erro ao salvar no Firebase: $e");
      return false;
    }
  }

  /// Busca as matérias do usuário no Realtime Database
  static Future<List<Map<String, dynamic>>> fetchUserSubjects(String email) async {
    try {
      if (kDebugMode) print('🔍 [Firebase] Buscando matérias do usuário: $email');
      
      final db = FirebaseDatabase.instance.ref();
      final safeEmail = email.replaceAll(".", "_");
      
      final snapshot = await db
          .child('users')
          .child(safeEmail)
          .child('subjects')
          .get();

      if (!snapshot.exists) {
        if (kDebugMode) print('⚠️ [Firebase] Nenhuma matéria encontrada');
        return [];
      }

      final List<dynamic> data = snapshot.value as List<dynamic>;
      final List<Map<String, dynamic>> subjects = [];

      for (var subject in data) {
        if (subject != null && subject is Map) {
          subjects.add({
            'id': subject['id'],
            'nome': subject['atividade'] ?? 'Sem nome',
            'turma': subject['turma'] ?? 'N/A',
            'periodo': subject['periodo'],
            'ano': subject['ano'],
            'horarios': subject['horarios'] ?? [],
          });
        }
      }

      // Ordena por dia da semana e depois por horário
      subjects.sort((a, b) {
        final horariosA = a['horarios'] as List<dynamic>? ?? [];
        final horariosB = b['horarios'] as List<dynamic>? ?? [];

        // Se não tem horário, vai pro final
        if (horariosA.isEmpty) return 1;
        if (horariosB.isEmpty) return -1;

        // Pega o primeiro horário de cada matéria
        final horarioA = horariosA[0];
        final horarioB = horariosB[0];

        // Mapeia dias da semana para números (para ordenação)
        final diaA = _getDayOrder(horarioA['dia']?.toString() ?? '');
        final diaB = _getDayOrder(horarioB['dia']?.toString() ?? '');

        // Primeiro compara os dias
        if (diaA != diaB) {
          return diaA.compareTo(diaB);
        }

        // Se for o mesmo dia, compara os horários
        final inicioA = horarioA['inicio']?.toString() ?? '00:00:00';
        final inicioB = horarioB['inicio']?.toString() ?? '00:00:00';
        return inicioA.compareTo(inicioB);
      });

      if (kDebugMode) print('✅ [Firebase] ${subjects.length} matérias encontradas e ordenadas');
      return subjects;
    } catch (e) {
      if (kDebugMode) print('❌ [Firebase] Erro ao buscar matérias: $e');
      return [];
    }
  }

  /// Mapeia o dia da semana para um número (para ordenação)
  static int _getDayOrder(String dia) {
    final diaUpper = dia.toUpperCase();
    switch (diaUpper) {
      case 'SEGUNDA':
      case 'SEGUNDA-FEIRA':
        return 1;
      case 'TERCA':
      case 'TERÇA':
      case 'TERÇA-FEIRA':
      case 'TERCA-FEIRA':
        return 2;
      case 'QUARTA':
      case 'QUARTA-FEIRA':
        return 3;
      case 'QUINTA':
      case 'QUINTA-FEIRA':
        return 4;
      case 'SEXTA':
      case 'SEXTA-FEIRA':
        return 5;
      case 'SABADO':
      case 'SÁBADO':
        return 6;
      case 'DOMINGO':
        return 7;
      default:
        return 999; // Dias não reconhecidos vão pro final
    }
  }
}
