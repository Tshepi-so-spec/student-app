/**
 * Student Numbers: 224079447, 220039413, 222068206, 224004059
 * Student Names  : Tshepiso Mofokeng, Dlali Ntlahla,
 *                  Odwa Cengimbo, Tshitso Selepe
 * Question: Home Screen - Dlali Ntlahla
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../viewmodels/application_viewmodel.dart';
import '../models/student_application.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/application_status_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchApplications();
    });
  }

  // ─── Logout ───────────────────────────────────────────────
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthViewModel>().logout();
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm      = context.watch<ApplicationViewModel>();
    final user    = Supabase.instance.client.auth.currentUser;
    final apps    = vm.applications;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Applications'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.fetchApplications(),
        child: CustomScrollView(
          slivers: [
            // ── Welcome header ────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.primaryBlue,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'Student',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Summary card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryTile(
                            label: 'Total',
                            value: apps.length.toString(),
                            icon: Icons.description_outlined,
                          ),
                          _SummaryTile(
                            label: 'Pending',
                            value: apps
                                .where((a) => a.isPending)
                                .length
                                .toString(),
                            icon: Icons.hourglass_empty,
                          ),
                          _SummaryTile(
                            label: 'Approved',
                            value: apps
                                .where((a) => a.isApproved)
                                .length
                                .toString(),
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Section title ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    const Text(
                      'My Applications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (apps.isEmpty)
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(
                            context, '/student/apply'),
                        icon: const Icon(Icons.add),
                        label: const Text('Apply Now'),
                      ),
                  ],
                ),
              ),
            ),

            // ── Loading ───────────────────────────────────────
            if (vm.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )

            // ── Empty state ───────────────────────────────────
            else if (apps.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 72, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No applications yet',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text(
                        'Tap the button below to apply for\na Student Assistant position.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )

            // ── Application list ──────────────────────────────
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ApplicationCard(app: apps[i]),
                    childCount: apps.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // ── FAB: Apply if no app exists, warn if already applied ─
      floatingActionButton: FloatingActionButton.extended(
        onPressed: apps.isEmpty
            ? () => Navigator.pushNamed(context, '/student/apply')
                .then((_) => vm.fetchApplications())
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'You may only submit one application. Edit or delete your existing one.',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
        icon: Icon(apps.isEmpty ? Icons.add : Icons.info_outline),
        label: Text(apps.isEmpty ? 'Apply Now' : 'One Application Only'),
        backgroundColor: apps.isEmpty ? AppTheme.primaryBlue : Colors.orange,
      ),
    );
  }
}

// ─── Summary tile ─────────────────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _SummaryTile(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
        ],
      );
}

// ─── Application card ─────────────────────────────────────────
class _ApplicationCard extends StatelessWidget {
  final StudentApplication app;
  const _ApplicationCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(
          context,
          '/student/detail',
          arguments: app,
        ).then((_) => context.read<ApplicationViewModel>().fetchApplications()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      app.module1Name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  ApplicationStatusChip(status: app.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Year ${app.yearOfStudy} \u2022 ${app.module1Level}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              if (app.hasSecondModule) ...[
                const SizedBox(height: 4),
                Text(
                  'Also: ${app.module2Name}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'Applied ${_formatDate(app.createdAt)}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
