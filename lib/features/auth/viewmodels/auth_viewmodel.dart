/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: Auth ViewModel
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/supabase_constants.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status       = AuthStatus.idle;
  String     _errorMessage = '';
  String     _userRole     = SupabaseConstants.roleStudent;

  AuthStatus get status       => _status;
  String     get errorMessage => _errorMessage;
  String     get userRole     => _userRole;
  bool       get isAdmin      => _userRole == SupabaseConstants.roleAdmin;

  // ─── Login ────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    _setStatus(AuthStatus.loading);

    try {
      await _authService.signIn(email: email, password: password);
      _userRole = _authService.getUserRole();
      _setStatus(AuthStatus.success);
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setStatus(AuthStatus.error);
    } catch (_) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setStatus(AuthStatus.error);
    }
  }

  // ─── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.signOut();
    _userRole = SupabaseConstants.roleStudent;
    _setStatus(AuthStatus.idle);
  }

  // ─── Reset error ──────────────────────────────────────────
  void resetError() {
    _errorMessage = '';
    _setStatus(AuthStatus.idle);
  }

  // ─── Helper ───────────────────────────────────────────────
  void _setStatus(AuthStatus s) {
    _status = s;
    notifyListeners();
  }
}
