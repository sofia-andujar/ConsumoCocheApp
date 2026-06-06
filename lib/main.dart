import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/db_asset_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Optional: copy a bundled database from assets on first run.
  // await copyDbFromAssets();
  runApp(const ProviderScope(child: GasApp()));
}
