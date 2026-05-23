import 'package:supabase_flutter/supabase_flutter.dart';

/// Profile Service - ensures profile always exists for authenticated user
///
/// Uses Supabase.instance.client directly to always have the latest session.
/// Call ensureProfileExists after every signup AND login.
class ProfileService {
  static final ProfileService _instance = ProfileService._();
  static ProfileService get instance => _instance;
  ProfileService._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Ensure profile exists for the current user.
  /// Call this after any successful auth event (signup or login).
  Future<bool> ensureProfileExists({
    String? displayName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      print('[ProfileService] No current user, cannot create profile');
      return false;
    }

    print('[ProfileService] Ensuring profile for: ${user.email} (${user.id})');

    try {
      // Check if profile already exists
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        print('[ProfileService] Profile already exists');
        return true;
      }

      // Profile doesn't exist — create it
      final name = displayName ??
          user.userMetadata?['nome'] as String? ??
          user.userMetadata?['name'] as String? ??
          'Usuário';

      print('[ProfileService] Creating profile for ${user.email}...');

      await _client.from('profiles').insert({
        'id': user.id,
        'nome': name,
        'email': user.email,
        'perfil_is_complete': false,
        'senha_is_seted': true,
        'app_source': 'book',
        'language': 'pt',
        'access_type': 'free',
        'has_book_access': false,
      });

      print('[ProfileService] Profile created successfully!');
      return true;
    } catch (e) {
      print('[ProfileService] ERROR creating profile: $e');
      return false;
    }
  }

  /// Get the current user's profile
  Future<Map<String, dynamic>?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      return await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
    } catch (e) {
      print('[ProfileService] Error getting profile: $e');
      return null;
    }
  }
}
