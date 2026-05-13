/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: Storage Service
 */
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── Upload supporting document ───────────────────────────
  /// Uploads a file to the 'supporting-docs' bucket and returns
  /// the public URL. Filename is scoped by userId to avoid collisions.
  Future<String> uploadDocument({
    required File file,
    required String userId,
  }) async {
    final ext      = file.path.split('.').last.toLowerCase();
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage
        .from(SupabaseConstants.docsBucket)
        .upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: false),
        );

    return _client.storage
        .from(SupabaseConstants.docsBucket)
        .getPublicUrl(fileName);
  }

  // ─── Delete a document by URL ─────────────────────────────
  Future<void> deleteDocument(String publicUrl) async {
    // Extract the file path from the public URL
    final uri      = Uri.parse(publicUrl);
    final segments = uri.pathSegments;
    // Path after the bucket name
    final bucketIndex = segments.indexOf(SupabaseConstants.docsBucket);
    if (bucketIndex == -1) return;
    final filePath = segments.skip(bucketIndex + 1).join('/');

    await _client.storage
        .from(SupabaseConstants.docsBucket)
        .remove([filePath]);
  }
}
