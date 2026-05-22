/**
 * Student Numbers: 224079447, 220039413, 222068206, 224004059
 * Student Names  : Tshepiso Mofokeng, Dlali Ntlahla,
 *                  Odwa Cengimbo, Tshitso Selepe
 * Question: Storage Service - Tshepiso Mofokeng
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
