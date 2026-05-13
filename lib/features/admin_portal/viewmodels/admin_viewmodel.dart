/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: Admin ViewModel
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../student_portal/models/student_application.dart';
import '../../../core/constants/supabase_constants.dart';

class AdminViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<StudentApplication> _all     = [];
  bool    _isLoading    = false;
  String  _error        = '';
  String? _filterStatus; // null = show all

  // ─── Getters ──────────────────────────────────────────────
  List<StudentApplication> get applications {
    if (_filterStatus == null) return _all;
    return _all.where((a) => a.status == _filterStatus).toList();
  }

  bool    get isLoading    => _isLoading;
  String  get error        => _error;
  String? get filterStatus => _filterStatus;

  int get pendingCount  => _all.where((a) => a.isPending).length;
  int get approvedCount => _all.where((a) => a.isApproved).length;
  int get rejectedCount => _all.where((a) => a.isRejected).length;
  int get totalCount    => _all.length;

  // ─── Fetch ALL applications ───────────────────────────────
  Future<void> fetchAll() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final response = await _client
          .from(SupabaseConstants.applicationsTable)
          .select()
          .order('created_at', ascending: false);

      _all = (response as List)
          .map((row) => StudentApplication.fromMap(row))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Approve ──────────────────────────────────────────────
  Future<void> approveApplication(String id) async {
    await _updateStatus(id, SupabaseConstants.statusApproved);
  }

  // ─── Reject ───────────────────────────────────────────────
  Future<void> rejectApplication(String id) async {
    await _updateStatus(id, SupabaseConstants.statusRejected);
  }

  // ─── Delete ───────────────────────────────────────────────
  Future<void> deleteApplication(String id) async {
    try {
      await _client
          .from(SupabaseConstants.applicationsTable)
          .delete()
          .eq('id', id);
      _all.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ─── Filter ───────────────────────────────────────────────
  void setFilter(String? status) {
    _filterStatus = status;
    notifyListeners();
  }

  // ─── Internal: update status in Supabase + local list ─────
  Future<void> _updateStatus(String id, String status) async {
    try {
      await _client
          .from(SupabaseConstants.applicationsTable)
          .update({'status': status}).eq('id', id);

      final idx = _all.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _all[idx] = _all[idx].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
