import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_planner/pages/settings_page.dart';
import 'package:widgetbook/widgetbook.dart';

final settingsPageStory = WidgetbookComponent(
  name: 'Settings Page',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return const ProviderScope(
          child: SettingsPage(),
        );
      },
    ),
  ],
);
