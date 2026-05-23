import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/services/profile_service.dart';

/// Thank You / Obrigado screen — inline account creation after payment
///
/// Receives email from URL query parameter `external_reference`.
/// Displays inline form: email (readonly if pre-filled), nome, senha.
/// On submit: validates purchase → signUp → ensureProfile → navigate /home.
class ThankYouScreen extends ConsumerStatefulWidget {
  final String? email;

  const ThankYouScreen({this.email, super.key});

  @override
  ConsumerState<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends ConsumerState<ThankYouScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeHeadline;
  late Animation<double> _fadeForm;

  final _emailController = TextEditingController();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _emailIsReadonly = false;

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
      duration: const Duration(milliseconds: 2500),
    );

    _fadeHeadline = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _fadeForm = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Pre-fill email from URL query parameter
    if (widget.email != null && widget.email!.isNotEmpty) {
      _emailController.text = widget.email!;
      _emailIsReadonly = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _nomeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccess() async {
    final email = _emailController.text.trim();
    final nome = _nomeController.text.trim();
    final senha = _senhaController.text;

    // Validate fields
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Informe um email');
      return;
    }

    if (nome.isEmpty) {
      setState(() => _errorMessage = 'Informe como quer ser chamado');
      return;
    }

    if (senha.length < 6) {
      setState(() => _errorMessage = 'A senha precisa ter pelo menos 6 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Validate purchase exists for this email
      final hasPurchase =
          await ProfileService.instance.validatePurchaseByEmail(email);

      if (!hasPurchase) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Não encontramos uma compra para este email';
          });
        }
        return;
      }

      // Step 2: Create Supabase auth user
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: senha,
        data: {'nome': nome},
      );

      if (response.user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Erro ao criar conta. Tente novamente.';
          });
        }
        return;
      }

      // Step 3: Ensure profile with book access
      await ProfileService.instance.ensureProfileExists(
        displayName: nome,
        withBookAccess: true,
      );

      // Step 4: Navigate to home
      if (mounted) {
        context.go('/home');
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message;
        if (e.message.toLowerCase().contains('already registered') ||
            e.message.toLowerCase().contains('already been registered') ||
            e.message.toLowerCase().contains('user already registered')) {
          message = 'Já existe uma conta com este email. Faça login.';
        } else {
          message = 'Erro: ${e.message}';
        }
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro de conexão. Tente novamente.';
        });
      }
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Headline
                    FadeTransition(
                      opacity: _fadeHeadline,
                      child: const Text(
                        'Seu acesso já está pronto.',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    FadeTransition(
                      opacity: _fadeHeadline,
                      child: const Text(
                        'Agora só falta criar sua senha\npara entrar no seu espaço diante do Pai.',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Gold divider
                    FadeTransition(
                      opacity: _fadeHeadline,
                      child: Container(
                        width: 30,
                        height: 1,
                        color: _goldPrimary.withOpacity(0.15),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Form
                    FadeTransition(
                      opacity: _fadeForm,
                      child: Column(
                        children: [
                          // Email field — elegant display when readonly
                          _buildEmailField(),

                          const SizedBox(height: 24),

                          // Nome field
                          _buildField(
                            controller: _nomeController,
                            hint: 'como quer ser chamado',
                          ),

                          const SizedBox(height: 24),

                          // Senha field
                          _buildField(
                            controller: _senhaController,
                            hint: 'escolha uma senha',
                            obscure: true,
                          ),

                          // Error message
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A1A1A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _goldPrimary.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: _goldPrimary.withOpacity(0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],

                          const SizedBox(height: 40),

                          // Submit button
                          GestureDetector(
                            onTap: _isLoading ? null : _handleCreateAccess,
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _goldPrimary.withOpacity(0.08),
                                border: Border.all(
                                  color: _goldPrimary.withOpacity(0.3),
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
                                          color:
                                              _goldPrimary.withOpacity(0.5),
                                        ),
                                      )
                                    : const Text(
                                        'entrar na caminhada',
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

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Email field — when readonly, displays as an elegant gold badge.
  /// When editable (no external_reference), shows as a regular input.
  Widget _buildEmailField() {
    if (_emailIsReadonly) {
      // Elegant readonly email display — gold badge style
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _goldPrimary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _goldPrimary.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.email_outlined,
              color: _goldPrimary.withOpacity(0.5),
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _emailController.text,
                style: const TextStyle(
                  color: _goldPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Icon(
              Icons.lock_outline,
              color: _goldPrimary.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      );
    }

    // Editable email field (when no external_reference in URL)
    return _buildField(
      controller: _emailController,
      hint: 'email da compra',
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w300,
      ),
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }
}
