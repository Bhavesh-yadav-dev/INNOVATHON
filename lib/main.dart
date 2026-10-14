import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/statement/presentation/pages/pocketly_page.dart';

/// Starts the Pocketly application.
void main() => runApp(const PocketlyApp());

/// Application shell with the Pocketly light and dark themes.
class PocketlyApp extends StatelessWidget {
  /// Creates the app shell.
  const PocketlyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pocketly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const PocketlyPage(),
      );
}
