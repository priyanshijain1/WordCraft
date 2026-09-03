import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SwitchListTile(
              value: isDark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setDark(value);
              },
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Dark mode',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Current: ${_themeLabel(themeMode)}',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
