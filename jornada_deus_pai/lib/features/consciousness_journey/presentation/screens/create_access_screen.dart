import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Create Access screen - after payment, user creates their account
/// Email is pre-filled from purchase, user chooses password and username
class CreateAccessScreen extends StatefulWidget {
  const CreateAccessScreen({super.key});

  @override
  State<CreateAccessScreen> createState() => _CreateAccessScreenState();
}

class _CreateAccessScreenState extends State<CreateAccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeContent;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

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

    // TODO: Pre-fill email from purchase token/query params
    // final token = GoRouterState.of(context).uri.queryParameters['token'];
    // Fetch email from token and pre-fill
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccess() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Create Supabase account with email + password
    // Then redirect to book
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      context.go('/home');
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
                      const SizedBox(height: 80),

                      // Headline
                      const Text(
                        'Crie seu acesso.',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Esse será o seu espaço pessoal\ndiante do Pai.',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          height: 1.7,
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

                      // Email field (pre-filled, readonly when token available)
                      _buildField(
                        controller: _emailController,
                        hint: 'email da compra',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),

                      // Username
                      _buildField(
                        controller: _usernameController,
                        hint: 'como quer ser chamado',
                      ),
                      const SizedBox(height: 24),

                      // Password
                      _buildField(
                        controller: _passwordController,
                        hint: 'escolha uma senha',
                        obscure: true,
                      ),

                      const SizedBox(height: 48),

                      // Submit button
                      GestureDetector(
                        onTap: _isLoading ? null : _handleCreateAccess,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                      color: _goldPrimary.withOpacity(0.5),
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly ? _textSecondary : _textPrimary,
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
