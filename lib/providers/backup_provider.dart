import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/export_service.dart';
import '../services/google_drive_service.dart';
import '../utils/app_logger.dart';
import 'auth_provider.dart';
import 'refuel_provider.dart';

enum BackupStatus { idle, backingUp, restoring, error }

class BackupState {
  final BackupStatus status;
  final String? message;
  final DateTime? lastBackup;

  const BackupState({
    this.status = BackupStatus.idle,
    this.message,
    this.lastBackup,
  });
}

final backupProvider = StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  return BackupNotifier(ref);
});

class BackupNotifier extends StateNotifier<BackupState> {
  final Ref _ref;

  BackupNotifier(this._ref) : super(const BackupState());

  Future<bool> backup() async {
    state = const BackupState(status: BackupStatus.backingUp);

    try {
      final scopeGranted = await _ref.read(authProvider.notifier).ensureDriveScope();
      if (!scopeGranted) {
        state = const BackupState(status: BackupStatus.error, message: 'driveScopeRequired');
        return false;
      }

      final authHeaders = await _ref.read(authProvider.notifier).getAuthHeaders();
      if (authHeaders == null) {
        state = const BackupState(status: BackupStatus.error, message: 'authRequired');
        return false;
      }

      final refuels = _ref.read(refuelListProvider).valueOrNull ?? [];
      if (refuels.isEmpty) {
        state = const BackupState(status: BackupStatus.error, message: 'noData');
        return false;
      }

      final csvPath = await ExportService.exportToCsv(refuels);
      final csvFile = File(csvPath);

      await GoogleDriveService.uploadBackup(authHeaders, csvFile);

      await csvFile.delete();

      state = BackupState(
        status: BackupStatus.idle,
        lastBackup: DateTime.now(),
      );
      return true;
    } catch (e, st) {
      logError(e, st, tag: 'backup_provider');
      state = BackupState(status: BackupStatus.error, message: e.toString());
      return false;
    }
  }

  Future<bool> restore({required bool clearExisting}) async {
    state = const BackupState(status: BackupStatus.restoring);

    try {
      final scopeGranted = await _ref.read(authProvider.notifier).ensureDriveScope();
      if (!scopeGranted) {
        state = const BackupState(status: BackupStatus.error, message: 'driveScopeRequired');
        return false;
      }

      final authHeaders = await _ref.read(authProvider.notifier).getAuthHeaders();
      if (authHeaders == null) {
        state = const BackupState(status: BackupStatus.error, message: 'authRequired');
        return false;
      }

      final csvContent = await GoogleDriveService.downloadBackupContent(authHeaders);
      final db = _ref.read(refuelDatabaseProvider);
      await db.importFromCsv(csvContent, clearExisting: clearExisting);

      await _ref.read(refuelListProvider.notifier).refresh();

      state = BackupState(status: BackupStatus.idle, lastBackup: DateTime.now());
      return true;
    } catch (e, st) {
      logError(e, st, tag: 'backup_provider');
      state = BackupState(status: BackupStatus.error, message: e.toString());
      return false;
    }
  }
}