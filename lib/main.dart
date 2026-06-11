import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'utils/app_logger.dart';

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
          'depth': details.depth,
          'summary': details.summary,
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

    AppLogger.instance.logInfo('App starting', tag: 'main');

    runApp(const ProviderScope(child: GasApp()));
  }, (Object error, StackTrace stack) {
    AppLogger.instance.logError(error, stack, tag: 'unhandled');
  });
}