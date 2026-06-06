import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = ref.watch(accentColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de color'),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Color de acento',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppTheme.accentColors.map((color) {
                final selected = color == accentColor;
                return GestureDetector(
                  onTap: () {
                    ref.read(accentColorProvider.notifier).state = color;
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.transparent, width: 3),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check,
                            color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Elige el color de acento que más te guste. El tema se actualizará en toda la app.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
