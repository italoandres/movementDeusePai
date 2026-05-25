import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Sales page - contemplative, golden warmth, not aggressive
class SalesPageScreen extends StatelessWidget {
  const SalesPageScreen({super.key});

  // Design tokens
  static const _bgColor = Color(0xFF0D0D0D);
  static const _goldPrimary = Color(0xFFC6A15B);
  static const _goldSoft = Color(0xFFB8914A);
  static const _textPrimary = Color(0xFFF5F1E8);
  static const _textSecondary = Color(0xB3F5F1E8); // 70%
  static const _textContemplative = Color(0x6BF5F1E8); // 42%

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
              const Color(0xFF1A121C).withOpacity(0.15),
              _bgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SEÇÃO 1 — HEADLINE
                    const SizedBox(height: 40),
                    const Text(
                      'Você não nasceu para viver tentando merecer o amor de Deus.',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'O livro "Não Ore. Fale com o Pai." é um convite para sair da religiosidade e reencontrar sua identidade de filho.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 80),
                    _buildDivider(),
                    const SizedBox(height: 80),

                    // SEÇÃO 2 — IDENTIFICAÇÃO
                    _buildIdentificationSection(),

                    const SizedBox(height: 80),
                    _buildDivider(),
                    const SizedBox(height: 80),

                    // SEÇÃO 3 — RELIGIOSIDADE
                    _buildReligiositySection(),

                    const SizedBox(height: 80),
                    _buildDivider(),
                    const SizedBox(height: 80),

                    // SEÇÃO 4 — O QUE O LIVRO DESPERTA
                    _buildAwakeningSection(),

                    const SizedBox(height: 80),
                    _buildDivider(),
                    const SizedBox(height: 80),

                    // SEÇÃO 5 — DENTRO DO LIVRO
                    _buildChaptersSection(),

                    const SizedBox(height: 80),
                    _buildDivider(),
                    const SizedBox(height: 80),

                    // SEÇÃO 7 — GRANDE VIRADA
                    _buildTurningPointSection(),

                    const SizedBox(height: 80),
                    _buildDivider(),
                    const SizedBox(height: 80),

                    // SEÇÃO 8 — DEPOIMENTOS
                    _buildTestimonialsSection(),

                    const SizedBox(height: 80),
                    _buildDivider(),
                    const SizedBox(height: 80),

                    // SEÇÃO 9 — GARANTIA
                    _buildGuaranteeSection(),

                    const SizedBox(height: 80),
                    _buildDivider(),
                    const SizedBox(height: 80),

                    // SEÇÃO 10 — CTA FINAL
                    _buildFinalCTA(context),

                    const SizedBox(height: 100),

                    // SEÇÃO FINAL — ACESSO GRATUITO HUMANIZADO
                    _buildFreeAccessSection(context),

                    const SizedBox(height: 80),
                  ],
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
      width: 40,
      height: 1,
      color: _goldPrimary.withOpacity(0.2),
    );
  }

  Widget _buildIdentificationSection() {
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
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                item,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            )),
        const SizedBox(height: 28),
        const Text(
          'Talvez você nunca tenha aprendido acesso.\nApenas obrigação.',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReligiositySection() {
    return const Column(
      children: [
        Text(
          'Muitas pessoas aprenderam sobre Deus…\nmas poucas aprenderam intimidade com o Pai.',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 36),
        Text(
          'Religiosidade ensina comportamento.\nMas filhos aprendem relacionamento.\n\nJesus nunca chamou os discípulos para viver apenas rituais.\nEle ensinou acesso. Presença. Intimidade.\nDependência. Filiação.',
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

  Widget _buildAwakeningSection() {
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
        const Text(
          'O que esse livro desperta em você:',
          style: TextStyle(
            color: _goldSoft,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
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
      ],
    );
  }

  Widget _buildChaptersSection() {
    final chapters = [
      'por que você sente Deus distante',
      'a mentira da performance espiritual',
      'o medo de nunca ser suficiente',
      'o acesso que Jesus veio revelar',
      'voltar a ser filho',
      'aprender presença',
      'o secreto diante do Pai',
    ];

    return Column(
      children: [
        const Text(
          'O que existe dentro do livro:',
          style: TextStyle(
            color: _goldSoft,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...chapters.map((chapter) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                chapter,
                style: const TextStyle(
                  color: _textContemplative,
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            )),
      ],
    );
  }

  Widget _buildTurningPointSection() {
    return const Column(
      children: [
        Text(
          'Talvez Deus nunca tenha pedido que você carregasse esse peso sozinho.',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 36),
        Text(
          'Você não precisa se tornar perfeito\npara se aproximar do Pai.\n\nFilhos se aproximam antes mesmo\nde conseguirem colocar tudo em ordem.',
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

  Widget _buildTestimonialsSection() {
    final testimonials = [
      'Pela primeira vez senti paz ao falar com Deus.',
      'Eu percebi que minha vida espiritual era baseada em medo.',
      'O livro me ensinou descanso espiritual.',
      'Parei de tentar impressionar Deus.',
    ];

    return Column(
      children: testimonials.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 22,
                horizontal: 24,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _goldPrimary.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$t"',
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )).toList(),
    );
  }

  Widget _buildGuaranteeSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(
          color: _goldPrimary.withOpacity(0.12),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Se esse livro não ajudar você a enxergar Deus de forma mais próxima e verdadeira, você pode pedir reembolso.\n\nSem justificativas. Sem peso. Sem culpa.',
        style: TextStyle(
          color: _textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w300,
          height: 1.7,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFinalCTA(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Talvez esteja na hora de parar apenas de orar…\n\ne começar a viver diante do Pai.',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.3,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 52),

        // Price section
        const Text(
          'Acesso completo — R\$57',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'ou em até 12x no Mercado Pago',
          style: TextStyle(
            color: _textContemplative,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Isso não foi criado para ser consumido rápido.\nFoi criado para ser vivido.',
          style: TextStyle(
            color: _textContemplative,
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // CTA Button
        GestureDetector(
          onTap: () => context.push('/checkout'),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: _goldPrimary.withOpacity(0.08),
              border: Border.all(
                color: _goldPrimary.withOpacity(0.35),
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'quero continuar essa caminhada',
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

  /// Seção humanizada de acesso gratuito - discreta, no final da página
  Widget _buildFreeAccessSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 1,
          color: _goldPrimary.withOpacity(0.08),
        ),
        const SizedBox(height: 60),
        Text(
          'Talvez você tenha chegado até aqui…\nmas realmente não consiga pagar por esse acesso agora.',
          style: TextStyle(
            color: _textPrimary.withOpacity(0.4),
            fontSize: 15,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Se for esse o seu caso, não saia sentindo que o Pai\ntambém ficou distante de você por causa disso.',
          style: TextStyle(
            color: _textPrimary.withOpacity(0.35),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Existe um caminho gratuito.',
          style: TextStyle(
            color: _textPrimary.withOpacity(0.4),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '"A Carta de um Órfão" foi deixada para quem precisa\ncomeçar essa caminhada mesmo em silêncio.\n\nSem explicações. Sem vergonha. Sem cobrança.',
          style: TextStyle(
            color: _textPrimary.withOpacity(0.35),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        GestureDetector(
          onTap: () => context.push('/receber-carta'),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: _textPrimary.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'receber a carta',
              style: TextStyle(
                color: _textPrimary.withOpacity(0.4),
                fontSize: 13,
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
