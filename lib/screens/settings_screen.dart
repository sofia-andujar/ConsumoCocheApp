import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/import_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/refuel_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _importing = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(themeSettingsProvider);
    final currentLocale = ref.watch(localeProvider);
    final importState = ref.watch(importProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customizeTheme)),
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
                      Icon(Icons.language, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(l10n.language, style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'es', label: Text(l10n.spanish)),
                      ButtonSegment(value: 'en', label: Text(l10n.english)),
                      ButtonSegment(value: 'ca', label: Text(l10n.catalan)),
                    ],
                    selected: {currentLocale.languageCode},
                    onSelectionChanged: (selected) {
                      ref.read(localeProvider.notifier).setLocale(Locale(selected.first));
                    },
                    showSelectedIcon: false,
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
                      Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(l10n.accentColor, style: theme.textTheme.titleMedium),
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
                      Text(l10n.visualMode, style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<BrightnessMode>(
                    segments: [
                      ButtonSegment(value: BrightnessMode.light, icon: const Icon(Icons.light_mode), label: Text(l10n.lightMode)),
                      ButtonSegment(value: BrightnessMode.dark, icon: const Icon(Icons.dark_mode), label: Text(l10n.darkMode)),
                      ButtonSegment(value: BrightnessMode.system, icon: const Icon(Icons.settings_brightness), label: Text(l10n.systemMode)),
                    ],
                    selected: {settings.brightnessMode},
                    onSelectionChanged: (mode) => ref.read(themeSettingsProvider.notifier).setBrightnessMode(mode.first),
                    showSelectedIcon: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildImportCard(context, theme, l10n, importState),
          const SizedBox(height: 24),
          Text(
            l10n.settingsPersist,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImportCard(BuildContext context, ThemeData theme, AppLocalizations l10n, AsyncValue<bool> importState) {
    return importState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (imported) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.download, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(l10n.importData, style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l10n.importDataDescription, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                if (imported)
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.importDataDone, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green)),
                    ],
                  )
                else
                  _importing
                      ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                      : SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _doImport,
                            icon: const Icon(Icons.file_download, size: 18),
                            label: Text(l10n.importDataButton),
                          ),
                        ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _doImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.importData),
        content: Text(AppLocalizations.of(context)!.importDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.importDataButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _importing = true);

    try {
      final count = await ref.read(importProvider.notifier).importFromAssets();
      await ref.read(refuelListProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.importDataSuccess(count))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorPrefix(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }
}