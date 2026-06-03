import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/insurance.dart';
import '../../constants/members.dart';
import '../../data/database.dart';
import '../../providers/insurance_provider.dart';
import '../../services/file_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';

// ---------------------------------------------------------------------------
// Draft document (not yet persisted)
// ---------------------------------------------------------------------------

class _DraftDoc {
  final String path;
  final String mimeType;
  const _DraftDoc({required this.path, required this.mimeType});
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class InsuranceFormScreen extends ConsumerStatefulWidget {
  final String? policyId;
  final String? memberId;

  const InsuranceFormScreen({super.key, this.policyId, this.memberId});

  bool get _isEdit => policyId != null;

  @override
  ConsumerState<InsuranceFormScreen> createState() =>
      _InsuranceFormScreenState();
}

class _InsuranceFormScreenState extends ConsumerState<InsuranceFormScreen> {
  // Controllers
  final _insurerCtrl = TextEditingController();
  final _policyNumberCtrl = TextEditingController();
  final _policyHolderCtrl = TextEditingController();
  final _sumInsuredCtrl = TextEditingController();
  final _premiumCtrl = TextEditingController();
  final _validFromCtrl = TextEditingController();
  final _validUntilCtrl = TextEditingController();
  final _helplineCtrl = TextEditingController();
  final _agentCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Selectors
  String _planType = 'PERSONAL';
  String _currency = 'INR';
  String _memberId = kDefaultSelfMemberId;

  // Documents
  final List<_DraftDoc> _drafts = [];
  List<InsuranceDocument> _existingDocs = [];

  bool _saving = false;
  bool _loadingEdit = false;

  static const _maxDocs = 6;

