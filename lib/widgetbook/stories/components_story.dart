library;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Exemplo de story para componentes de botão
final buttonComponentsStory = WidgetbookComponent(
  name: 'Buttons',
  useCases: [
    WidgetbookUseCase(
      name: 'Primary Button',
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2FD1C5),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Primary Button'),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Secondary Button',
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2FD1C5), width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Secondary Button'),
          ),
        );
      },
    ),
  ],
);

/// Exemplo de story para cards
final cardComponentsStory = WidgetbookComponent(
  name: 'Cards',
  useCases: [
    WidgetbookUseCase(
      name: 'Activity Card',
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB5B5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate_rounded,
                  color: Color(0xFFFFB5B5),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '10:30 - 11:30',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Matemática',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Crie uma história emocional',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);

/// Exemplo de story para campos de texto
final textFieldComponentsStory = WidgetbookComponent(
  name: 'Text Fields',
  useCases: [
    WidgetbookUseCase(
      name: 'Email Input',
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'seu@email.com',
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2FD1C5),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Password Input',
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: '••••••••',
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: const Icon(Icons.visibility_off_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2FD1C5),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
