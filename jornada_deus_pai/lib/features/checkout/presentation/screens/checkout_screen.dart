import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/design/ecosystem_theme.dart';
import '../../../../shared/widgets/contemplative_rotating_phrase.dart';

/// Checkout screen — portal de entrada na jornada
/// "Você não está comprando algo. Você está começando algo."
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

  static const _apiUrl = 'https://nosecreto.vercel.app';

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

    // Auto-preencher email se user já está autenticado (fluxo interno)
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.email != null) {
      _emailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
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
      final response = await http.post(
        Uri.parse('$_apiUrl/api/checkout/create-preference'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Use init_point for production, fallback to sandbox for test
        final checkoutUrl = (data['init_point'] ?? data['sandbox_init_point']) as String?;

        if (checkoutUrl != null) {
          final uri = Uri.parse(checkoutUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            setState(() => _error = 'não foi possível abrir o acesso');
          }
        } else {
          setState(() => _error = 'erro ao preparar acesso');
        }
      } else {
        setState(() => _error = 'erro ao processar. tente novamente.');
      }
    } catch (e) {
      setState(() => _error = 'erro de conexão. tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcosystemTheme.background,
      body: Container(
        decoration: EcosystemTheme.backgroundGradient,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeContent,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: EcosystemTheme.textPrimary.withOpacity(0.3),
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Title
                      const Text(
                        'Talvez essa seja a primeira vez\nque você não está apenas tentando.',
                        style: TextStyle(
                          color: EcosystemTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          height: 1.7,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Subtitle
                      Text(
                        'O acesso ao "Não Ore. Fale com o Pai."\nfaz parte da jornada Deus é Pai —\num espaço criado para reconstruir\nrelacionamento, identidade e presença\ndiante do Pai.',
                        style: TextStyle(
                          color: EcosystemTheme.textPrimary.withOpacity(0.55),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Rotating phrases
                      const ContemplativeRotatingPhrase(
                        fontSize: 15,
                      ),

                      const SizedBox(height: 60),

                      // Access block
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: EcosystemTheme.gold.withOpacity(0.12),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Seu acesso será conectado ao email abaixo.',
                              style: TextStyle(
                                color: EcosystemTheme.textPrimary.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 20),

                            // Email field
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: EcosystemTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                              decoration: InputDecoration(
                                hintText: 'seu melhor email',
                                hintStyle: const TextStyle(
                                  color: EcosystemTheme.textContemplative,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: EcosystemTheme.gold.withOpacity(0.12),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: EcosystemTheme.gold.withOpacity(0.3),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 4,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Esse será o email usado para acessar sua caminhada\ndentro do ecossistema Deus é Pai.',
                              style: TextStyle(
                                color: EcosystemTheme.textPrimary.withOpacity(0.3),
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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

                      const SizedBox(height: 36),

                      // Value block
                      const Text(
                        'Acesso completo — R\$57',
                        style: TextStyle(
                          color: EcosystemTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ou em até 12x no Mercado Pago',
                        style: TextStyle(
                          color: EcosystemTheme.textContemplative,
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // CTA
                      GestureDetector(
                        onTap: _isLoading ? null : _handleContinue,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: EcosystemTheme.gold.withOpacity(0.06),
                            border: Border.all(
                              color: EcosystemTheme.gold.withOpacity(0.3),
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
                                      color: EcosystemTheme.gold.withOpacity(0.5),
                                    ),
                                  )
                                : const Text(
                                    'continuar para o acesso',
                                    style: TextStyle(
                                      color: EcosystemTheme.gold,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Footer
                      Text(
                        'Pagamento seguro via Mercado Pago.\nApós a confirmação, seu acesso será liberado\nautomaticamente no ecossistema.',
                        style: TextStyle(
                          color: EcosystemTheme.textPrimary.withOpacity(0.25),
                          fontSize: 11,
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
