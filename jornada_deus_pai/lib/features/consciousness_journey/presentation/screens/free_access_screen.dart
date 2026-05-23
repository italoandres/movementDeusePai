import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/services/profile_service.dart';

/// Free access screen - creates REAL Supabase account
/// "Fui acolhido mesmo sem poder entrar pela porta principal."
class FreeAccessScreen extends StatefulWidget {
  const FreeAccessScreen({super.key});

  @override
  State<FreeAccessScreen> createState() => _FreeAccessScreenState();
}

class _FreeAccessScreenState extends State<FreeAccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeContent;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      duration: const Duration(milliseconds: 2000),
    );
    _fadeContent = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'preencha todos os campos');
      return;
    }

    if (!email.contains('@')) {
      setState(() => _error = 'informe um email válido');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'a senha precisa ter pelo menos 6 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create REAL user in Supabase Auth
      final response = await SupabaseService.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'nome': name,
          'access_type': 'free',
          'product': 'carta-de-um-orfao',
        },
      );

      if (response.user == null) {
        setState(() => _error = 'não foi possível criar sua conta. tente novamente.');
        return;
      }

      // User created and session persisted automatically by Supabase
      // Now ensure profile exists
      await ProfileService.instance.ensureProfileExists(
        displayName: name,
      );

      if (mounted) {
        context.go('/acesso-criado');
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('already registered') || errorMsg.contains('already exists')) {
        // User already exists - try to sign in instead
        try {
          await SupabaseService.instance.client.auth.signInWithPassword(
            email: email,
            password: password,
          );
          // Ensure profile exists after login too
          await ProfileService.instance.ensureProfileExists(displayName: name);
          if (mounted) {
            context.go('/acesso-criado');
          }
        } catch (loginError) {
          setState(() => _error = 'esse email já está cadastrado. tente fazer login.');
        }
      } else {
        setState(() => _error = 'algo deu errado. tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                child: FadeTransition(
                  opacity: _fadeContent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

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
                        'Talvez esse seja\napenas o começo.',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 36),

                      const Text(
                        'Nem toda caminhada começa da mesma forma.\n\nAlgumas pessoas chegam prontas para entrar.\nOutras apenas precisam de um lugar silencioso\npara respirar novamente.',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        '"A Carta de um Órfão" foi deixada para quem\ndeseja começar sem pressa.',
                        style: TextStyle(
                          color: _textPrimary.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 60),

                      // Divider
                      Container(
                        width: 30,
                        height: 1,
                        color: _goldPrimary.withOpacity(0.15),
                      ),

                      const SizedBox(height: 60),

                      // Form fields
                      _buildField(
                        controller: _nameController,
                        hint: 'seu nome',
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        controller: _emailController,
                        hint: 'seu email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        controller: _passwordController,
                        hint: 'escolha uma senha',
                        obscure: true,
                      ),

                      // Error message
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 48),

                      // Submit button
                      GestureDetector(
                        onTap: _isLoading ? null : _handleSubmit,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _goldPrimary.withOpacity(0.06),
                            border: Border.all(
                              color: _goldPrimary.withOpacity(0.25),
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
                                    'receber meu acesso',
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
