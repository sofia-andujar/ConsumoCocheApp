import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/export_service.dart';
import '../data/refuel_database.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/backup_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/refuel_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/snackbar_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _backingUp = false;
  bool _restoring = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(themeSettingsProvider);
    final currentLocale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);
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
                                  size: 22,
                                )
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
          _buildGoogleAccountCard(context, theme, l10n, authState),
          const SizedBox(height: 16),
          _buildExportCard(context, theme, l10n),
          const SizedBox(height: 16),
          _buildImportCard(context, theme, l10n),
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

  Widget _buildGoogleAccountCard(BuildContext context, ThemeData theme, AppLocalizations l10n, AsyncValue<GoogleSignInAccount?> authState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: authState.when(
          loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (e, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader(Icons.account_circle, l10n.googleAccount, theme),
              const SizedBox(height: 12),
              Text(l10n.errorPrefix(e.toString()), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => ref.read(authProvider.notifier).signIn(),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.retry),
              ),
            ],
          ),
          data: (account) {
            if (account == null) {
              return _buildSignedOutCard(context, theme, l10n);
            }
            return _buildSignedInCard(context, theme, l10n, account);
          },
        ),
      ),
    );
  }

  Widget _buildSignedOutCard(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardHeader(Icons.account_circle, l10n.googleAccount, theme),
        const SizedBox(height: 12),
        Text(l10n.signInRequired, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => ref.read(authProvider.notifier).signIn(),
            icon: const Icon(Icons.login, size: 18),
            label: Text(l10n.signInWithGoogle),
          ),
        ),
      ],
    );
  }

  Widget _buildSignedInCard(BuildContext context, ThemeData theme, AppLocalizations l10n, GoogleSignInAccount account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _cardHeader(Icons.account_circle, l10n.googleAccount, theme),
            const Spacer(),
            TextButton.icon(
              onPressed: () => ref.read(authProvider.notifier).signOut(),
              icon: const Icon(Icons.logout, size: 16),
              label: Text(l10n.signOut, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.signedInAs(account.email),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(180)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _backingUp ? null : _doBackup,
                icon: _backingUp
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload, size: 18),
                label: Text(l10n.backupButton),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _restoring ? null : _doRestore,
                icon: _restoring
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_download, size: 18),
                label: Text(l10n.restoreButton),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardHeader(IconData icon, String title, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium),
      ],
    );
  }

  Widget _buildExportCard(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upload, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.exportData, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.exportDataDescription, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _doExport,
                icon: const Icon(Icons.file_upload, size: 18),
                label: Text(l10n.exportDataCsv),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportCard(BuildContext context, ThemeData theme, AppLocalizations l10n) {
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
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _doImport,
                icon: const Icon(Icons.file_open, size: 18),
                label: Text(l10n.importDataCsv),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doImport() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      final bytes = await File(filePath).readAsBytes();
      String content;
      if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
        final codeUnits = <int>[];
        for (var i = 2; i + 1 < bytes.length; i += 2) {
          codeUnits.add(bytes[i] | (bytes[i + 1] << 8));
        }
        content = String.fromCharCodes(codeUnits);
      } else if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
        final codeUnits = <int>[];
        for (var i = 2; i + 1 < bytes.length; i += 2) {
          codeUnits.add((bytes[i] << 8) | bytes[i + 1]);
        }
        content = String.fromCharCodes(codeUnits);
      } else {
        try {
          content = utf8.decode(bytes);
        } on FormatException {
          content = latin1.decode(bytes);
        }
      }

      final count = await RefuelDatabase.instance.importFromCsv(content, clearExisting: false);

      ref.invalidate(refuelListProvider);

      if (mounted) {
        final msg = count > 0
            ? l10n.importDataSuccess(count)
            : '${l10n.importDataError}: ${l10n.noRefuelsRegistered}';
        if (count > 0) {
          SnackBarHelper.showSuccess(context, msg);
        } else {
          SnackBarHelper.showWarning(context, msg);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${l10n.importDataError}: $e');
      }
    }
  }

  Future<void> _doExport() async {
    final refuels = ref.read(refuelListProvider).valueOrNull ?? [];
    if (refuels.isEmpty) {
      if (mounted) {
        SnackBarHelper.showWarning(context, AppLocalizations.of(context)!.noRefuelsRegistered);
      }
      return;
    }

    try {
      final locale = Localizations.localeOf(context).toString();
      final now = DateTime.now();
      final ts = '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
      final fileName = 'tankup_$ts.csv';

      final csvContent = ExportService.generateCsvContent(refuels, locale: locale);

      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: AppLocalizations.of(context)!.exportDataCsv,
        fileName: fileName,
        bytes: utf8.encode(csvContent),
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );

      if (savePath == null) return;

      if (mounted) {
        SnackBarHelper.showSuccess(context, AppLocalizations.of(context)!.exportDataSuccess);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${AppLocalizations.of(context)!.exportDataError}: $e');
      }
    }
  }

  Future<void> _doBackup() async {
    setState(() => _backingUp = true);

    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await ref.read(backupProvider.notifier).backup();
      if (mounted) {
        if (success) {
          SnackBarHelper.showSuccess(context, l10n.backupSuccess);
        } else {
          final state = ref.read(backupProvider);
          final msg = state.message;
          if (msg == 'authRequired') {
            SnackBarHelper.showWarning(context, l10n.signInRequired);
          } else if (msg == 'driveScopeRequired') {
            SnackBarHelper.showWarning(context, l10n.driveScopeRequired);
          } else if (msg == 'noData') {
            SnackBarHelper.showWarning(context, l10n.noRefuelsRegistered);
          } else {
            SnackBarHelper.showError(context, l10n.backupError(msg ?? ''));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, l10n.backupError(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _backingUp = false);
      }
    }
  }

  Future<void> _doRestore() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreData),
        content: Text(l10n.restoreConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.restoreButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _restoring = true);

    try {
      final success = await ref.read(backupProvider.notifier).restore(clearExisting: true);
      if (mounted) {
        if (success) {
          SnackBarHelper.showSuccess(context, l10n.restoreSuccess);
        } else {
          final state = ref.read(backupProvider);
          final msg = state.message;
          if (msg == 'authRequired') {
            SnackBarHelper.showWarning(context, l10n.signInRequired);
          } else if (msg == 'driveScopeRequired') {
            SnackBarHelper.showWarning(context, l10n.driveScopeRequired);
          } else if (msg?.contains('No backup found') == true) {
            SnackBarHelper.showWarning(context, l10n.noBackupFound);
          } else {
            SnackBarHelper.showError(context, l10n.restoreError(msg ?? ''));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, l10n.restoreError(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _restoring = false);
      }
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}