import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_planner/providers/user_provider.dart';
import 'package:study_planner/services/firebase_data_service.dart';
import 'package:study_planner/theme/app_theme.dart';

import 'activity_page.dart'; // importa sua ActivityPage
import 'settings_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    
    final user = ref.read(userProvider);
    final email = user?.email;

    if (email != null) {
      final subjects = await FirebaseDataService.fetchUserSubjects(email);
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Páginas correspondentes às abas
  List<Widget> get _pages => [
    AgendaPage(subjects: _subjects, onRefresh: _loadSubjects, isLoading: _isLoading),
    const ActivityPage(),
    const Placeholder(), // Notificações
    const SettingsPage(), // Configurações
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx).colorScheme;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        title: Text(
          _selectedIndex == 0
              ? "Agenda"
              : _selectedIndex == 1
              ? "Atividades"
              : _selectedIndex == 2
              ? "Notificações"
              : "Configurações",
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),

      // barra inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.primary,
        unselectedItemColor: theme.secondaryText,
        backgroundColor: theme.secondaryBackground,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline_rounded),
            label: 'Atividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_rounded),
            label: 'Notificações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),

      // corpo alternável
      body: _pages[_selectedIndex],
    );
  }
}

// Agenda original virou uma subpágina separada
class AgendaPage extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  final VoidCallback onRefresh;
  final bool isLoading;

  const AgendaPage({
    super.key,
    required this.subjects,
    required this.onRefresh,
    required this.isLoading,
  });

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  String? _selectedDay; // null = mostrar todos os dias
  late DateTime _currentMonth;
  late DateTime _selectedWeekStart;

  @override
  void initState() {
    super.initState();
    // Inicializa com a segunda-feira da semana atual
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    final weekDay = now.weekday;
    _selectedWeekStart = now.subtract(Duration(days: weekDay - 1));
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      // Atualiza a semana para a primeira segunda-feira do mês anterior
      final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final weekDay = firstDay.weekday;
      _selectedWeekStart = weekDay == 1 
          ? firstDay 
          : firstDay.add(Duration(days: 8 - weekDay));
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      // Atualiza a semana para a primeira segunda-feira do mês seguinte
      final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final weekDay = firstDay.weekday;
      _selectedWeekStart = weekDay == 1 
          ? firstDay 
          : firstDay.add(Duration(days: 8 - weekDay));
    });
  }

  String _getMonthName() {
    final months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[_currentMonth.month - 1];
  }

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final weekDay = now.weekday;
    final currentMonday = now.subtract(Duration(days: weekDay - 1));
    
    // Compara apenas ano, mês e dia (ignora hora/minuto/segundo)
    return _selectedWeekStart.year == currentMonday.year &&
           _selectedWeekStart.month == currentMonday.month &&
           _selectedWeekStart.day == currentMonday.day;
  }

  List<Map<String, dynamic>> _getWeekDays() {
    return List.generate(7, (index) {
      final day = _selectedWeekStart.add(Duration(days: index));
      final dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      final dayValues = ['SEGUNDA', 'TERCA', 'QUARTA', 'QUINTA', 'SEXTA', 'SABADO', 'DOMINGO'];
      
      return {
        'day': day.day.toString(),
        'label': dayNames[index],
        'value': dayValues[index],
        'date': day,
      };
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx).colorScheme;
    final weekDays = _getWeekDays();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navegação do mês
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: theme.secondaryText,
                ),
                onPressed: _previousMonth,
              ),
              Text(
                "${_getMonthName()} ${_currentMonth.year}",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: theme.secondaryText,
                    ),
                    onPressed: _nextMonth,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 24,
                      color: theme.secondaryText,
                    ),
                    onPressed: widget.onRefresh,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dias da semana com navegação
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: theme.secondaryText,
                ),
                onPressed: () {
                  setState(() {
                    _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
                    // Atualiza o mês exibido se necessário
                    _currentMonth = DateTime(_selectedWeekStart.year, _selectedWeekStart.month, 1);
                  });
                },
              ),
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildDayCard("Todos", "", _selectedDay == null, null),
                      ...weekDays.map((day) => _buildDayCard(
                        day['day']!,
                        day['label']!,
                        _selectedDay == day['value'],
                        day['value']!,
                      )).toList(),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: theme.secondaryText,
                ),
                onPressed: () {
                  setState(() {
                    _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
                    // Atualiza o mês exibido se necessário
                    _currentMonth = DateTime(_selectedWeekStart.year, _selectedWeekStart.month, 1);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedDay == null 
                      ? "Minhas Matérias" 
                      : _getDayDisplayName(_selectedDay!).replaceAll("📅 ", ""),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryText,
                  ),
                ),
              ),
              if (_selectedDay != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDay = null;
                    });
                  },
                  child: const Text("Ver todos"),
                ),
              if (!_isCurrentWeek())
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      final now = DateTime.now();
                      final weekDay = now.weekday;
                      _selectedWeekStart = now.subtract(Duration(days: weekDay - 1));
                      _currentMonth = DateTime(now.year, now.month, 1);
                    });
                  },
                  icon: const Icon(Icons.today, size: 16),
                  label: const Text("Hoje"),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.subjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma matéria encontrada',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: widget.onRefresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Recarregar'),
                            ),
                          ],
                        ),
                      )
                    : _buildGroupedSubjectsList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedSubjectsList(ColorScheme theme) {
    // Agrupa matérias por dia da semana
    final Map<String, List<Map<String, dynamic>>> groupedByDay = {};
    
    for (var subject in widget.subjects) {
      final horarios = subject['horarios'] as List<dynamic>? ?? [];
      if (horarios.isNotEmpty) {
        final dia = horarios[0]['dia']?.toString() ?? 'Sem dia definido';
        if (!groupedByDay.containsKey(dia)) {
          groupedByDay[dia] = [];
        }
        groupedByDay[dia]!.add(subject);
      }
    }

    // Filtra por dia selecionado (se houver)
    Map<String, List<Map<String, dynamic>>> filteredByDay = groupedByDay;
    if (_selectedDay != null) {
      filteredByDay = {
        for (var entry in groupedByDay.entries)
          if (_normalizeDayName(entry.key) == _selectedDay)
            entry.key: entry.value
      };
    }

    // Ordena as chaves (dias) na ordem correta
    final sortedDays = filteredByDay.keys.toList()
      ..sort((a, b) => _getDayOrder(a).compareTo(_getDayOrder(b)));

    // Se não há matérias no dia selecionado
    if (sortedDays.isEmpty && _selectedDay != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma matéria neste dia',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedDay = null;
                });
              },
              child: const Text('Ver todas as matérias'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: sortedDays.length,
      itemBuilder: (context, dayIndex) {
        final dia = sortedDays[dayIndex];
        final materiasNoDia = filteredByDay[dia]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do dia
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getDayDisplayName(dia),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${materiasNoDia.length} ${materiasNoDia.length == 1 ? "matéria" : "matérias"})',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de matérias do dia
            ...materiasNoDia.asMap().entries.map((entry) {
              final index = entry.key;
              final subject = entry.value;
              final horarios = subject['horarios'] as List<dynamic>? ?? [];
              
              String timeDisplay = "Horário não definido";
              if (horarios.isNotEmpty) {
                final horario = horarios[0];
                final inicio = horario['inicio']?.toString().substring(0, 5) ?? '';
                final fim = horario['fim']?.toString().substring(0, 5) ?? '';
                final sala = horario['sala'] ?? '';
                timeDisplay = "$inicio - $fim${sala.isNotEmpty ? ' • $sala' : ''}";
              }

              return TaskCard(
                title: subject['nome'] ?? 'Sem nome',
                subtitle: "Turma ${subject['turma']} • ${subject['ano']}/${subject['periodo']}",
                time: timeDisplay,
                color: _getColorForIndex(dayIndex * 10 + index),
                avatars: const [],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  int _getDayOrder(String dia) {
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
        return 999;
    }
  }

  String _getDayDisplayName(String dia) {
    final diaUpper = dia.toUpperCase();
    switch (diaUpper) {
      case 'SEGUNDA':
      case 'SEGUNDA-FEIRA':
        return '📅 Segunda-feira';
      case 'TERCA':
      case 'TERÇA':
      case 'TERÇA-FEIRA':
      case 'TERCA-FEIRA':
        return '📅 Terça-feira';
      case 'QUARTA':
      case 'QUARTA-FEIRA':
        return '📅 Quarta-feira';
      case 'QUINTA':
      case 'QUINTA-FEIRA':
        return '📅 Quinta-feira';
      case 'SEXTA':
      case 'SEXTA-FEIRA':
        return '📅 Sexta-feira';
      case 'SABADO':
      case 'SÁBADO':
        return '📅 Sábado';
      case 'DOMINGO':
        return '📅 Domingo';
      default:
        return '📅 $dia';
    }
  }

  String _normalizeDayName(String dia) {
    final diaUpper = dia.toUpperCase();
    switch (diaUpper) {
      case 'SEGUNDA':
      case 'SEGUNDA-FEIRA':
        return 'SEGUNDA';
      case 'TERCA':
      case 'TERÇA':
      case 'TERÇA-FEIRA':
      case 'TERCA-FEIRA':
        return 'TERCA';
      case 'QUARTA':
      case 'QUARTA-FEIRA':
        return 'QUARTA';
      case 'QUINTA':
      case 'QUINTA-FEIRA':
        return 'QUINTA';
      case 'SEXTA':
      case 'SEXTA-FEIRA':
        return 'SEXTA';
      case 'SABADO':
      case 'SÁBADO':
        return 'SABADO';
      case 'DOMINGO':
        return 'DOMINGO';
      default:
        return diaUpper;
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFFFFB84D), // Orange
      const Color(0xFF4CD7A5), // Green
      const Color(0xFFB894F6), // Purple
      const Color(0xFF5DADE2), // Blue
      const Color(0xFFFF6B6B), // Red
      const Color(0xFFFECA57), // Yellow
    ];
    return colors[index % colors.length];
  }

  Widget _buildDayCard(String day, String label, bool selected, String? dayValue) {
    final bool isTodosButton = dayValue == null;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = dayValue;
        });
      },
      child: Container(
        width: isTodosButton ? 70 : 60,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2FD1C5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF2FD1C5) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: GoogleFonts.poppins(
                fontSize: isTodosButton ? 14 : 20,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
            if (!isTodosButton) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: selected ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// TaskCard permanece igual
class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final List<String> avatars;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.avatars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: avatars.map((url) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
