/**
 * Student Numbers: 224079447, 220039413, 222068206, 224004059
 * Student Names  : Tshepiso Mofokeng, Dlali Ntlahla,
 *                  Odwa Cengimbo, Tshitso Selepe
 * Question: Authentication Service - Tshepiso Mofokeng
 */
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── Sign In ───────────────────────────────────────────────
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ─── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Get current user role from metadata ──────────────────
  /// To set a user as admin:
  /// Supabase Dashboard → Authentication → Users → Edit user
  /// Raw user meta data: { "role": "admin" }
  String getUserRole() {
    final meta = _client.auth.currentUser?.userMetadata;
    return (meta?['role'] as String?) ?? SupabaseConstants.roleStudent;
  }

  // ─── Getters ───────────────────────────────────────────────
  User?  get currentUser => _client.auth.currentUser;
  String get currentUserId => _client.auth.currentUser?.id ?? '';
  bool   get isLoggedIn  => _client.auth.currentUser != null;

  // ─── Auth state stream ────────────────────────────────────
  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;
}
