/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: Admin Dashboard Screen
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_viewmodel.dart';
import '../../student_portal/models/student_application.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../student_portal/views/widgets/application_status_chip.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().fetchAll();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  Future<bool> _confirm(String action, String detail) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Confirm $action'),
            content: Text(detail),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: action == 'Approve'
                      ? AppTheme.successGreen
                      : Colors.red,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<AdminViewModel>();
    final apps = vm.applications;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: vm.fetchAll,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.fetchAll,
        child: CustomScrollView(
          slivers: [
            // ── Stats header ──────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.primaryBlue,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Applications Overview',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                            label: 'Total',
                            value: vm.totalCount,
                            color: Colors.white),
                        const SizedBox(width: 10),
                        _StatCard(
                            label: 'Pending',
                            value: vm.pendingCount,
                            color: Colors.orange.shade200),
                        const SizedBox(width: 10),
                        _StatCard(
                            label: 'Approved',
                            value: vm.approvedCount,
                            color: Colors.green.shade200),
                        const SizedBox(width: 10),
                        _StatCard(
                            label: 'Rejected',
                            value: vm.rejectedCount,
                            color: Colors.red.shade200),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Filter bar ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                          label: 'All',
                          selected: vm.filterStatus == null,
                          onTap: () => vm.setFilter(null)),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Pending',
                          selected: vm.filterStatus == 'pending',
                          onTap: () => vm.setFilter('pending')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Approved',
                          selected: vm.filterStatus == 'approved',
                          onTap: () => vm.setFilter('approved')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Rejected',
                          selected: vm.filterStatus == 'rejected',
                          onTap: () => vm.setFilter('rejected')),
                    ],
                  ),
                ),
              ),
            ),

            // ── Loading ───────────────────────────────────
            if (vm.isLoading)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))

            // ── Empty ─────────────────────────────────────
            else if (apps.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text('No applications found'),
                    ],
                  ),
                ),
              )

            // ── List ──────────────────────────────────────
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _AdminAppCard(
                      app: apps[i],
                      onApprove: apps[i].isPending
                          ? () async {
                              if (await _confirm('Approve',
                                  'Approve this application for ${apps[i].module1Name}?')) {
                                vm.approveApplication(apps[i].id);
                              }
                            }
                          : null,
                      onReject: apps[i].isPending
                          ? () async {
                              if (await _confirm('Reject',
                                  'Reject this application for ${apps[i].module1Name}?')) {
                                vm.rejectApplication(apps[i].id);
                              }
                            }
                          : null,
                      onDelete: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Application'),
                            content: const Text(
                                'Permanently delete this application?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (ok == true) vm.deleteApplication(apps[i].id);
                      },
                    ),
                    childCount: apps.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(value.toString(),
                  style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
            ],
          ),
        ),
      );
}

// ─── Filter chip ──────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                selected ? AppTheme.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected
                    ? AppTheme.primaryBlue
                    : Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade700,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      );
}

// ─── Admin application card ───────────────────────────────────
class _AdminAppCard extends StatelessWidget {
  final StudentApplication app;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback onDelete;

  const _AdminAppCard({
    required this.app,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.module1Name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (app.hasSecondModule)
                        Text('+ ${app.module2Name}',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12)),
                    ],
                  ),
                ),
                ApplicationStatusChip(status: app.status),
              ],
            ),
            const SizedBox(height: 8),
            // Student info
            Row(children: [
              Icon(Icons.person_outline,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                app.studentEmail.isNotEmpty
                    ? app.studentEmail
                    : app.studentId,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.school_outlined,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                'Year ${app.yearOfStudy} \u2022 ${app.module1Level}',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '${app.createdAt.day}/${app.createdAt.month}/${app.createdAt.year}',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ]),

            if (app.isPending) ...[
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          minimumSize: const Size(0, 38)),
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          minimumSize: const Size(0, 38)),
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.grey),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: Colors.grey),
                  label: const Text('Delete',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
