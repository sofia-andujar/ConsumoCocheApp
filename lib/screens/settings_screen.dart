import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Personalizar tema')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Color de acento', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppTheme.accentColors.map((color) {
                      final selected = color == settings.accentColor;
                      return GestureDetector(
                        onTap: () => ref.read(themeSettingsProvider.notifier).setAccentColor(color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? theme.colorScheme.onSurface : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: selected
                                ? [BoxShadow(color: color.withAlpha(120), blurRadius: 8, spreadRadius: 1)]
                                : null,
                          ),
                          child: selected
                              ? Icon(Icons.check,
                                  color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  size: 22)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.brightness_6_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Modo visual', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<BrightnessMode>(
                    segments: const [
                      ButtonSegment(value: BrightnessMode.light, icon: Icon(Icons.light_mode), label: Text('Claro')),
                      ButtonSegment(value: BrightnessMode.dark, icon: Icon(Icons.dark_mode), label: Text('Oscuro')),
                      ButtonSegment(value: BrightnessMode.system, icon: Icon(Icons.settings_brightness), label: Text('Sistema')),
                    ],
                    selected: {settings.brightnessMode},
                    onSelectionChanged: (mode) => ref.read(themeSettingsProvider.notifier).setBrightnessMode(mode.first),
                    showSelectedIcon: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Los cambios se guardan y persisten entre sesiones.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
