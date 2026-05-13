/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: Student Application Model
 */
class StudentApplication {
  final String  id;
  final String  studentId;
  final String  studentEmail;   // denormalised for admin view
  final int     yearOfStudy;    // 1, 2 or 3
  final String  module1Level;   // e.g. 'First Year'
  final String  module1Name;    // e.g. 'ITT111 - Introduction to Programming'
  final String? module2Level;   // optional second module
  final String? module2Name;
  final String? docUrl;         // Supabase Storage public URL
  final String  status;         // 'pending' | 'approved' | 'rejected'
  final DateTime createdAt;

  const StudentApplication({
    required this.id,
    required this.studentId,
    this.studentEmail = '',
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Name,
    this.module2Level,
    this.module2Name,
    this.docUrl,
    this.status = 'pending',
    required this.createdAt,
  });

  // ─── Factory: Supabase row → model ────────────────────────
  factory StudentApplication.fromMap(Map<String, dynamic> map) {
    return StudentApplication(
      id:           map['id']            as String,
      studentId:    map['student_id']    as String,
      studentEmail: (map['student_email'] as String?) ?? '',
      yearOfStudy:  map['year_of_study'] as int,
      module1Level: map['module_1_level'] as String,
      module1Name:  map['module_1_name']  as String,
      module2Level: map['module_2_level'] as String?,
      module2Name:  map['module_2_name']  as String?,
      docUrl:       map['doc_url']       as String?,
      status:       map['status']        as String,
      createdAt:    DateTime.parse(map['created_at'] as String),
    );
  }

  // ─── model → Supabase insert/update map ──────────────────
  Map<String, dynamic> toMap() => {
    'student_id'    : studentId,
    'student_email' : studentEmail,
    'year_of_study' : yearOfStudy,
    'module_1_level': module1Level,
    'module_1_name' : module1Name,
    'module_2_level': module2Level,
    'module_2_name' : module2Name,
    'doc_url'       : docUrl,
    'status'        : status,
  };

  // ─── Immutable copy with optional field overrides ─────────
  StudentApplication copyWith({
    String? status,
    String? docUrl,
    String? studentEmail,
    int?    yearOfStudy,
    String? module1Level,
    String? module1Name,
    String? module2Level,
    String? module2Name,
  }) {
    return StudentApplication(
      id:           id,
      studentId:    studentId,
      studentEmail: studentEmail ?? this.studentEmail,
      yearOfStudy:  yearOfStudy  ?? this.yearOfStudy,
      module1Level: module1Level ?? this.module1Level,
      module1Name:  module1Name  ?? this.module1Name,
      module2Level: module2Level ?? this.module2Level,
      module2Name:  module2Name  ?? this.module2Name,
      docUrl:       docUrl       ?? this.docUrl,
      status:       status       ?? this.status,
      createdAt:    createdAt,
    );
  }

  // ─── Display helpers ──────────────────────────────────────
  bool get isPending  => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get hasSecondModule => module2Name != null && module2Name!.isNotEmpty;

  String get statusDisplay =>
      status[0].toUpperCase() + status.substring(1);
}
