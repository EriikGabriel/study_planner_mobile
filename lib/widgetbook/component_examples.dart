library;

import 'package:flutter/material.dart';

class ExemploComponenteBom extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;

  const ExemploComponenteBom({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitulo!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isDisabled || isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Ação'),
          ),
        ],
      ),
    );
  }
}

/// ❌ RUIM: Componente sem flexibilidade
class ExemploComponenteRuim extends StatelessWidget {
  const ExemploComponenteRuim({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Título fixo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Subtítulo fixo', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Ação fixa
            },
            child: const Text('Ação'),
          ),
        ],
      ),
    );
  }
}

/// ✅ BOM: Use enums para estados discretos
enum ButtonState { normal, loading, disabled, success, error }

class BotaoComEstados extends StatelessWidget {
  final String label;
  final ButtonState state;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const BotaoComEstados({
    super.key,
    required this.label,
    this.state = ButtonState.normal,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    IconData? iconData;
    String displayLabel = label;

    switch (state) {
      case ButtonState.loading:
        displayLabel = '';
        break;
      case ButtonState.success:
        iconData = Icons.check;
        break;
      case ButtonState.error:
        iconData = Icons.error;
        break;
      case ButtonState.disabled:
      case ButtonState.normal:
        break;
    }

    return ElevatedButton(
      onPressed: state == ButtonState.normal ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: state == ButtonState.loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : iconData != null
          ? Icon(iconData)
          : Text(displayLabel),
    );
  }
}

/// ✅ BOM: Use factory constructors para variantes
class Card extends StatelessWidget {
  final String titulo;
  final String? descricao;
  final Color borderColor;
  final Color backgroundColor;
  final IconData? icon;
  final List<Widget>? actions;

  const Card({
    super.key,
    required this.titulo,
    this.descricao,
    this.borderColor = const Color(0xFFE0E0E0),
    this.backgroundColor = Colors.white,
    this.icon,
    this.actions,
  });

  /// Variante para atividade
  factory Card.activity({
    required String titulo,
    required String descricao,
    required String horario,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      titulo: titulo,
      descricao: descricao,
      borderColor: color,
      icon: icon,
      actions: [Text(horario, style: const TextStyle(fontSize: 12))],
    );
  }

  /// Variante para tarefa
  factory Card.task({
    required String titulo,
    required String subtitulo,
    required Color color,
  }) {
    return Card(titulo: titulo, descricao: subtitulo, backgroundColor: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: borderColor),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (descricao != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    descricao!,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) Column(children: actions!),
        ],
      ),
    );
  }
}
