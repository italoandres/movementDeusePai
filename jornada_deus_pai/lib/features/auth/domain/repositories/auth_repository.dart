import 'package:jornada_deus_pai/features/auth/domain/models/auth_user.dart';

/// Auth Repository Interface
abstract class AuthRepository {
  /// Get current authenticated user
  AppUser? getCurrentUser();

  /// Sign in with email and password
  Future<AppUser> signIn(String email, String password);

  /// Sign up with email and password
  Future<AppUser> signUp(String email, String password, String name);

  /// Sign out
  Future<void> signOut();

  /// Stream of auth state changes
  Stream<AppUser?> authStateChanges();
}
