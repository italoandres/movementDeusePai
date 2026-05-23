import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jornada_deus_pai/shared/theme/app_theme.dart';

/// Preparation Screen
/// Identity reinforcement before chat
class PreparationScreen extends ConsumerWidget {
  const PreparationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Identity Affirmations
                const Text(
                  'Você é filho(a) amado(a)',
                  style: AppTheme.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing32),
                const Text(
                  'Você não está sozinho.\n\n'
                  'Você é aceito.\n\n'
                  'Você é amado incondicionalmente.\n\n'
                  'O Pai está esperando para ouvir você.',
                  style: AppTheme.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing64),

                // Breathing Exercise Hint
                const Text(
                  'Respire fundo...\n\n'
                  'Inspire... Expire...\n\n'
                  'Quando estiver pronto, clique abaixo.',
                  style: AppTheme.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing48),

                // Ready Button
                ElevatedButton(
                  onPressed: () {
                    context.go('/book-home');
                  },
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
