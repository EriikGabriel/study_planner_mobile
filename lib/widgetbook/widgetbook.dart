import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:study_planner/pages/activity_page.dart';
import 'package:study_planner/pages/login_page.dart';
import 'package:study_planner/pages/main_page.dart';
import 'package:study_planner/pages/settings_page.dart';
import 'package:study_planner/theme/app_theme.dart';
import 'package:widgetbook/widgetbook.dart';

void main() async {
  // Inicializar flutter_translate
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'pt_br',
    supportedLocales: ['en', 'pt_br', 'es', 'fr', 'zh'],
  );

  runApp(
    LocalizedApp(
      delegate,
      ProviderScope(
        child: Widgetbook.material(
          addons: [
            MaterialThemeAddon(
              themes: [
                WidgetbookTheme(name: 'Light', data: lightTheme),
                WidgetbookTheme(name: 'Dark', data: darkTheme),
              ],
            ),
            DeviceFrameAddon(
              devices: [
                Devices.ios.iPhoneSE,
                Devices.ios.iPhone13,
                Devices.android.smallPhone,
                Devices.android.mediumPhone,
              ],
            ),
            TextScaleAddon(scales: [0.85, 1.0, 1.15, 1.3]),
          ],
          directories: [
            WidgetbookCategory(
              name: 'Pages',
              children: [
                WidgetbookComponent(
                  name: 'Login Page',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Default',
                      builder: (context) => const LoginPage(),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'Main Page',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Default',
                      builder: (context) => const MainPage(),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'Activity Page',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Default',
                      builder: (context) => const ActivityPage(),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'Settings Page',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Default',
                      builder: (context) => const SettingsPage(),
                    ),
                  ],
                ),
              ],
            ),
            WidgetbookCategory(
              name: 'Components',
              children: [
                WidgetbookComponent(
                  name: 'Buttons',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Primary Button',
                      builder: (context) => _buildPrimaryButton(),
                    ),
                    WidgetbookUseCase(
                      name: 'Secondary Button',
                      builder: (context) => _buildSecondaryButton(),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'Cards',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Activity Card',
                      builder: (context) => _buildActivityCard(),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'Text Fields',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Email Input',
                      builder: (context) => _buildEmailField(),
                    ),
                    WidgetbookUseCase(
                      name: 'Password Input',
                      builder: (context) => _buildPasswordField(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPrimaryButton() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2FD1C5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Primary Button'),
    ),
  );
}

Widget _buildSecondaryButton() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF2FD1C5), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Secondary Button'),
    ),
  );
}

Widget _buildActivityCard() {
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}

Widget _buildEmailField() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: TextField(
      decoration: InputDecoration(
        hintText: 'seu@email.com',
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2FD1C5), width: 2),
        ),
      ),
    ),
  );
}

Widget _buildPasswordField() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: TextField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: '••••••••',
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: const Icon(Icons.visibility_off_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2FD1C5), width: 2),
        ),
      ),
    ),
  );
}
