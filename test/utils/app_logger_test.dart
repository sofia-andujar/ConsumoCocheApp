import 'package:flutter_test/flutter_test.dart';
import 'package:tankup/utils/app_logger.dart';

void main() {
  group('AppLogger', () {
    test('logError adds entry to ring buffer', () {
      final logger = AppLogger.instance;
      logger.logError('Test error', StackTrace.current, tag: 'test');
      expect(logger.entries.isNotEmpty, true);
    });

    test('logWarning adds entry to ring buffer', () {
      final logger = AppLogger.instance;
      logger.logWarning('Test warning', tag: 'test');
      expect(logger.entries.isNotEmpty, true);
    });

    test('logInfo adds entry in debug mode', () {
      final logger = AppLogger.instance;
      logger.logInfo('Test info', tag: 'test');
      expect(logger.entries.isNotEmpty, true);
    });

    test('logError captures stack trace', () {
      final logger = AppLogger.instance;
      logger.logError('Error with stack', StackTrace.current, tag: 'test');
      final entry = logger.entries.last;
      expect(entry.stackTrace, isNotNull);
    });

    test('logError captures context', () {
      final logger = AppLogger.instance;
      logger.logError(
        'Error with context',
        null,
        tag: 'test',
        context: {'key': 'value', 'count': 42},
      );
      final entry = logger.entries.last;
      expect(entry.context, isNotNull);
      expect(entry.context!['key'], 'value');
      expect(entry.context!['count'], 42);
    });
  });
}