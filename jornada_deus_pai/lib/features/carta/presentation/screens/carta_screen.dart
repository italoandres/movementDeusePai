import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Carta de um Órfão - Immersive contemplative reading
/// Full content: raw, emotional, viral
/// Future: video format (vertical, like reels but not playing)
/// Current: immersive tap-to-advance (same as book chapters)
class CartaScreen extends ConsumerStatefulWidget {
  const CartaScreen({super.key});

  @override
  ConsumerState<CartaScreen> createState() => _CartaScreenState();
}

class _CartaScreenState extends ConsumerState<CartaScreen> {
  int _currentIndex = 0;
  bool _showCTA = false;

  // Design tokens
  static const _bgColor = Color(0xFF0D0D0D);
  static const _goldPrimary = Color(0xFFC6A15B);
  static const _textPrimary = Color(0xFFF5F1E8);
  static const _textContemplative = Color(0x6BF5F1E8);

  // Full content of "A Carta de um Órfão"
  final List<_CartaItem> _content = const [
    _CartaItem(text: 'A CARTA DE UM ÓRFÃO', isTitle: true),
    _CartaItem(text: 'Eu não sei exatamente quando isso começou…'),
    _CartaItem(text: 'Mas em algum momento da minha vida\neu senti que tava sozinho.'),
    _CartaItem(text: 'Mesmo quando tinha gente perto.'),
    _CartaItem(text: 'Mesmo quando tudo parecia "normal".'),
    _CartaItem(text: 'Tinha um vazio.\nUm silêncio.'),
    _CartaItem(text: 'Uma sensação de que…\nfaltava alguma coisa\nque eu não sabia explicar.'),
    _CartaItem(text: 'Eu aprendi a viver assim.'),
    _CartaItem(text: 'Aprendi a sorrir…\nmesmo não estando bem.'),
    _CartaItem(text: 'Aprendi a parecer forte…\nmesmo me sentindo perdido.'),
    _CartaItem(text: 'Aprendi a correr atrás de tudo…\nmenos daquilo que realmente importava.'),
    _CartaItem(text: 'Porque no fundo…\neu só queria uma coisa\nque eu nunca soube pedir:'),
    _CartaItem(text: 'alguém que me visse de verdade.', isImpact: true),
    _CartaItem(text: 'alguém que dissesse:\n"eu tô aqui…\npode parar de carregar tudo sozinho."', isImpact: true),
    _CartaItem(text: 'E talvez o mais difícil de admitir seja isso:'),
    _CartaItem(text: 'eu tentei preencher esse vazio\nde todas as formas.'),
    _CartaItem(text: 'Com conquistas.\nCom dinheiro.\nCom pessoas.\nCom distrações.'),
    _CartaItem(text: 'Mas nada ficava.\nNada resolvia.'),
    _CartaItem(text: 'Porque o problema nunca foi\no que faltava fora…'),
    _CartaItem(text: 'era o que faltava dentro.', isImpact: true),
    _CartaItem(text: 'E o mais louco?'),
    _CartaItem(text: 'Eu sempre ouvi falar de Deus.\nSempre.'),
    _CartaItem(text: 'Mas pra mim… Ele era distante.'),
    _CartaItem(text: 'Era alguém que eu precisava impressionar.\nAlguém que eu precisava agradar.\nAlguém que eu precisava "merecer".'),
    _CartaItem(text: 'Então eu fazia o que me ensinaram:'),
    _CartaItem(text: 'Orava.\nRepetia palavras.\nTentava fazer tudo certo.'),
    _CartaItem(text: 'Mas no fundo…\neu continuava sozinho.'),
    _CartaItem(text: 'Até que um dia…\neu parei.'),
    _CartaItem(text: 'Parei de tentar fazer\ndo jeito que me ensinaram.'),
    _CartaItem(text: 'Parei de falar bonito.'),
    _CartaItem(text: 'Parei de fingir que tava tudo bem.'),
    _CartaItem(text: 'E fiz algo que mudou tudo:'),
    _CartaItem(text: 'Eu falei como um filho.', isImpact: true),
    _CartaItem(text: 'Sem filtro.\nSem roteiro.\nSem religião.'),
    _CartaItem(text: 'Só disse:'),
    _CartaItem(text: '"Pai… eu não aguento mais."', isImpact: true),
    _CartaItem(text: 'E naquele momento…\nnada mudou do lado de fora.'),
    _CartaItem(text: 'Mas tudo começou a mudar\npor dentro.', isImpact: true),
    _CartaItem(text: 'Porque pela primeira vez…'),
    _CartaItem(text: 'eu não estava tentando falar\ncom um Deus distante.'),
    _CartaItem(text: 'Eu estava começando a me relacionar\ncom um Pai.', isImpact: true),
    _CartaItem(text: 'E se você chegou até aqui…'),
    _CartaItem(text: 'talvez essa carta\nnão seja só minha.'),
    _CartaItem(text: 'Talvez seja sua também.', isImpact: true),
    _CartaItem(text: 'E se for…'),
    _CartaItem(text: 'então você não precisa\nde mais informação.'),
    _CartaItem(text: 'Você precisa viver isso.', isImpact: true),
  ];

