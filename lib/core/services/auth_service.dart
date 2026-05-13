/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: Authentication Service
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
