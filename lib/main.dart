import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'utils/app_logger.dart';

class _DebugProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    logError(
      error,
      stackTrace,
      tag: 'riverpod',
      context: {'provider': provider.name ?? provider.runtimeType.toString()},
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      AppLogger.instance.logProviderTransition(
        provider.name ?? provider.runtimeType.toString(),
        previousValue,
        newValue,
      );
    }
  }
}

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await initializeDateFormatting();

    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.instance.logError(
        details.exceptionAsString(),
        details.stack,
        tag: 'flutter',
        context: {
          'library': details.library,
          'silent': details.silent,
        },
      );
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      AppLogger.instance.logError(
        error,
        stack,
        tag: 'platform',
      );
      return false;
    };

    logInfo('App starting', tag: 'main');

    runApp(
      ProviderScope(
        observers: kDebugMode ? [_DebugProviderObserver()] : [],
        child: const TankUpApp(),
      ),
    );
  }, (Object error, StackTrace stack) {
    AppLogger.instance.logError(error, stack, tag: 'unhandled');
  });
}