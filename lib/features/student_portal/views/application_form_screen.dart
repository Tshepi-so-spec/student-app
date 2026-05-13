/**
 * Student Numbers: [Student Number 1], [Student Number 2], [Student Number 3], [Student Number 4], [Student Number 5]
 * Student Names  : [Full Name 1], [Full Name 2], [Full Name 3], [Full Name 4], [Full Name 5]
 * Question: Student Assistant Application Form
 */
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../viewmodels/application_viewmodel.dart';
import '../models/student_application.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/theme/app_theme.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form state
  int?    _yearOfStudy;
  String? _mod1Level;
  String? _mod1Name;
  bool    _addSecondModule = false;
  String? _mod2Level;
  String? _mod2Name;

  // File state - supports both web (bytes) and mobile (File)
  File?        _document;           // mobile/desktop
  Uint8List?   _webDocBytes;        // web
  String?      _webDocName;         // web filename
  String?      _existingDocUrl;
  bool         _confirmed  = false;
  bool         _submitting = false;

  // Edit mode
  StudentApplication? _editApp;
  bool get _isEditing => _editApp != null;
  bool get _hasDocument =>
      _document != null || _webDocBytes != null || _existingDocUrl != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is StudentApplication && _editApp == null) {
      _editApp         = arg;
      _yearOfStudy     = arg.yearOfStudy;
      _mod1Level       = arg.module1Level;
      _mod1Name        = arg.module1Name;
      _mod2Level       = arg.module2Level;
      _mod2Name        = arg.module2Name;
      _existingDocUrl  = arg.docUrl;
      _addSecondModule = arg.hasSecondModule;
      _confirmed       = true;
    }
  }

  // ─── Pick document (web + mobile) ─────────────────────────
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: kIsWeb, // load bytes on web
    );
    if (result == null) return;
    final picked = result.files.single;

    if (kIsWeb) {
      // Web: use bytes directly
      setState(() {
        _webDocBytes = picked.bytes;
        _webDocName  = picked.name;
        _document    = null;
      });
    } else {
      // Mobile / Desktop: use file path
      if (picked.path != null) {
        setState(() {
          _document    = File(picked.path!);
          _webDocBytes = null;
          _webDocName  = null;
        });
      }
    }
  }

  // ─── Upload to Supabase Storage ───────────────────────────
  Future<String?> _uploadDocument() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final ts     = DateTime.now().millisecondsSinceEpoch;

    if (kIsWeb && _webDocBytes != null) {
      final ext      = _webDocName?.split('.').last ?? 'pdf';
      final fileName = '${userId}_$ts.$ext';
      await Supabase.instance.client.storage
          .from(SupabaseConstants.docsBucket)
          .uploadBinary(fileName, _webDocBytes!);
      return Supabase.instance.client.storage
          .from(SupabaseConstants.docsBucket)
          .getPublicUrl(fileName);
    } else if (_document != null) {
      final ext      = _document!.path.split('.').last;
      final fileName = '${userId}_$ts.$ext';
      await Supabase.instance.client.storage
          .from(SupabaseConstants.docsBucket)
          .upload(fileName, _document!);
      return Supabase.instance.client.storage
          .from(SupabaseConstants.docsBucket)
          .getPublicUrl(fileName);
    }
    return _existingDocUrl;
  }

  // ─── Submit ───────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_confirmed) {
      _showSnack('Please confirm your eligibility before submitting.',
          isError: true);
      return;
    }

    if (!_hasDocument) {
      _showSnack('Please attach a supporting document.', isError: true);
      return;
    }

    setState(() => _submitting = true);
    final vm = context.read<ApplicationViewModel>();

    try {
      final docUrl = await _uploadDocument();
      bool success;

      if (_isEditing) {
        success = await vm.updateApplication(
          id:             _editApp!.id,
          yearOfStudy:    _yearOfStudy!,
          module1Level:   _mod1Level!,
          module1Name:    _mod1Name!,
          module2Level:   _addSecondModule ? _mod2Level : null,
          module2Name:    _addSecondModule ? _mod2Name  : null,
          existingDocUrl: docUrl,
        );
      } else {
        success = await vm.createApplication(
          yearOfStudy:  _yearOfStudy!,
          module1Level: _mod1Level!,
          module1Name:  _mod1Name!,
          module2Level: _addSecondModule ? _mod2Level : null,
          module2Name:  _addSecondModule ? _mod2Name  : null,
          docUrl:       docUrl,
        );
      }

      setState(() => _submitting = false);
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
      } else {
        _showSnack(vm.error, isError: true);
      }
    } catch (e) {
      setState(() => _submitting = false);
      _showSnack('Upload failed: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? Colors.red.shade700 : Colors.green.shade700,
    ));
  }

  // ─── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEditing ? 'Edit Application' : 'Apply — Student Assistant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.accentBlue.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.accentBlue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You may apply for a maximum of two modules. '
                        'Only one application per student is allowed.',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Year of study
              _SectionHeader(title: 'Academic Details'),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _yearOfStudy,
                decoration: const InputDecoration(
                  labelText: 'Current Year of Study *',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: ModuleData.yearsOfStudy
                    .map((y) => DropdownMenuItem(
                        value: y, child: Text('Year $y')))
                    .toList(),
                onChanged: (v) => setState(() => _yearOfStudy = v),
                validator: (v) =>
                    v == null ? 'Year of study is required' : null,
              ),
              const SizedBox(height: 20),

              // Module 1
              _SectionHeader(title: 'Module 1 (Required)'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _mod1Level,
                decoration: const InputDecoration(
                  labelText: 'Academic Level *',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                items: ModuleData.levels
                    .map((l) =>
                        DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _mod1Level = v;
                  _mod1Name  = null;
                }),
                validator: (v) =>
                    v == null ? 'Academic level is required' : null,
              ),
              if (_mod1Level != null) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _mod1Name,
                  decoration: const InputDecoration(
                    labelText: 'Module *',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  items: (ModuleData.modulesByLevel[_mod1Level] ?? [])
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _mod1Name = v),
                  validator: (v) =>
                      v == null ? 'Module is required' : null,
                ),
              ],
              const SizedBox(height: 20),

              // Module 2
              _SectionHeader(title: 'Module 2 (Optional)'),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Add a second module'),
                subtitle:
                    const Text('You may assist with at most 2 modules'),
                value: _addSecondModule,
                activeColor: AppTheme.primaryBlue,
                onChanged: (v) => setState(() {
                  _addSecondModule = v;
                  if (!v) {
                    _mod2Level = null;
                    _mod2Name  = null;
                  }
                }),
              ),
              if (_addSecondModule) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _mod2Level,
                  decoration: const InputDecoration(
                    labelText: 'Academic Level *',
                    prefixIcon: Icon(Icons.layers_outlined),
                  ),
                  items: ModuleData.levels
                      .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _mod2Level = v;
                    _mod2Name  = null;
                  }),
                  validator: (v) =>
                      _addSecondModule && v == null ? 'Required' : null,
                ),
                if (_mod2Level != null) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _mod2Name,
                    decoration: const InputDecoration(
                      labelText: 'Module *',
                      prefixIcon: Icon(Icons.book_outlined),
                    ),
                    items: (ModuleData.modulesByLevel[_mod2Level] ?? [])
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _mod2Name = v),
                    validator: (v) =>
                        _addSecondModule && v == null ? 'Required' : null,
                  ),
                ],
              ],
              const SizedBox(height: 20),

              // Supporting document
              _SectionHeader(title: 'Supporting Documentation'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Choose File (PDF / Image)'),
                    ),
                    const SizedBox(height: 8),
                    // Show selected file
                    if (kIsWeb && _webDocBytes != null) ...[
                      Row(children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_webDocName ?? 'File selected',
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() {
                            _webDocBytes = null;
                            _webDocName  = null;
                          }),
                        ),
                      ]),
                    ] else if (!kIsWeb && _document != null) ...[
                      Row(children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                _document!.path.split('/').last,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () =>
                              setState(() => _document = null),
                        ),
                      ]),
                    ] else if (_existingDocUrl != null) ...[
                      const Row(children: [
                        Icon(Icons.link, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text('Existing document attached',
                            style: TextStyle(fontSize: 13)),
                      ]),
                    ] else ...[
                      Text(
                        'No document selected. Attachment is required.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Eligibility confirmation
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _confirmed
                        ? AppTheme.successGreen.withValues(alpha: 0.4)
                        : Colors.grey.shade300,
                  ),
                  color: _confirmed
                      ? const Color(0xFFE8F5E9)
                      : Colors.grey.shade50,
                ),
                child: CheckboxListTile(
                  value: _confirmed,
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (v) => setState(() => _confirmed = v!),
                  title: const Text(
                    'I confirm that I meet the minimum academic requirements '
                    'for a Student Assistant position.',
                    style: TextStyle(fontSize: 13),
                  ),
                  subtitle: const Text(
                    'Note: Eligibility is determined by administrative staff.',
                    style: TextStyle(fontSize: 11),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                ),
              ),
              const SizedBox(height: 28),

              // Submit button
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(_isEditing
                        ? 'Update Application'
                        : 'Submit Application'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue)),
          const Divider(height: 8),
        ],
      );
}
