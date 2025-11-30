import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_planner/providers/user_provider.dart';
import 'package:study_planner/services/firebase_data_service.dart';
import 'package:study_planner/theme/app_theme.dart';

String _sectionHeader(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(d.year, d.month, d.day);
  if (target == today) return 'Hoje';
  if (target == today.add(const Duration(days: 1))) return 'Amanhã';

  // If month or year differ from current, show full date with abbreviated month
  if (target.month != today.month || target.year != today.year) {
    const monthsPt = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    final mon = monthsPt[target.month - 1];
    return '${target.day} $mon, ${target.year}';
  }

  const weekdaysPt = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
  final wd = weekdaysPt[(d.weekday - 1) % 7];
  return '$wd ${d.day}';
}

/// ActivityPage + NewActivityPage
/// UI updated to follow the provided mock; logic preserved.

class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _activities = [];
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // Palette used for migration (distinct from UI palettes in NewActivity)
  final List<int> _migrationPalette = [
    0xFFD32F2F,
    0xFFF4511E,
    0xFFFF7043,
    0xFFFFC107,
    0xFFFFD600,
    0xFF1976D2,
    0xFF3949AB,
    0xFFE91E63,
  ];

  Future<void> _loadActivities() async {
    setState(() => _loading = true);
    final user = ref.read(userProvider);
    final email = user?.email;
    if (email == null) {
      setState(() {
        _activities = [];
        _loading = false;
      });
      return;
    }

    try {
      final items = await FirebaseDataService.fetchUserActivities(email);
      items.sort((a, b) {
        final aEnd =
            DateTime.tryParse(a['end']?.toString() ?? '') ?? DateTime.now();
        final bEnd =
            DateTime.tryParse(b['end']?.toString() ?? '') ?? DateTime.now();
        return aEnd.compareTo(bEnd);
      });
      setState(() {
        _activities = items;
      });
    } catch (e) {
      setState(() {
        _activities = [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openNewActivity() async {
    final user = ref.read(userProvider);
    final email = user?.email;
    if (email == null) return;

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NewActivityPage(email: email)),
    );
    if (created == true) await _loadActivities();
  }

  Future<void> _migrateColors() async {
    final user = ref.read(userProvider);
    final email = user?.email;
    if (email == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciando migração de cores...')),
    );

    int updated = 0;
    // Use a stable ordering: current _activities list sorted by end date
    for (var i = 0; i < _activities.length; i++) {
      final item = _activities[i];
      final id = item['id']?.toString();
      if (id == null) continue;

      final backupColor = item['color'];
      final newColor = _migrationPalette[i % _migrationPalette.length];

      final updatedItem = Map<String, dynamic>.from(item);
      // store previous color for rollback if needed
      updatedItem['color_old'] = backupColor;
      updatedItem['color'] = newColor;

      final ok = await FirebaseDataService.updateUserActivity(
        email: email,
        id: id,
        activity: updatedItem,
      );
      if (ok) updated++;
    }

    await _loadActivities();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Migração completa: $updated itens atualizados')),
    );
  }

  bool _isDone(Map<String, dynamic> item) {
    final v = item['done'];
    if (v == null) return false;
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is num) return v != 0;
    return false;
  }

  Future<void> _toggleComplete(Map<String, dynamic> activity) async {
    final user = ref.read(userProvider);
    final email = user?.email;
    if (email == null) return;
    final id = activity['id']?.toString();
    if (id == null) return;
    final currently = _isDone(activity);
    final backup = Map<String, dynamic>.from(activity);
    final updated = Map<String, dynamic>.from(activity);
    updated['done'] = !currently;
    if (!currently) {
      updated['completedAt'] = DateTime.now().toIso8601String();
    } else {
      updated.remove('completedAt');
    }

    final ok = await FirebaseDataService.updateUserActivity(
      email: email,
      id: id,
      activity: updated,
    );
    if (ok) {
      await _loadActivities();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currently
                ? 'Atividade marcada como concluída'
                : 'Atividade marcada como pendente',
          ),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () async {
              // restore previous state
              await FirebaseDataService.updateUserActivity(
                email: email,
                id: id,
                activity: backup,
              );
              await _loadActivities();
            },
          ),
        ),
      );
    }
  }

  Future<void> _deleteActivity(Map<String, dynamic> activity) async {
    final user = ref.read(userProvider);
    final email = user?.email;
    if (email == null) return;
    final id = activity['id']?.toString();
    if (id == null) return;

    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark
            ? Theme.of(ctx).cardColor
            : cs.surface,
        title: Text('Confirmar', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Deseja excluir esta atividade?',
          style: TextStyle(color: cs.onSurface.withOpacity(0.9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: TextStyle(color: cs.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Excluir', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // keep a copy in case user wants to undo
    final backup = Map<String, dynamic>.from(activity);

    final ok = await FirebaseDataService.deleteUserActivity(
      email: email,
      id: id,
    );
    if (ok) {
      await _loadActivities();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Atividade excluída'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () async {
              // recreate the activity if user undoes
              final recreated = await FirebaseDataService.saveUserActivity(
                email: email,
                activity: backup,
              );
              if (recreated) await _loadActivities();
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir atividade')),
      );
    }
  }

  Future<void> _editActivity(Map<String, dynamic> activity) async {
    final user = ref.read(userProvider);
    final email = user?.email;
    if (email == null) return;

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            NewActivityPage(email: email, existingActivity: activity),
      ),
    );
    if (updated == true) await _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final surface = theme.brightness == Brightness.dark
        ? theme.cardColor
        : cs.surface;

    // prepare grouping by day (based on end date) and apply completed filter
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in _activities) {
      final done = _isDone(item);
      if (done != _showCompleted) continue;
      final endIso = item['end']?.toString();
      DateTime end;
      try {
        end = DateTime.parse(endIso ?? '').toLocal();
      } catch (_) {
        end = DateTime.now();
      }
      final dayKey = DateTime(end.year, end.month, end.day).toIso8601String();
      grouped.putIfAbsent(dayKey, () => []).add(item);
    }
    final groupKeys = grouped.keys.toList()
      ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    return Scaffold(
      backgroundColor: cs.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // filter segmented control
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.primary.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showCompleted = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _showCompleted
                                    ? Colors.transparent
                                    : cs.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Pendentes',
                                  style: GoogleFonts.poppins(
                                    color: _showCompleted
                                        ? cs.onSurface
                                        : cs.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showCompleted = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _showCompleted
                                    ? cs.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Concluídas',
                                  style: GoogleFonts.poppins(
                                    color: _showCompleted
                                        ? cs.onPrimary
                                        : cs.primaryText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: groupKeys.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.checklist_rounded,
                                  size: 64,
                                  color: theme.disabledColor,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhuma atividade encontrada',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: cs.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _loadActivities,
                                  icon: Icon(
                                    Icons.refresh,
                                    color: cs.onSurface,
                                  ),
                                  label: Text(
                                    'Recarregar',
                                    style: TextStyle(color: cs.onSurface),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadActivities,
                            child: ListView.builder(
                              itemCount: groupKeys.length,
                              itemBuilder: (context, gIndex) {
                                final dayKey = groupKeys[gIndex];
                                final date = DateTime.parse(dayKey).toLocal();
                                final items = grouped[dayKey]!
                                  ..sort((a, b) {
                                    final aEnd =
                                        DateTime.tryParse(
                                          a['end']?.toString() ?? '',
                                        ) ??
                                        DateTime.now();
                                    final bEnd =
                                        DateTime.tryParse(
                                          b['end']?.toString() ?? '',
                                        ) ??
                                        DateTime.now();
                                    return aEnd.compareTo(bEnd);
                                  });

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8,
                                        top: 8,
                                      ),
                                      child: Text(
                                        _sectionHeader(date),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    ),
                                    ...items
                                        .map(
                                          (it) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: ActivityCardStyled(
                                              activity: it,
                                              onEdit: (map) =>
                                                  _editActivity(map),
                                              onDelete: (map) =>
                                                  _deleteActivity(map),
                                              onToggleComplete: (map) =>
                                                  _toggleComplete(map),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewActivity,
        icon: const Icon(Icons.add),
        label: Text(
          'Nova atividade',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: cs.primary,
      ),
    );
  }
}

class ActivityCardStyled extends StatelessWidget {
  final Map<String, dynamic> activity;
  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onDelete;
  final void Function(Map<String, dynamic>)? onToggleComplete;
  const ActivityCardStyled({
    super.key,
    required this.activity,
    this.onEdit,
    this.onDelete,
    this.onToggleComplete,
  });

  // time formatting handled inline in the card to allow separate lines for start/end

  IconData _iconFor(Map<String, dynamic> activity) {
    final category = (activity['category'] ?? 'atividade').toString();
    if (category == 'prova') return Icons.history_edu;
    return Icons.assignment;
  }

  Color _accentColor(Map<String, dynamic> activity) {
    final colorInt =
        int.tryParse(activity['color']?.toString() ?? '') ?? 0xFF2FD1C5;
    return Color(colorInt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final title = activity['title'] ?? 'Sem título';
    final desc = activity['description'] ?? '';
    final accent = _accentColor(activity);
    final surface = theme.brightness == Brightness.dark
        ? cs.primaryBackground
        : cs.surface;
    bool _done() {
      final v = activity['done'];
      if (v == null) return false;
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      if (v is num) return v != 0;
      return false;
    }

    final done = _done();

    return Container(
      decoration: BoxDecoration(
        color: cs.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done ? theme.disabledColor.withOpacity(0.4) : accent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(_iconFor(activity), color: accent, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (ctx) {
                      DateTime? s;
                      DateTime? e;
                      try {
                        if (activity['start'] != null) {
                          s = DateTime.parse(activity['start']).toLocal();
                        }
                      } catch (_) {}
                      try {
                        if (activity['end'] != null) {
                          e = DateTime.parse(activity['end']).toLocal();
                        }
                      } catch (_) {}

                      String fmt(DateTime d) {
                        final hour = d.hour.toString().padLeft(2, '0');
                        final minute = d.minute.toString().padLeft(2, '0');
                        return '$hour:$minute';
                      }

                      final TextStyle tss = GoogleFonts.poppins(
                        color: cs.onSurface.withOpacity(0.72),
                        fontSize: 12,
                      );

                      if (s != null && e != null) {
                        return Text('${fmt(s)}h - ${fmt(e)}h', style: tss);
                      }
                      if (e != null) return Text('${fmt(e)}h', style: tss);
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: done ? theme.disabledColor : cs.primaryText,
                      decoration: done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: done
                          ? theme.disabledColor
                          : cs.onSurface.withOpacity(0.85),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (onToggleComplete != null) onToggleComplete!(activity);
              },
              child: Icon(
                done ? Icons.check_circle : Icons.check_circle_outline,
                color: done ? Colors.green : theme.disabledColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            PopupMenuButton<int>(
              color: surface,
              icon: Icon(Icons.more_vert, color: cs.onSurface.withOpacity(0.7)),
              onSelected: (v) {
                if (v == 1) {
                  if (onEdit != null) onEdit!(activity);
                } else if (v == 2) {
                  if (onDelete != null) onDelete!(activity);
                } else if (v == 3) {
                  if (onToggleComplete != null) onToggleComplete!(activity);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 1, child: Text('Editar')),
                const PopupMenuItem(value: 2, child: Text('Excluir')),
                PopupMenuItem(
                  value: 3,
                  child: Text(
                    done ? 'Desmarcar como concluída' : 'Marcar como concluída',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewActivityPage extends StatefulWidget {
  final String email;
  final Map<String, dynamic>? existingActivity;
  const NewActivityPage({
    super.key,
    required this.email,
    this.existingActivity,
  });

  @override
  State<NewActivityPage> createState() => _NewActivityPageState();
}

class _NewActivityPageState extends State<NewActivityPage> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _editingId;

  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 2));
  String _category = 'atividade';

  final List<int> _colors = [
    0xFFE53935, // Red
    0xFFF57C00, // Orange
    0xFFFFB300, // Amber
    0xFF43A047, // Green
    0xFF00897B, // Teal
    0xFF1976D2, // Blue
    0xFF3949AB, // Indigo
    0xFF8E24AA, // Purple
  ];
  int _selectedColor = 0xFFE53935;

  bool get _canSave {
    final title = _titleController.text.trim();
    if (title.isEmpty) return false;
    // For exams (prova) require start < end
    if (_category == 'prova') {
      return _start.isBefore(_end);
    }
    // For normal activity, just require a title (end is always set)
    return true;
  }

  void initState() {
    super.initState();
    final existing = widget.existingActivity;
    if (existing != null) {
      _editingId = existing['id']?.toString();
      _titleController.text = existing['title']?.toString() ?? '';
      _detailsController.text = existing['description']?.toString() ?? '';
      _category = existing['category']?.toString() ?? 'atividade';
      try {
        if (existing['start'] != null)
          _start = DateTime.parse(existing['start']).toLocal();
      } catch (_) {}
      try {
        if (existing['end'] != null)
          _end = DateTime.parse(existing['end']).toLocal();
      } catch (_) {}
      try {
        _selectedColor =
            int.tryParse(existing['color']?.toString() ?? '') ?? _selectedColor;
      } catch (_) {}
    }
    // update UI when title changes to enable/disable the Create button
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(
    DateTime initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  String _format(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Widget _fieldCard({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).cardColor
          : Theme.of(context).colorScheme.surface),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _pill({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).cardColor
              : Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nome é obrigatório')));
      return;
    }

    final payload = <String, dynamic>{
      'title': title,
      'description': _detailsController.text.trim(),
      'category': _category,
      'end': _end.toIso8601String(),
      'color': _selectedColor,
      'createdAt':
          widget.existingActivity?['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
    };
    if (_category == 'prova') payload['start'] = _start.toIso8601String();
    bool ok = false;
    if (_editingId != null) {
      ok = await FirebaseDataService.updateUserActivity(
        email: widget.email,
        id: _editingId!,
        activity: payload,
      );
    } else {
      ok = await FirebaseDataService.saveUserActivity(
        email: widget.email,
        activity: payload,
      );
    }
    if (ok) Navigator.of(context).pop(true);
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao criar atividade')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.primaryBackground,
      appBar: AppBar(
        backgroundColor: cs.primaryBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _editingId != null ? 'Editar tarefa' : 'Criar tarefa',
          style: GoogleFonts.poppins(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldCard(
                child: TextField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(color: cs.onSurface),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Nome',
                    hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Date controls: if 'prova' show start + end; otherwise only end (prazo)
              if (_category == 'prova')
                Row(
                  children: [
                    Expanded(
                      child: _pill(
                        icon: Icons.play_arrow,
                        label: 'Início',
                        value: _format(_start),
                        onTap: () => _pickDateTime(
                          _start,
                          (d) => setState(() => _start = d),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pill(
                        icon: Icons.stop,
                        label: 'Término',
                        value: _format(_end),
                        onTap: () => _pickDateTime(
                          _end,
                          (d) => setState(() => _end = d),
                        ),
                      ),
                    ),
                  ],
                )
              else
                _pill(
                  icon: Icons.calendar_today,
                  label: 'Prazo',
                  value: _format(_end),
                  onTap: () =>
                      _pickDateTime(_end, (d) => setState(() => _end = d)),
                ),
              const SizedBox(height: 14),

              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _category,
                  items: [
                    DropdownMenuItem(
                      value: 'atividade',
                      child: Text(
                        'Atividade',
                        style: TextStyle(color: cs.primaryText),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'prova',
                      child: Text(
                        'Prova',
                        style: TextStyle(color: cs.onSurface),
                      ),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _category = v ?? 'atividade'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Categoria',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _fieldCard(
                child: TextField(
                  controller: _detailsController,
                  style: GoogleFonts.poppins(color: cs.onSurface),
                  maxLines: 5,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Detalhes...',
                    hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Palette
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _colors.map((c) {
                    final selected = _selectedColor == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: selected
                              ? Border.all(color: theme.dividerColor, width: 2)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _editingId != null ? 'Salvar' : 'Criar',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
