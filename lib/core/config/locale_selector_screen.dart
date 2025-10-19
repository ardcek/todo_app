import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/config/locale_controller.dart';
import 'package:todo_app/l10n/l10n.dart';

class LocaleSelectorScreen extends ConsumerWidget {
  const LocaleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
        title: Text(L10n.of(context).language),
      ),
      body: ListView(
        children: L10n.all.map((locale) {
          final isSelected = locale.languageCode == currentLocale;
          return ListTile(
            title: Text(L10n.getLanguageName(locale.languageCode)),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () {
              ref.read(localeControllerProvider.notifier).toggleLocale(locale.languageCode);
              context.go('/');
            },
          );
        }).toList(),
      ),
    );
  }
}