/**
 * Question: Application ViewModel - Tshepiso Mofokeng
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_application.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/storage_service.dart';

enum ViewModelStatus { idle, loading, success, error }

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseClient _client  = Supabase.instance.client;
  final StorageService _storage = StorageService();

  List<StudentApplication> _applications = [];
  ViewModelStatus          _status       = ViewModelStatus.idle;
  String                   _error        = '';

  List<StudentApplication> get applications => _applications;
  ViewModelStatus          get status       => _status;
  String                   get error        => _error;
  bool                     get isLoading    => _status == ViewModelStatus.loading;

  // ─── READ: fetch all apps for the logged-in student ───────
  Future<void> fetchApplications() async {
    _setState(ViewModelStatus.loading);
    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from(SupabaseConstants.applicationsTable)
          .select()
          .eq('student_id', userId)
          .order('created_at', ascending: false);

      _applications = (response as List)
          .map((row) => StudentApplication.fromMap(row))
          .toList();
      _setState(ViewModelStatus.success);
    } catch (e) {
      _setState(ViewModelStatus.error, e.toString());
    }
  }

  // ─── CREATE ───────────────────────────────────────────────
  Future<bool> createApplication({
    required int    yearOfStudy,
    required String module1Level,
    required String module1Name,
    String?         module2Level,
    String?         module2Name,
    String?         docUrl,
  }) async {
    _setState(ViewModelStatus.loading);
    try {
      final user = _client.auth.currentUser!;

      final app = StudentApplication(
        id:           '',
        studentId:    user.id,
        studentEmail: user.email ?? '',
        yearOfStudy:  yearOfStudy,
        module1Level: module1Level,
        module1Name:  module1Name,
        module2Level: module2Level,
        module2Name:  module2Name,
        docUrl:       docUrl,
        status:       SupabaseConstants.statusPending,
        createdAt:    DateTime.now(),
      );

      await _client
          .from(SupabaseConstants.applicationsTable)
          .insert(app.toMap());

      await fetchApplications();
      return true;
    } catch (e) {
      _setState(ViewModelStatus.error, e.toString());
      return false;
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────
  Future<bool> updateApplication({
    required String id,
    required int    yearOfStudy,
    required String module1Level,
    required String module1Name,
    String?         module2Level,
    String?         module2Name,
    String?         existingDocUrl,
  }) async {
    _setState(ViewModelStatus.loading);
    try {
      String? docUrl = existingDocUrl;

      await _client
          .from(SupabaseConstants.applicationsTable)
          .update({
            'year_of_study' : yearOfStudy,
            'module_1_level': module1Level,
            'module_1_name' : module1Name,
            'module_2_level': module2Level,
            'module_2_name' : module2Name,
            'doc_url'       : docUrl,
          })
          .eq('id', id);

      await fetchApplications();
      return true;
    } catch (e) {
      _setState(ViewModelStatus.error, e.toString());
      return false;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────
  Future<bool> deleteApplication(String id) async {
    _setState(ViewModelStatus.loading);
    try {
      // Optionally delete the associated document from storage
      final app = _applications.firstWhere((a) => a.id == id,
          orElse: () => throw Exception('Application not found'));
      if (app.docUrl != null) {
        await _storage.deleteDocument(app.docUrl!);
      }

      await _client
          .from(SupabaseConstants.applicationsTable)
          .delete()
          .eq('id', id);

      _applications.removeWhere((a) => a.id == id);
      _setState(ViewModelStatus.success);
      return true;
    } catch (e) {
      _setState(ViewModelStatus.error, e.toString());
      return false;
    }
  }

  // ─── Check if student already has an application ──────────
  bool get hasExistingApplication => _applications.isNotEmpty;

  // ─── Helper ───────────────────────────────────────────────
  void _setState(ViewModelStatus s, [String err = '']) {
    _status = s;
    _error  = err;
    notifyListeners();
  }

  void clearError() {
    _error  = '';
    _status = ViewModelStatus.idle;
    notifyListeners();
  }
}