  @override
  void initState() {
    super.initState();
    if (widget.memberId != null) _memberId = widget.memberId!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget._isEdit) _loadForEdit();
    });
  }

  @override
  void dispose() {
    _insurerCtrl.dispose();
    _policyNumberCtrl.dispose();
    _policyHolderCtrl.dispose();
    _sumInsuredCtrl.dispose();
    _premiumCtrl.dispose();
    _validFromCtrl.dispose();
    _validUntilCtrl.dispose();
    _helplineCtrl.dispose();
    _agentCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Edit mode loading ────────────────────────────────────────────────────

  Future<void> _loadForEdit() async {
    setState(() => _loadingEdit = true);
    InsurancePolicy? policy =
        ref.read(insuranceProvider).currentPolicy;
    if (policy == null || policy.id != widget.policyId) {
      await ref.read(insuranceProvider.notifier).loadById(widget.policyId!);
      policy = ref.read(insuranceProvider).currentPolicy;
    }
    if (policy != null && mounted) {
      _applyPolicy(policy);
      final docs = await ref
          .read(insuranceProvider.notifier)
          .loadDocuments(widget.policyId!);
      if (mounted) setState(() => _existingDocs = docs);
    }
    if (mounted) setState(() => _loadingEdit = false);
  }

  void _applyPolicy(InsurancePolicy p) {
    _memberId = p.memberId;
    _planType = p.planType;
    _currency = p.currency;
    _insurerCtrl.text = p.insurerName;
    _policyNumberCtrl.text = p.policyNumber ?? '';
    _policyHolderCtrl.text = p.policyHolder ?? '';
    _sumInsuredCtrl.text =
        p.sumInsured != null ? p.sumInsured!.toStringAsFixed(0) : '';
    _premiumCtrl.text =
        p.premium != null ? p.premium!.toStringAsFixed(0) : '';
    _validFromCtrl.text = p.validFrom ?? '';
    _validUntilCtrl.text = p.validUntil ?? '';
    _helplineCtrl.text = p.helplinePhone ?? '';
    _agentCtrl.text = p.agentName ?? '';
    _notesCtrl.text = p.notes ?? '';
  }

  // ── Date pickers ──────────────────────────────────────────────────────────

  Future<void> _pickDate(TextEditingController ctrl) async {
    final initial = _parseDate(ctrl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        ctrl.text =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  DateTime? _parseDate(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  // ── Document picking ──────────────────────────────────────────────────────

  Future<void> _addDoc() async {
    final total = _drafts.length + _existingDocs.length;
    if (total >= _maxDocs) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 6 documents allowed')),
      );
      return;
    }
    final source = await _pickSource();
    if (source == null || !mounted) return;

    String? path;
    String? mimeType;

    if (source == 'camera') {
      final img = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 90);
      if (img == null) return;
      path = img.path;
      mimeType = 'image/jpeg';
    } else if (source == 'gallery') {
      final img = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (img == null) return;
      path = img.path;
      mimeType = img.mimeType ?? 'image/jpeg';
    } else if (source == 'pdf') {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return;
      final f = result.files.first;
      if (f.path == null) return;
      path = f.path!;
      mimeType = 'application/pdf';
    }

    if (path == null || !mounted) return;
    setState(
        () => _drafts.add(_DraftDoc(path: path!, mimeType: mimeType!)));
  }

  Future<String?> _pickSource() {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.md))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  Spacing.md, 0, Spacing.md, Spacing.sm),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Add Document', style: AppText.h3)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading:
                  const Icon(Icons.picture_as_pdf, color: AppColors.error),
              title: const Text('PDF File'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );
  }

  void _removeDraft(int index) =>
      setState(() => _drafts.removeAt(index));

  Future<void> _deleteExistingDoc(InsuranceDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${doc.fileName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ref2 = await ref
        .read(insuranceProvider.notifier)
        .deleteDocument(doc.id);
    if (ref2 != null) {
      await fileService.deleteFiles([
        ref2.filePath,
        if (ref2.thumbnailPath != null) ref2.thumbnailPath!,
      ]);
    }
    if (mounted) {
      setState(() => _existingDocs.removeWhere((d) => d.id == doc.id));
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final insurer = _insurerCtrl.text.trim();
    final validFrom = _validFromCtrl.text.trim();
    final validUntil = _validUntilCtrl.text.trim();
    final helpline = _helplineCtrl.text.trim();
    final sumText = _sumInsuredCtrl.text.trim();
    final premText = _premiumCtrl.text.trim();
    final sumInsured =
        sumText.isNotEmpty ? double.tryParse(sumText) : null;
    final premium =
        premText.isNotEmpty ? double.tryParse(premText) : null;

    final errors = validateInsuranceForm(
      insurerName: insurer.isEmpty ? null : insurer,
      validFrom: validFrom.isNotEmpty ? validFrom : null,
      validUntil: validUntil.isNotEmpty ? validUntil : null,
      helplinePhone: helpline.isNotEmpty ? helpline : null,
      sumInsured: sumInsured,
      premium: premium,
    );

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(errors.first),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final companion = InsurancePoliciesCompanion(
        memberId: Value(_memberId),
        insurerName: Value(insurer),
        planType: Value(_planType),
        policyNumber: _policyNumberCtrl.text.trim().isNotEmpty
            ? Value(_policyNumberCtrl.text.trim())
            : const Value.absent(),
        policyHolder: _policyHolderCtrl.text.trim().isNotEmpty
            ? Value(_policyHolderCtrl.text.trim())
            : const Value.absent(),
        sumInsured:
            sumInsured != null ? Value(sumInsured) : const Value.absent(),
        premium: premium != null ? Value(premium) : const Value.absent(),
        currency: Value(_currency),
        validFrom: validFrom.isNotEmpty
            ? Value(validFrom)
            : const Value.absent(),
        validUntil: validUntil.isNotEmpty
            ? Value(validUntil)
            : const Value.absent(),
        helplinePhone: helpline.isNotEmpty
            ? Value(helpline)
            : const Value.absent(),
        agentName: _agentCtrl.text.trim().isNotEmpty
            ? Value(_agentCtrl.text.trim())
            : const Value.absent(),
        notes: _notesCtrl.text.trim().isNotEmpty
            ? Value(_notesCtrl.text.trim())
            : const Value.absent(),
      );

      String policyId;
      if (widget._isEdit) {
        await ref
            .read(insuranceProvider.notifier)
            .updatePolicy(widget.policyId!, companion);
        policyId = widget.policyId!;
      } else {
        final policy = await ref
            .read(insuranceProvider.notifier)
            .createPolicy(companion);
        policyId = policy.id;
      }

      // Save draft documents
      for (final draft in _drafts) {
        final saved = await fileService.saveInsuranceDocument(
            policyId, draft.path, draft.mimeType);
        await ref.read(insuranceProvider.notifier).addDocument(
              InsuranceDocumentsCompanion(
                policyId: Value(policyId),
                filePath: Value(saved.filePath),
                fileName: Value(saved.fileName),
                mimeType: Value(draft.mimeType),
                sizeBytes: Value(saved.sizeBytes),
                thumbnailPath: saved.thumbnailPath != null
                    ? Value(saved.thumbnailPath)
                    : const Value.absent(),
              ),
            );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Save failed: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Policy'),
        content: const Text(
            'This will permanently delete the policy and all its documents.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    final refs = await ref
        .read(insuranceProvider.notifier)
        .deletePolicy(widget.policyId!);
    final paths = refs
        .expand((r) =>
            [r.filePath, if (r.thumbnailPath != null) r.thumbnailPath!])
        .toList();
    if (paths.isNotEmpty) await fileService.deleteFiles(paths);
    if (mounted) {
      setState(() => _saving = false);
      // Pop twice: past the detail screen back to the list
      context.pop();
      context.pop();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loadingEdit) {
      return Scaffold(
        appBar: AppBar(title: const Text('Policy')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget._isEdit ? 'Edit Policy' : 'Add Insurance'),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          // ── Section 1: Policy Details ────────────────────────────────────
          _SectionTile(
            title: 'Policy Details',
            initiallyExpanded: true,
            children: [
              _FormField(
                label: 'Insurer / Company *',
                controller: _insurerCtrl,
                icon: Icons.shield_outlined,
              ),
              const SizedBox(height: Spacing.sm),
              _PlanTypeDropdown(
                value: _planType,
                onChanged: (v) =>
                    setState(() => _planType = v ?? 'PERSONAL'),
              ),
              const SizedBox(height: Spacing.sm),
              _FormField(
                label: 'Policy Number',
                controller: _policyNumberCtrl,
                icon: Icons.numbers,
              ),
              const SizedBox(height: Spacing.sm),
              _FormField(
                label: 'Policy Holder',
                controller: _policyHolderCtrl,
                icon: Icons.person_outlined,
              ),
            ],
          ),

          // ── Section 2: Coverage & Validity ───────────────────────────────
          _SectionTile(
            title: 'Coverage & Validity',
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Sum Insured',
                      controller: _sumInsuredCtrl,
                      icon: Icons.account_balance_wallet_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  _CurrencyDropdown(
                    value: _currency,
                    onChanged: (v) =>
                        setState(() => _currency = v ?? 'INR'),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              _FormField(
                label: 'Premium',
                controller: _premiumCtrl,
                icon: Icons.receipt_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d*')),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              _DateField(
                label: 'Valid From',
                controller: _validFromCtrl,
                onTap: () => _pickDate(_validFromCtrl),
                trailing: _validFromCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 18, color: AppColors.textDisabled),
                        onPressed: () =>
                            setState(() => _validFromCtrl.clear()),
                      )
                    : null,
              ),
              const SizedBox(height: Spacing.sm),
              _DateField(
                label: 'Valid Until',
                controller: _validUntilCtrl,
                onTap: () => _pickDate(_validUntilCtrl),
                trailing: _validUntilCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 18, color: AppColors.textDisabled),
                        onPressed: () =>
                            setState(() => _validUntilCtrl.clear()),
                      )
                    : null,
              ),
            ],
          ),

          // ── Section 3: Contact & Notes ───────────────────────────────────
          _SectionTile(
            title: 'Contact & Notes',
            children: [
              _FormField(
                label: 'Helpline Phone',
                controller: _helplineCtrl,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: Spacing.sm),
              _FormField(
                label: 'Agent Name',
                controller: _agentCtrl,
                icon: Icons.support_agent_outlined,
              ),
              const SizedBox(height: Spacing.sm),
              _FormField(
                label: 'Notes',
                controller: _notesCtrl,
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
            ],
          ),

          // ── Section 4: Documents ─────────────────────────────────────────
          _SectionTile(
            title: 'Documents',
            children: [
              if (_existingDocs.isNotEmpty) ...[
                Text('Saved (${_existingDocs.length})',
                    style: AppText.caption),
                const SizedBox(height: Spacing.xs),
                Wrap(
                  children: _existingDocs
                      .map((doc) => _ExistingDocThumb(
                            doc: doc,
                            onDelete: () => _deleteExistingDoc(doc),
                          ))
                      .toList(),
                ),
                const SizedBox(height: Spacing.sm),
              ],
              if (_drafts.isNotEmpty) ...[
                Text('New (${_drafts.length})', style: AppText.caption),
                const SizedBox(height: Spacing.xs),
                Wrap(
                  children: List.generate(
                    _drafts.length,
                    (i) => _DraftDocThumb(
                      draft: _drafts[i],
                      onDelete: () => _removeDraft(i),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
              ],
              if (_drafts.length + _existingDocs.length < _maxDocs)
                OutlinedButton.icon(
                  onPressed: _addDoc,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add Document'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                )
              else
                Text(
                  'Maximum $_maxDocs documents reached',
                  style:
                      AppText.caption.copyWith(color: AppColors.textDisabled),
                ),
            ],
          ),

          // ── Delete footer (edit mode) ────────────────────────────────────
          if (widget._isEdit) ...[
            const SizedBox(height: Spacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: OutlinedButton.icon(
                onPressed: _saving ? null : _delete,
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error),
                label: const Text('Delete Policy',
                    style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets (reuse VisitFormScreen style)
// ---------------------------------------------------------------------------

class _SectionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  const _SectionTile(
      {required this.title,
      required this.children,
      this.initiallyExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      color: AppColors.surface,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(
            horizontal: Spacing.md, vertical: Spacing.xs),
        title: Text(
          title.toUpperCase(),
          style: AppText.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textSecondary),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
            Spacing.md, 0, Spacing.md, Spacing.md),
        children: children,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final Widget? trailing;
  const _DateField(
      {required this.label,
      required this.controller,
      required this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            suffixIcon: trailing,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: const OutlineInputBorder(),
        isDense: true,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class _PlanTypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _PlanTypeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Plan Type',
        prefixIcon: Icon(Icons.category_outlined, size: 18),
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: kPlanTypes
          .map((p) => DropdownMenuItem(value: p.id, child: Text(p.label)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _CurrencyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
            horizontal: Spacing.sm, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
        DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
        DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
      ],
      onChanged: onChanged,
    );
  }
}

// ── Draft doc thumbnail ───────────────────────────────────────────────────────

class _DraftDocThumb extends StatelessWidget {
  final _DraftDoc draft;
  final VoidCallback onDelete;
  const _DraftDocThumb({required this.draft, required this.onDelete});

  bool get _isPdf => draft.mimeType == 'application/pdf';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88 + 8,
      height: 88 + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 88,
            height: 88,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: _isPdf
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf,
                            color: AppColors.error, size: 28),
                        Text('PDF',
                            style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary)),
                      ],
                    )
                  : Image.file(File(draft.path),
                      fit: BoxFit.cover, width: 88, height: 88),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: AppColors.error, shape: BoxShape.circle),
                child: const Icon(Icons.close,
                    size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Existing doc thumbnail ────────────────────────────────────────────────────

class _ExistingDocThumb extends StatelessWidget {
  final InsuranceDocument doc;
  final VoidCallback onDelete;
  const _ExistingDocThumb({required this.doc, required this.onDelete});

  bool get _isPdf => doc.mimeType == 'application/pdf';
  String get _displayPath => doc.thumbnailPath ?? doc.filePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88 + 8,
      height: 88 + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 88,
            height: 88,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: _isPdf
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: AppColors.error, size: 28),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            doc.fileName,
                            style: const TextStyle(
                                fontSize: 8,
                                color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : Image.file(
                      File(_displayPath),
                      fit: BoxFit.cover,
                      width: 88,
                      height: 88,
                      errorBuilder: (_, _, _) => const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textDisabled),
                    ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: AppColors.error, shape: BoxShape.circle),
                child: const Icon(Icons.close,
                    size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
