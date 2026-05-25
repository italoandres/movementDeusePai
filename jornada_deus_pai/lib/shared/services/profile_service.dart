import 'dart:convert';

import 'package:http/http.dart' as http;
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
  ///
  /// When [withBookAccess] is true:
  /// - If profile is being CREATED: sets `has_book_access: true`, `access_type: 'book'`
  /// - If profile ALREADY EXISTS with `has_book_access: false`: does an UPDATE to grant book access
  /// - If profile already has book access: no change needed
  ///
  /// When [withBookAccess] is false (default): keeps current behavior unchanged.
  Future<bool> ensureProfileExists({
    String? displayName,
    bool withBookAccess = false,
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
          .select('id, has_book_access')
          .eq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        print('[ProfileService] Profile already exists');

        // If withBookAccess is requested and profile doesn't have it yet, update
        if (withBookAccess && existing['has_book_access'] == false) {
          print('[ProfileService] Granting book access to existing profile...');
          await _client.from('profiles').update({
            'has_book_access': true,
            'access_type': 'book',
          }).eq('id', user.id);
          print('[ProfileService] Book access granted successfully!');
        }

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
        'access_type': withBookAccess ? 'book' : 'free',
        'has_book_access': withBookAccess,
      });

      print('[ProfileService] Profile created successfully!${withBookAccess ? ' (with book access)' : ''}');
      return true;
    } catch (e) {
      print('[ProfileService] ERROR creating profile: $e');
      return false;
    }
  }

  /// Validate that a purchase exists for the given email.
  ///
  /// Calls the Next.js API endpoint to check if [email] has a purchase
  /// with `access_released = true` in the purchases table.
  /// Returns true if a valid purchase exists, false otherwise.
  ///
  /// This prevents account creation with book access for emails
  /// that did not actually complete a purchase.
  Future<bool> validatePurchaseByEmail(String email) async {
    try {
      print('[ProfileService] Validating purchase for: $email');

      final response = await http.post(
        Uri.parse('https://nosecreto.vercel.app/api/checkout/validate-purchase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final isValid = data['valid'] == true;
        print('[ProfileService] Purchase validation result: $isValid');
        return isValid;
      }

      print('[ProfileService] Purchase validation failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      print('[ProfileService] ERROR validating purchase: $e');
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
