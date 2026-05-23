import 'package:jornada_deus_pai/features/auth/domain/models/auth_user.dart';
import 'package:jornada_deus_pai/features/auth/domain/repositories/auth_repository.dart';
import 'package:jornada_deus_pai/shared/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepositoryImpl(this._supabaseService);

  @override
  AppUser? getCurrentUser() {
    final user = _supabaseService.currentUser;
    return user != null ? AppUser.fromSupabaseUser(user) : null;
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    try {
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Falha no login. Verifique suas credenciais.');
      }

      return AppUser.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  @override
  Future<AppUser> signUp(String email, String password, String name) async {
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'nome': name},
      );

      if (response.user == null) {
        throw Exception('Falha no cadastro. Tente novamente.');
      }

      return AppUser.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseService.client.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao sair: $e');
    }
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _supabaseService.authStateChanges.map((authState) {
      final user = authState.session?.user;
      return user != null ? AppUser.fromSupabaseUser(user) : null;
    });
  }

  /// Get user-friendly error message from AuthException
  String _getAuthErrorMessage(AuthException exception) {
    switch (exception.statusCode) {
      case '400':
        return 'Email ou senha inválidos.';
      case '422':
        return 'Email já cadastrado.';
      default:
        return exception.message;
    }
  }
}
