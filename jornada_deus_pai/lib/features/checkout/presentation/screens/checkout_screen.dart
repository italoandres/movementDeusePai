import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Checkout screen - collects email and redirects to Mercado Pago
/// Contemplative design aligned with the journey experience
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeContent;

  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  // Design tokens
  static const _bgColor = Color(0xFF0D0D0D);
  static const _goldPrimary = Color(0xFFC6A15B);
  static const _textPrimary = Color(0xFFF5F1E8);
  static const _textSecondary = Color(0xB3F5F1E8);
  static const _textContemplative = Color(0x6BF5F1E8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeContent = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'informe um email válido');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: When deployed, call the Next.js API to create preference
      // For now, show a message that this will redirect to Mercado Pago
      // 
      // In production:
      // 1. Call POST /api/checkout/create-preference with email
      // 2. Get init_point URL back
      // 3. Launch that URL in browser
      //
      // final response = await http.post(
      //   Uri.parse('https://your-domain.vercel.app/api/checkout/create-preference'),
      //   body: jsonEncode({'email': email}),
      //   headers: {'Content-Type': 'application/json'},
      // );
      // final data = jsonDecode(response.body);
      // await launchUrl(Uri.parse(data['init_point']));

      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        // Temporary: show confirmation that checkout will redirect
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Pagamento',
              style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w300),
            ),
            content: Text(
              'Quando o app estiver publicado, você será redirecionado para o Mercado Pago para concluir o pagamento com segurança.\n\nEmail: $email\nValor: R\$57,00',
              style: const TextStyle(color: _textSecondary, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('/obrigado');
                },
                child: const Text(
                  'simular pagamento aprovado',
                  style: TextStyle(color: _goldPrimary),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'erro ao processar. tente novamente.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.2),
              _bgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                child: FadeTransition(
                  opacity: _fadeContent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: _textPrimary.withOpacity(0.3),
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Headline
                      const Text(
                        'Esse acesso existe para quem deseja\nreconstruir sua relação com o Pai\nsem religião, medo ou performance.',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.2,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Divider
                      Container(
                        width: 30,
                        height: 1,
                        color: _goldPrimary.withOpacity(0.15),
                      ),

                      const SizedBox(height: 48),

                      // Price
                      const Text(
                        'Acesso completo — R\$57',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 20,
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

                      const SizedBox(height: 48),

                      // Email field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: InputDecoration(
                          hintText: 'seu melhor email',
                          hintStyle: const TextStyle(
                            color: _textContemplative,
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: _goldPrimary.withOpacity(0.12),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: _goldPrimary.withOpacity(0.3),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // CTA Button
                      GestureDetector(
                        onTap: _isLoading ? null : _handleCheckout,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _goldPrimary.withOpacity(0.08),
                            border: Border.all(
                              color: _goldPrimary.withOpacity(0.35),
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: _goldPrimary.withOpacity(0.5),
                                    ),
                                  )
                                : const Text(
                                    'pagar com mercado pago',
                                    style: TextStyle(
                                      color: _goldPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Security note
                      const Text(
                        'pagamento seguro via Mercado Pago\ntodos os meios de pagamento aceitos',
                        style: TextStyle(
                          color: _textContemplative,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 80),
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
}