  void _advance() {
    if (_showCTA) return;

    if (_currentIndex < _content.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _showCTA = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.2),
              _bgColor,
            ],
          ),
        ),
        child: GestureDetector(
          onTap: _advance,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: SafeArea(
              child: Center(
                child: _showCTA ? _buildCTA(context) : _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final item = _content[_currentIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top bar: back button + progress
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Icon(
                Icons.arrow_back_ios,
                color: _textPrimary.withOpacity(0.3),
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _content.length,
                backgroundColor: _textPrimary.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(_goldPrimary.withOpacity(0.3)),
                minHeight: 1,
              ),
            ),
          ],
        ),

        const Spacer(flex: 3),

        // Text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            item.text,
            key: ValueKey(_currentIndex),
            style: TextStyle(
              color: item.isTitle
                  ? _goldPrimary
                  : item.isImpact
                      ? _textPrimary
                      : _textPrimary.withOpacity(0.85),
              fontSize: item.isTitle ? 28 : item.isImpact ? 24 : 21,
              fontWeight: item.isTitle
                  ? FontWeight.w300
                  : item.isImpact
                      ? FontWeight.w400
                      : FontWeight.w300,
              height: 1.8,
              letterSpacing: item.isTitle ? 1.5 : 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const Spacer(flex: 2),

        // Hint
        const Text(
          'toque para continuar',
          style: TextStyle(
            color: _textContemplative,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),

        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildCTA(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          Container(
            width: 30,
            height: 1,
            color: _goldPrimary.withOpacity(0.2),
          ),

          const SizedBox(height: 48),

          const Text(
            'Se essa carta parece que\nfoi escrita por você…',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w300,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          Text(
            'Você não precisa de mais conteúdo.\nVocê não precisa de mais motivação.\nVocê não precisa de mais uma oração decorada.',
            style: TextStyle(
              color: _textPrimary.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w300,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          const Text(
            'Você precisa de um Pai.',
            style: TextStyle(
              color: _goldPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w300,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          Text(
            'No livro "Não ore, fale com o Pai"\neu te mostro como esse relacionamento começou…\ne como ele reconstruiu minha identidade do zero.',
            style: TextStyle(
              color: _textPrimary.withOpacity(0.55),
              fontSize: 15,
              fontWeight: FontWeight.w300,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          Text(
            'Se você cansou de se sentir sozinho…',
            style: TextStyle(
              color: _textPrimary.withOpacity(0.7),
              fontSize: 17,
              fontWeight: FontWeight.w300,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          const Text(
            'começa hoje.',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // CTA Button - go to sales/checkout
          GestureDetector(
            onTap: () => context.push('/journey/sales'),
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
                'conhecer o livro',
                style: TextStyle(
                  color: _goldPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Secondary: read again
          GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = 0;
                _showCTA = false;
              });
            },
            child: Text(
              'ler novamente',
              style: TextStyle(
                color: _textPrimary.withOpacity(0.3),
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

/// Simple model for carta content items
class _CartaItem {
  final String text;
  final bool isTitle;
  final bool isImpact;

  const _CartaItem({
    required this.text,
    this.isTitle = false,
    this.isImpact = false,
  });
}
