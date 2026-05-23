import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jornada_deus_pai/shared/core/app_routes.dart';
import 'package:jornada_deus_pai/shared/theme/app_theme.dart';

/// Entry Screen
/// Emotional introduction with two paths
class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Emotional Text about Spiritual Orphanhood
                const Text(
                  'Você já se sentiu sozinho?',
                  style: AppTheme.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing24),
                const Text(
                  'Como se algo essencial estivesse faltando...\n\n'
                  'Como se você estivesse navegando pela vida sem um porto seguro...\n\n'
                  'Talvez você não saiba, mas existe um Pai que sempre esteve esperando por você.',
                  style: AppTheme.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing64),

                // Primary Button: "Começar pela raiz"
                ElevatedButton(
                  onPressed: () {
                    context.go(AppRoutes.carta);
                  },
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Começar pela raiz'),
                ),
                const SizedBox(height: AppTheme.spacing16),

                // Secondary Button: "Ir direto falar com o Pai"
                TextButton(
                  onPressed: () {
                    context.go(AppRoutes.preparation);
                  },
                  style: AppTheme.secondaryButtonStyle,
                  child: const Text('Ir direto falar com o Pai'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
