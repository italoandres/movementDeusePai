import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

/// Access type enum for the ecosystem
enum AccessType { free, book, gifted, admin }

/// Provider that determines user's access level in the ecosystem
/// 
/// This is the CENTRAL source of truth for what a user can access.
/// Every screen checks this to decide what to show.
final userAccessTypeProvider = FutureProvider<AccessType>((ref) async {
  final user = SupabaseService.instance.currentUser;
  if (user == null) return AccessType.free;

  try {
    final profile = await SupabaseService.instance.client
        .from('profiles')
        .select('access_type, has_book_access')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) return AccessType.free;

    final accessType = profile['access_type'] as String? ?? 'free';
    
    switch (accessType) {
      case 'book':
        return AccessType.book;
      case 'gifted':
        return AccessType.gifted;
      case 'admin':
        return AccessType.admin;
      default:
        return AccessType.free;
    }
  } catch (e) {
    return AccessType.free;
  }
});

/// Simple boolean: does user have book access?
final hasBookAccessProvider = FutureProvider<bool>((ref) async {
  final access = await ref.watch(userAccessTypeProvider.future);
  return access == AccessType.book || 
         access == AccessType.gifted || 
         access == AccessType.admin;
});

/// Simple boolean: is user free tier?
final isFreeUserProvider = FutureProvider<bool>((ref) async {
  final access = await ref.watch(userAccessTypeProvider.future);
  return access == AccessType.free;
});

/// Is user authenticated at all?
final isAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseService.instance.isAuthenticated;
});
