/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: Application Detail Screen
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/student_application.dart';
import '../viewmodels/application_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/application_status_chip.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = ModalRoute.of(context)!.settings.arguments as StudentApplication;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          if (app.isPending)
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  Navigator.pushNamed(context, '/student/apply',
                      arguments: app);
                } else if (v == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Application'),
                      content: const Text(
                          'Are you sure you want to delete this application? This cannot be undone.'),
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
                  if (confirmed == true && context.mounted) {
                    await context
                        .read<ApplicationViewModel>()
                        .deleteApplication(app.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit Application')),
                PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  ApplicationStatusChip(status: app.status),
                  const SizedBox(height: 10),
                  Text(
                    app.isPending
                        ? 'Your application is under review.'
                        : app.isApproved
                            ? 'Congratulations! Your application was approved.'
                            : 'Unfortunately your application was not approved.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Details card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Application Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const Divider(),
                    _DetailRow(label: 'Year of Study', value: 'Year ${app.yearOfStudy}'),
                    _DetailRow(label: 'Module 1 Level', value: app.module1Level),
                    _DetailRow(label: 'Module 1', value: app.module1Name),
                    if (app.hasSecondModule) ...[
                      _DetailRow(label: 'Module 2 Level', value: app.module2Level ?? ''),
                      _DetailRow(label: 'Module 2', value: app.module2Name ?? ''),
                    ],
                    _DetailRow(
                      label: 'Date Applied',
                      value:
                          '${app.createdAt.day}/${app.createdAt.month}/${app.createdAt.year}',
                    ),
                    if (app.docUrl != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 130,
                              child: Text('Document',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500)),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse(app.docUrl!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('View Document'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}
