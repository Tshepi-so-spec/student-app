/**
 * Student Numbers: 224079447, 220039413, 222068206, 224004059
 * Student Names  : Tshepiso Mofokeng, Dlali Ntlahla,
 *                  Odwa Cengimbo, Tshitso Selepe
 * Question: Supabase Constants - Dlali Ntlahla
 */
class SupabaseConstants {
  // Table names
  static const String applicationsTable = 'applications';
  static const String profilesTable = 'profiles';

  // Storage bucket
  static const String docsBucket = 'supporting-docs';

  // Application statuses
  static const String statusPending  = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // User roles
  static const String roleStudent = 'student';
  static const String roleAdmin   = 'admin';
}

/// Available modules grouped by academic level
class ModuleData {
  static const Map<String, List<String>> modulesByLevel = {
    'First Year': [
      'ITT111 - Introduction to Programming',
      'ITT121 - Computer Fundamentals',
      'ITT131 - Web Development Basics',
      'ITT141 - Database Fundamentals',
    ],
    'Second Year': [
      'ITT211 - Object-Oriented Programming',
      'ITT221 - Data Structures',
      'ITT231 - Operating Systems',
      'ITT241 - Networking Fundamentals',
    ],
    'Third Year': [
      'ITT311 - Software Engineering',
      'ITT321 - Mobile Application Development',
      'ITT331 - Artificial Intelligence',
      'ITT341 - Cloud Computing',
    ],
  };

  static const List<String> levels = [
    'First Year',
    'Second Year',
    'Third Year',
  ];

  static const List<int> yearsOfStudy = [1, 2, 3];
}
