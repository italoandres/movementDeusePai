import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/design/ecosystem_theme.dart';
import '../../../../shared/widgets/contemplative_rotating_phrase.dart';
import '../../../../shared/providers/access_providers.dart';

/// Journey Home - "Jornada Deus é Pai"
/// The main spiritual environment. Not a dashboard. A place.
///
/// States:
/// 1. New user → "Receber a Carta"
/// 2. Free user (read carta) → "Continuar caminhada"
/// 3. Paid user (has book) → Progress + continue reading
class JourneyHomeScreen extends ConsumerStatefulWidget {
  const JourneyHomeScreen({super.key});

  @override
  ConsumerState<JourneyHomeScreen> createState() => _JourneyHomeScreenState();
}

class _JourneyHomeScreenState extends ConsumerState<JourneyHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeContent;

  // Design tokens (from EcosystemTheme)
  static const _bgColor = EcosystemTheme.background;
  static const _goldPrimary = EcosystemTheme.gold;
  static const _goldSoft = EcosystemTheme.goldSoft;
  static const _textPrimary = EcosystemTheme.textPrimary;
  static const _textSecondary = EcosystemTheme.textSecondary;
  static const _textContemplative = EcosystemTheme.textContemplative;

  // User state
  _UserState _userState = _UserState.newUser;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeContent = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _determineUserState();
  }

  void _determineUserState() async {
    final user = SupabaseService.instance.currentUser;
    if (user == null) {
      setState(() => _userState = _UserState.newUser);
      return;
    }

    // Check from DATABASE (profiles table), not metadata
    try {
      final profile = await SupabaseService.instance.client
          .from('profiles')
          .select('access_type, has_book_access')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && (profile['has_book_access'] == true || profile['access_type'] == 'book' || profile['access_type'] == 'gifted' || profile['access_type'] == 'admin')) {
        setState(() => _userState = _UserState.paidUser);
      } else if (profile != null) {
        setState(() => _userState = _UserState.freeUser);
      } else {
        setState(() => _userState = _UserState.newUser);
      }
    } catch (e) {
      // Fallback to metadata if DB query fails
      final metadata = user.userMetadata;
      final accessType = metadata?['access_type'] as String?;
      if (accessType == 'paid') {
        setState(() => _userState = _UserState.paidUser);
      } else if (accessType == 'free') {
        setState(() => _userState = _UserState.freeUser);
      } else {
        setState(() => _userState = _UserState.newUser);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.8,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.15),
              _bgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeContent,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logout button (top right, subtle)
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            await SupabaseService.instance.client.auth.signOut();
                            if (context.mounted) {
                              context.go('/');
                            }
                          },
                          child: Icon(
                            Icons.logout_rounded,
                            color: EcosystemTheme.textPrimary.withOpacity(0.2),
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Jornada Deus é Pai',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'uma caminhada de volta ao relacionamento',
                        style: TextStyle(
                          color: _textContemplative,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 60),

                      // Contemplative rotating phrase
                      const ContemplativeRotatingPhrase(),

                      const SizedBox(height: 60),

                      // Divider
                      Container(
                        width: 30,
                        height: 1,
                        color: _goldPrimary.withOpacity(0.15),
                      ),

                      const SizedBox(height: 60),

                      // Content based on state
                      _buildStateContent(context),

                      const SizedBox(height: 80),

                      // Journey environments
                      _buildEnvironments(context),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context) {
    switch (_userState) {
      case _UserState.newUser:
        return _buildNewUserState(context);
      case _UserState.freeUser:
        return _buildFreeUserState(context);
      case _UserState.paidUser:
        return _buildPaidUserState(context);
    }
  }

  /// STATE 1: New user - never accessed anything
  Widget _buildNewUserState(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Talvez você ainda esteja tentando\nse aproximar de Deus…\n\nsem perceber que o Pai\njá estava perto.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 17,
            fontWeight: FontWeight.w300,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: () => context.push('/carta'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            decoration: BoxDecoration(
              color: _goldPrimary.withOpacity(0.06),
              border: Border.all(color: _goldPrimary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'receber a carta',
              style: TextStyle(
                color: _goldPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// STATE 2: Free user - read the letter
  Widget _buildFreeUserState(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Algumas conversas\ncomeçam em silêncio.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: () => context.push('/carta'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            decoration: BoxDecoration(
              color: _goldPrimary.withOpacity(0.06),
              border: Border.all(color: _goldPrimary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'continuar caminhada',
              style: TextStyle(
                color: _goldPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// STATE 3: Paid user - has the book
  Widget _buildPaidUserState(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Sua caminhada continua.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: () => context.push('/book-home'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            decoration: BoxDecoration(
              color: _goldPrimary.withOpacity(0.06),
              border: Border.all(color: _goldPrimary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'continuar leitura',
              style: TextStyle(
                color: _goldPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Journey environments - organized as "places", not catalog
  Widget _buildEnvironments(BuildContext context) {
    return Column(
      children: [
        // Carta de um Órfão
        _buildEnvironmentItem(
          context,
          title: 'Carta de um Órfão',
          description: 'para quem ainda sente distância',
          onTap: () => context.push('/carta'),
          isAccessible: true,
        ),

        const SizedBox(height: 24),

        // Não Ore, Fale com o Pai
        _buildEnvironmentItem(
          context,
          title: 'Não Ore, Fale com o Pai',
          description: 'uma reconstrução de relacionamento',
          onTap: _userState == _UserState.paidUser
              ? () => context.push('/book-home')
              : () => context.push('/livro'),
          isAccessible: true,
        ),

        const SizedBox(height: 24),

        // No Secreto (future)
        _buildEnvironmentItem(
          context,
          title: 'No Secreto',
          description: 'quando a conversa deixa de parecer esforço',
          onTap: null,
          isAccessible: false,
          isFuture: true,
        ),
      ],
    );
  }

  Widget _buildEnvironmentItem(
    BuildContext context, {
    required String title,
    required String description,
    VoidCallback? onTap,
    required bool isAccessible,
    bool isFuture = false,
  }) {
    return GestureDetector(
      onTap: isAccessible ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        decoration: BoxDecoration(
          border: Border.all(
            color: isAccessible
                ? _goldPrimary.withOpacity(0.12)
                : _textPrimary.withOpacity(0.04),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isAccessible ? _textPrimary : _textPrimary.withOpacity(0.35),
                fontSize: 17,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                color: isAccessible
                    ? _textContemplative
                    : _textPrimary.withOpacity(0.2),
                fontSize: 14,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (!isAccessible && !isFuture) ...[
              const SizedBox(height: 12),
              Text(
                'Algumas partes da caminhada foram preparadas\npara quem decidiu permanecer.',
                style: TextStyle(
                  color: _textPrimary.withOpacity(0.2),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _UserState {
  newUser,
  freeUser,
  paidUser,
}
