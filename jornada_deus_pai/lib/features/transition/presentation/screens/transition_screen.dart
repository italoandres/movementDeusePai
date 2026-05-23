import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jornada_deus_pai/shared/core/app_routes.dart';
import 'package:jornada_deus_pai/shared/theme/app_theme.dart';

/// Transition Screen
/// Minimalist emotional conversion point after Carta de um Órfão
class TransitionScreen extends ConsumerStatefulWidget {
  const TransitionScreen({super.key});

  @override
  ConsumerState<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends ConsumerState<TransitionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _firstPartAnimation;
  late Animation<double> _secondPartAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // First part: 0-2s
    _firstPartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // Second part: 4-6s (with pause)
    _secondPartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeIn),
      ),
    );

    // Button: 7-8s
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.875, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // First Part
                  Opacity(
                    opacity: _firstPartAnimation.value,
                    child: const Text(
                      'Talvez você nunca tenha sido apresentado\nao seu verdadeiro Pai.',
                      style: AppTheme.h2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing64),

                  // Second Part (with pause)
                  Opacity(
                    opacity: _secondPartAnimation.value,
                    child: const Text(
                      'Mas isso pode começar agora.',
                      style: AppTheme.h2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing64),

                  // Button
                  Opacity(
                    opacity: _buttonAnimation.value,
                    child: ElevatedButton(
                      onPressed: _buttonAnimation.value > 0.5
                          ? () {
                              context.go(AppRoutes.preparation);
                            }
                          : null,
                      style: AppTheme.primaryButtonStyle,
                      child: const Text('Falar com o Pai pela primeira vez'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
