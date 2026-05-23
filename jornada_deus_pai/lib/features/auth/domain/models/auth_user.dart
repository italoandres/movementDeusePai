import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// App User Model
/// Wrapper around Supabase User
class AppUser extends Equatable {
  final String id;
  final String email;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, createdAt];

  /// Create AppUser from Supabase User
  factory AppUser.fromSupabaseUser(supabase.User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
    );
  }
}
