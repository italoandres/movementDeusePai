import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jornada_deus_pai/shared/core/app_router.dart';
import 'package:jornada_deus_pai/shared/theme/app_theme.dart';

/// Main App Widget
class JornadaDeusePaiApp extends ConsumerWidget {
  const JornadaDeusePaiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Jornada Deus é Pai',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
