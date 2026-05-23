import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/supabase_service.dart';

/// Internal journey page for "Não Ore, Fale com o Pai"
/// Accessed INSIDE the ecosystem (after Carta, from Home)
/// NOT a sales page. A continuation of the journey.
///
/// "Ninguém está tentando me convencer.
///  Apenas me mostraram que existe um próximo espaço
///  quando eu estiver pronto."
class BookJourneyScreen extends ConsumerStatefulWidget {
  const BookJourneyScreen({super.key});

  @override
  ConsumerState<BookJourneyScreen> createState() => _BookJourneyScreenState();
}

class _BookJourneyScreenState extends ConsumerState<BookJourneyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeContent;
  bool _hasAccess = false;

  // Design tokens
  static const _bgColor = Color(0xFF0D0D0D);
  static const _goldPrimary = Color(0xFFC6A15B);
  static const _goldSoft = Color(0xFFB8945A);
  static const _textPrimary = Color(0xFFF5F1E8);
  static const _textSecondary = Color(0xB3F5F1E8);
  static const _textContemplative = Color(0x6BF5F1E8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeContent = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _checkAccess();
  }

  void _checkAccess() async {
    final user = SupabaseService.instance.currentUser;
    if (user == null) {
      setState(() => _hasAccess = false);
      return;
    }

    // Check from DATABASE (profiles table)
    try {
      final profile = await SupabaseService.instance.client
          .from('profiles')
          .select('access_type, has_book_access')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && (profile['has_book_access'] == true || profile['access_type'] == 'book' || profile['access_type'] == 'gifted' || profile['access_type'] == 'admin')) {
        // User has access - redirect to book home
        if (mounted) context.go('/book-home');
        return;
      }
    } catch (e) {
      // Continue showing the page
    }

    setState(() => _hasAccess = false);
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
            radius: 2.0,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.12),
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
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back to home
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: _textPrimary.withOpacity(0.3),
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // HERO
                      _buildHero(),

                      const SizedBox(height: 80),
                      _buildDivider(),
                      const SizedBox(height: 80),

                      // "VOCÊ JÁ COMEÇOU"
                      _buildAlreadyStarted(),

                      const SizedBox(height: 80),
                      _buildDivider(),
                      const SizedBox(height: 80),

                      // IDENTIFICATION
                      _buildIdentification(),

                      const SizedBox(height: 80),
                      _buildDivider(),
                      const SizedBox(height: 80),

                      // WHAT IT AWAKENS
                      _buildAwakening(),

                      const SizedBox(height: 80),
                      _buildDivider(),
                      const SizedBox(height: 80),

                      // TESTIMONIALS (silent)
                      _buildTestimonials(),

                      const SizedBox(height: 80),
                      _buildDivider(),
                      const SizedBox(height: 80),

                      // NOT CREATED TO BE CONSUMED FAST
                      _buildNotFast(),

                      const SizedBox(height: 80),
                      _buildDivider(),
                      const SizedBox(height: 80),

                      // CTA FINAL
                      _buildFinalCTA(context),

                      const SizedBox(height: 100),

                      // FREE ACCESS
                      _buildFreeAccess(context),

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

  Widget _buildDivider() {
    return Container(
      width: 30,
      height: 1,
      color: _goldPrimary.withOpacity(0.15),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Text(
          'algumas jornadas começam em silêncio',
          style: TextStyle(
            color: _goldSoft.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Text(
          'Não Ore. Fale com o Pai.',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'uma continuação da caminhada\nde volta ao relacionamento',
          style: TextStyle(
            color: _textContemplative,
            fontSize: 15,
            fontWeight: FontWeight.w300,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        const Text(
          'Talvez você já tenha percebido que o problema\nnunca foi falta de esforço.\n\nTalvez tenha sido viver tentando se aproximar de Deus\nsem nunca ter aprendido acesso.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w300,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAlreadyStarted() {
    return const Column(
      children: [
        Text(
          'Você já começou.',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 28),
        Text(
          'A Carta não foi o final.\n\nEla apenas abriu a porta para uma conversa\nque talvez você nunca tenha vivido antes.\n\nEssa continuação existe para quem deseja\nreconstruir sua relação com o Pai\nsem medo, performance ou religiosidade.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w300,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIdentification() {
    final items = [
      'você ora mas sente distância',
      'você tenta agradar Deus o tempo inteiro',
      'você sente culpa espiritual constante',
      'você acha que nunca é suficiente',
      'você conhece versículos mas não conhece descanso',
      'você fala com Deus como servo… não como filho',
    ];

    return Column(
      children: [
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                item,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            )),
        const SizedBox(height: 24),
        const Text(
          'Talvez você nunca tenha aprendido acesso.\nApenas obrigação.',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAwakening() {
    final items = [
      'compreender Deus como Pai',
      'sair da culpa espiritual constante',
      'aprender relacionamento em vez de performance',
      'reencontrar descanso espiritual',
      'entender identidade de filho',
      'perceber a voz do Pai no cotidiano',
      'viver espiritualidade sem peso religioso',
    ];

    return Column(
      children: [
        Text(
          'O que essa experiência desperta:',
          style: TextStyle(
            color: _goldSoft.withOpacity(0.7),
            fontSize: 17,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                item,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            )),
      ],
    );
  }

  Widget _buildTestimonials() {
    final testimonials = [
      'Pela primeira vez senti paz ao falar com Deus.',
      'Eu percebi que minha vida espiritual era baseada em medo.',
      'O livro me ensinou descanso espiritual.',
      'Parei de tentar impressionar Deus.',
    ];

    return Column(
      children: testimonials.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              '"$t"',
              style: TextStyle(
                color: _textPrimary.withOpacity(0.4),
                fontSize: 14,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          )).toList(),
    );
  }

  Widget _buildNotFast() {
    return const Column(
      children: [
        Text(
          'isso não foi criado para ser\nconsumido rápido.',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 28),
        Text(
          'Essa experiência não existe para gerar\nmais informação espiritual.\n\nEla existe para reconstruir algo que talvez\ntenha sido perdido há muito tempo:\n\no relacionamento.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w300,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFinalCTA(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Talvez esse seja o próximo passo.',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        const Text(
          'Acesso completo — R\$57',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'ou em até 12x no Mercado Pago',
          style: TextStyle(
            color: _textContemplative,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () => context.push('/checkout'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            decoration: BoxDecoration(
              color: _goldPrimary.withOpacity(0.06),
              border: Border.all(color: _goldPrimary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'continuar essa caminhada',
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

  Widget _buildFreeAccess(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 1,
          color: _goldPrimary.withOpacity(0.06),
        ),
        const SizedBox(height: 48),
        Text(
          'E se você realmente não puder pagar agora?',
          style: TextStyle(
            color: _textPrimary.withOpacity(0.45),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Não queremos que alguém saia daqui acreditando\nque o acesso ao Pai depende de dinheiro.\n\nSe esse for realmente o seu momento,\nvocê ainda pode continuar essa caminhada\ngratuitamente.',
          style: TextStyle(
            color: _textPrimary.withOpacity(0.35),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => context.push('/receber-carta'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: _textPrimary.withOpacity(0.12)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'receber a carta',
              style: TextStyle(
                color: _textPrimary.withOpacity(0.45),
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
