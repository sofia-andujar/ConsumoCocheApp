import 'package:flutter/material.dart';
import 'screens/add_refuel_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';

class GasApp extends StatelessWidget {
  const GasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CONSUMO COCHE MAZDA 2 SOFIA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 138, 78, 167)),
        useMaterial3: true,
      ),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        HistoryScreen.routeName: (context) => const HistoryScreen(),
        AddRefuelScreen.routeName: (context) => const AddRefuelScreen(),
      },
    );
  }
}
