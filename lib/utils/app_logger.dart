import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static const String _tag = 'AppLogger';
  static const int _maxEntries = 200;

  static final AppLogger instance = AppLogger._internal();
  AppLogger._internal();

  final List<_LogEntry> _ringBuffer = [];
  File? _logFile;
  int _fileLines = 0;
  static const int _maxFileLines = 1000;

  void logError(
    Object error,
    StackTrace? stack, {
    String? tag,
    Map<String, Object?>? context,
  }) {
    final entry = _LogEntry(
      timestamp: DateTime.now(),
      level: _LogLevel.error,
      tag: tag ?? 'app',
      message: error.toString(),
      stackTrace: stack,
      context: context,
    );
    _append(entry);
    _printEntry(entry);
  }

  void logWarning(
    String message, {
    String? tag,
    Map<String, Object?>? context,
  }) {
    final entry = _LogEntry(
      timestamp: DateTime.now(),
      level: _LogLevel.warning,
      tag: tag ?? 'app',
      message: message,
      context: context,
    );
    _append(entry);
    _printEntry(entry);
  }

  void logInfo(
    String message, {
    String? tag,
    Map<String, Object?>? context,
  }) {
    if (!kDebugMode) return;
    final entry = _LogEntry(
      timestamp: DateTime.now(),
      level: _LogLevel.info,
      tag: tag ?? 'app',
      message: message,
      context: context,
    );
    _append(entry);
    _printEntry(entry);
  }

  List<_LogEntry> get entries => List.unmodifiable(_ringBuffer);

  Future<void> _initFile() async {
    if (_logFile != null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(path.join(dir.path, 'app_debug.log'));
      if (await file.exists()) {
        final lines = await file.readAsLines();
        _fileLines = lines.length;
      }
      _logFile = file;
    } catch (_) {}
  }

  void _append(_LogEntry entry) {
    _ringBuffer.add(entry);
    if (_ringBuffer.length > _maxEntries) {
      _ringBuffer.removeAt(0);
    }
    _persist(entry);
  }

  Future<void> _persist(_LogEntry entry) async {
    if (!kDebugMode) return;
    try {
      await _initFile();
      if (_logFile == null) return;
      final line = _formatLine(entry);
      if (_fileLines >= _maxFileLines) {
        final content = await _logFile!.readAsString();
        final lines = content.split('\n');
        final trimmed = lines.skip((lines.length * 0.3).round()).join('\n');
        await _logFile!.writeAsString('$trimmed\n$line');
        _fileLines = trimmed.split('\n').length;
      } else {
        await _logFile!.writeAsString('$line\n', mode: FileMode.append);
        _fileLines++;
      }
    } catch (_) {}
  }

  String _formatLine(_LogEntry e) {
    final ts = '${e.timestamp.hour.toString().padLeft(2, '0')}:'
        '${e.timestamp.minute.toString().padLeft(2, '0')}:'
        '${e.timestamp.second.toString().padLeft(2, '0')}';
    final ctx = e.context?.entries
            .map((kv) => '${kv.key}=${kv.value}')
            .join(', ') ??
        '';
    return '[$ts][${e.level.name.toUpperCase()}][${e.tag}] ${e.message} $ctx';
  }

  void _printEntry(_LogEntry entry) {
    final ts = '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
        '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
        '${entry.timestamp.second.toString().padLeft(2, '0')}';
    final prefix = '[$ts][${entry.tag}]';

    if (entry.level == _LogLevel.error) {
      debugPrint('$prefix ERROR: ${entry.message}');
      if (entry.stackTrace != null) {
        debugPrintStack(
          label: '$prefix StackTrace',
          stackTrace: entry.stackTrace,
        );
      }
      if (entry.context != null && entry.context!.isNotEmpty) {
        debugPrint('$prefix Context: $entry.context');
      }
    } else if (entry.level == _LogLevel.warning) {
      debugPrint('$prefix WARNING: ${entry.message}');
    } else {
      debugPrint('$prefix INFO: ${entry.message}');
    }
  }

  void logProviderTransition(
    String providerName,
    Object? previous,
    Object? next,
  ) {
    if (!kDebugMode) return;
    String msg;
    if (previous is AsyncValue && next is AsyncValue) {
      if (previous.hasError && !next.hasError) {
        msg = '$providerName recovered from error';
      } else if (!previous.hasError && next.hasError) {
        msg = '$providerName transitioned to error: ${next.error}';
      } else if (previous.isLoading && !next.isLoading) {
        msg = '$providerName finished loading (${next.valueOrNull?.toString().substring(0, 50)})';
      } else {
        msg = '$providerName updated';
      }
    } else {
      msg = '$providerName: $previous -> $next';
    }
    logInfo(msg, tag: 'riverpod');
  }
}

enum _LogLevel { info, warning, error }

class _LogEntry {
  final DateTime timestamp;
  final _LogLevel level;
  final String tag;
  final String message;
  final StackTrace? stackTrace;
  final Map<String, Object?>? context;

  const _LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.stackTrace,
    this.context,
  });
}

void logError(
  Object error,
  StackTrace? stack, {
  String? tag,
  Map<String, Object?>? context,
}) {
  AppLogger.instance.logError(error, stack, tag: tag, context: context);
}

void logWarning(
  String message, {
  String? tag,
  Map<String, Object?>? context,
}) {
  AppLogger.instance.logWarning(message, tag: tag, context: context);
}

void logInfo(
  String message, {
  String? tag,
  Map<String, Object?>? context,
}) {
  AppLogger.instance.logInfo(message, tag: tag, context: context);
}