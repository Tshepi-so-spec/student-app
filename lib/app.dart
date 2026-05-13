/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: App Routes
 */
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/views/login_screen.dart';
import 'features/student_portal/views/home_screen.dart';
import 'features/student_portal/views/application_form_screen.dart';
import 'features/student_portal/views/application_detail_screen.dart';
import 'features/admin_portal/views/admin_dashboard_screen.dart';

class StudentAssistantApp extends StatelessWidget {
  const StudentAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Assistant System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/student/home': (_) => const HomeScreen(),
        '/student/apply': (_) => const ApplicationFormScreen(),
        '/student/detail': (_) => const ApplicationDetailScreen(),
        '/admin/dashboard': (_) => const AdminDashboardScreen(),
      },
    );
  }
}
