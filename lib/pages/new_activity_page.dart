import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_planner/services/firebase_data_service.dart';

/// Standalone redesigned New Activity page.
/// Use by importing and pushing `NewActivityScreen(email: yourEmail)`.

class NewActivityScreen extends StatefulWidget {
  final String email;
  const NewActivityScreen({super.key, required this.email});

  @override
  State<NewActivityScreen> createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen> {
  final _titleController = TextEditingController();
  final _collabController = TextEditingController();
  final _detailsController = TextEditingController();

  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 2));
  String _category = 'atividade';

  final List<int> _colors = [
    0xFFD32F2F, // Red (strong)
    0xFFF4511E, // Deep Orange
    0xFFFF7043, // Orange
    0xFFFFC107, // Amber
    0xFFFFD600, // Yellow (accent)
    0xFF1976D2, // Blue
    0xFF3949AB, // Indigo
    0xFFE91E63, // Pink
  ];
  int _selectedColor = 0xFFD32F2F;

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

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

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
      'collaborators': _collabController.text.trim(),
      'category': _category,
      'end': _end.toIso8601String(),
      'color': _selectedColor,
      'createdAt': DateTime.now().toIso8601String(),
    };
    if (_category == 'prova') payload['start'] = _start.toIso8601String();

    final ok = await FirebaseDataService.saveUserActivity(
      email: widget.email,
      activity: payload,
    );
    if (ok) Navigator.of(context).pop(true);
    if (!ok)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao criar atividade')));
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor.withOpacity(0.03),
          blurRadius: 8,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      // use the theme's background (primary canvas) so dark mode applies
      appBar: AppBar(
        // AppBar uses cardColor for a subtle elevated surface look
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Criar tarefa 2',
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
              _card(
                child: TextField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(),
                  decoration: const InputDecoration.collapsed(hintText: 'Nome'),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _pill(
                      icon: Icons.schedule,
                      label: 'Start Time',
                      value: _fmt(_start),
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
                      label: 'End Time',
                      value: _fmt(_end),
                      onTap: () =>
                          _pickDateTime(_end, (d) => setState(() => _end = d)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _category,
                  items: const [
                    DropdownMenuItem(
                      value: 'atividade',
                      child: Text('Atividade'),
                    ),
                    DropdownMenuItem(value: 'prova', child: Text('Prova')),
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
              _card(
                child: TextField(
                  controller: _collabController,
                  style: GoogleFonts.poppins(),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Colaborar com',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _card(
                child: TextField(
                  controller: _detailsController,
                  style: GoogleFonts.poppins(),
                  maxLines: 5,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Detalhes',
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                              color: Theme.of(
                                context,
                              ).shadowColor.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: selected
                              ? Border.all(
                                  color: Theme.of(context).dividerColor,
                                  width: 2,
                                )
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
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Criar',
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
