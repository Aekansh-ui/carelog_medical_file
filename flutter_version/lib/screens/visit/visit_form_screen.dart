import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/members.dart';
import '../../constants/specialities.dart';
import '../../data/database.dart';
import '../../providers/reminders_provider.dart';
import '../../providers/visits_provider.dart';
import '../../services/file_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart' as du;
import '../../utils/validators.dart';

// ---------------------------------------------------------------------------
// Draft attachment (not yet persisted)
// ---------------------------------------------------------------------------

class _DraftAtt {
  final String path;
  final String mimeType;
  final String type;
  const _DraftAtt(
      {required this.path, required this.mimeType, required this.type});
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class VisitFormScreen extends ConsumerStatefulWidget {
  /// Null → add mode. Non-null → edit mode.
  final String? visitId;

  /// Pre-set params (add mode).
  final String? bodyPartId;
  final String? specialityId;
  final String? memberId;

  const VisitFormScreen({
    super.key,
    this.visitId,
    this.bodyPartId,
    this.specialityId,
    this.memberId,
  });

  bool get _isEdit => visitId != null;

  @override
  ConsumerState<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends ConsumerState<VisitFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _visitDateCtrl = TextEditingController();
  final _followUpDateCtrl = TextEditingController();
  final _doctorNameCtrl = TextEditingController();
  final _clinicNameCtrl = TextEditingController();
  final _clinicPhoneCtrl = TextEditingController();
  final _doctorFeesCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Selectors
  String? _bodyPartId;
  String? _specialityId;
  String _memberId = kDefaultSelfMemberId;
  String _currency = 'INR';

  // Attachments
  final List<_DraftAtt> _drafts = [];
  List<Attachment> _existingAtts = [];

  bool _saving = false;
  bool _loadingEdit = false;

  @override
  void initState() {
    super.initState();
    _bodyPartId = widget.bodyPartId;
    _specialityId = widget.specialityId;
    if (widget.memberId != null) _memberId = widget.memberId!;

    // Default visitDate to today in add mode.
    if (!widget._isEdit) {
      _visitDateCtrl.text = du.today();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget._isEdit) _loadForEdit();
    });
  }

  @override
  void dispose() {
    _visitDateCtrl.dispose();
    _followUpDateCtrl.dispose();
    _doctorNameCtrl.dispose();
    _clinicNameCtrl.dispose();
    _clinicPhoneCtrl.dispose();
    _doctorFeesCtrl.dispose();
    _symptomsCtrl.dispose();
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Edit-mode loading ────────────────────────────────────────────────────

  Future<void> _loadForEdit() async {
    setState(() => _loadingEdit = true);
    // Try cached state first to avoid an extra DB round-trip.
    Visit? visit = ref.read(visitsProvider).currentVisit;
    if (visit == null || visit.id != widget.visitId) {
      await ref.read(visitsProvider.notifier).loadById(widget.visitId!);
      visit = ref.read(visitsProvider).currentVisit;
    }
    if (visit != null && mounted) {
      _applyVisit(visit);
      final atts = await ref
          .read(visitsProvider.notifier)
          .loadAttachments(widget.visitId!);
      if (mounted) setState(() => _existingAtts = atts);
    }
    if (mounted) setState(() => _loadingEdit = false);
  }

  void _applyVisit(Visit v) {
    _bodyPartId = v.bodyPartId;
    _specialityId = v.specialityId;
    if (v.memberId != null) _memberId = v.memberId!;
    _currency = v.currency;
    _visitDateCtrl.text = v.visitDate;
    _followUpDateCtrl.text = v.followUpDate ?? '';
    _doctorNameCtrl.text = v.doctorName ?? '';
    _clinicNameCtrl.text = v.clinicName ?? '';
    _clinicPhoneCtrl.text = v.clinicPhone ?? '';
    _doctorFeesCtrl.text =
        v.doctorFees != null ? v.doctorFees!.toStringAsFixed(0) : '';
    _symptomsCtrl.text = v.symptoms ?? '';
    _diagnosisCtrl.text = v.diagnosis ?? '';
    _notesCtrl.text = v.notes ?? '';
  }

  // ── Date pickers ──────────────────────────────────────────────────────────

  Future<void> _pickDate(TextEditingController ctrl,
      {DateTime? first, DateTime? last}) async {
    final initial = _parseDate(ctrl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first ?? DateTime(1990),
      lastDate: last ?? DateTime(2100),
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

  // ── Attachment picking ────────────────────────────────────────────────────

  Future<void> _addAttachment() async {
    final type = await _pickType();
    if (type == null || !mounted) return;
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
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final f = result.files.first;
      if (f.path == null) return;
      path = f.path!;
      mimeType = 'application/pdf';
    }

    if (path == null || !mounted) return;
    setState(() => _drafts.add(_DraftAtt(
          path: path!,
          mimeType: mimeType!,
          type: type,
        )));
  }

  Future<String?> _pickType() {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.md))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  Spacing.md, Spacing.sm, Spacing.md, Spacing.sm),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Attachment Type', style: AppText.h3)),
            ),
            for (final entry in const [
              ('prescription', Icons.description_outlined, 'Prescription'),
              ('medicine', Icons.medication_outlined, 'Medicine'),
              ('bill', Icons.receipt_outlined, 'Bill'),
              ('report', Icons.analytics_outlined, 'Report'),
            ])
              ListTile(
                leading: Icon(entry.$2, color: AppColors.primary),
                title: Text(entry.$3),
                onTap: () => Navigator.pop(ctx, entry.$1),
              ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );
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
            const _SheetHandle(),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  Spacing.md, Spacing.sm, Spacing.md, Spacing.sm),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Add From', style: AppText.h3)),
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

  void _removeDraft(int index) => setState(() => _drafts.removeAt(index));

  Future<void> _deleteExistingAtt(Attachment att) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Attachment'),
        content: Text('Delete "${att.fileName}"?'),
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
    final fileRef =
        await ref.read(visitsProvider.notifier).deleteAttachment(att.id);
    if (fileRef != null) {
      await fileService.deleteFiles([
        fileRef.filePath,
        if (fileRef.thumbnailPath != null) fileRef.thumbnailPath!,
      ]);
    }
    if (mounted) {
      setState(() => _existingAtts.removeWhere((a) => a.id == att.id));
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final vd = _visitDateCtrl.text.trim();
    final fu = _followUpDateCtrl.text.trim();
    final phone = _clinicPhoneCtrl.text.trim();
    final feesText = _doctorFeesCtrl.text.trim();
    final fees = feesText.isNotEmpty ? double.tryParse(feesText) : null;

    final errors = validateVisitForm(
      visitDate: vd.isEmpty ? null : vd,
      bodyPartId: _bodyPartId,
      specialityId: _specialityId,
      followUpDate: fu.isNotEmpty ? fu : null,
      clinicPhone: phone.isNotEmpty ? phone : null,
      doctorFees: fees,
    );

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final companion = VisitsCompanion(
        bodyPartId: Value(_bodyPartId!),
        specialityId: Value(_specialityId!),
        visitDate: Value(vd),
        followUpDate: fu.isNotEmpty ? Value(fu) : const Value.absent(),
        memberId: Value(_memberId),
        doctorName: _doctorNameCtrl.text.trim().isNotEmpty
            ? Value(_doctorNameCtrl.text.trim())
            : const Value.absent(),
        clinicName: _clinicNameCtrl.text.trim().isNotEmpty
            ? Value(_clinicNameCtrl.text.trim())
            : const Value.absent(),
        clinicPhone: phone.isNotEmpty ? Value(phone) : const Value.absent(),
        doctorFees: fees != null ? Value(fees) : const Value.absent(),
        currency: Value(_currency),
        symptoms: _symptomsCtrl.text.trim().isNotEmpty
            ? Value(_symptomsCtrl.text.trim())
            : const Value.absent(),
        diagnosis: _diagnosisCtrl.text.trim().isNotEmpty
            ? Value(_diagnosisCtrl.text.trim())
            : const Value.absent(),
        notes: _notesCtrl.text.trim().isNotEmpty
            ? Value(_notesCtrl.text.trim())
            : const Value.absent(),
      );

      String visitId;
      if (widget._isEdit) {
        await ref
            .read(visitsProvider.notifier)
            .updateVisit(widget.visitId!, companion);
        visitId = widget.visitId!;
      } else {
        final visit =
            await ref.read(visitsProvider.notifier).createVisit(companion);
        visitId = visit.id;
      }

      // Save draft attachments.
      for (final draft in _drafts) {
        final saved = await fileService.saveAttachment(
            visitId, draft.type, draft.path, draft.mimeType);
        await ref.read(visitsProvider.notifier).addAttachment(
              AttachmentsCompanion(
                visitId: Value(visitId),
                type: Value(draft.type),
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

      // Handle reminder.
      if (fu.isNotEmpty) {
        final existing =
            await ref.read(remindersProvider.notifier).findByVisit(visitId);
        if (existing == null) {
          await ref
              .read(remindersProvider.notifier)
              .createReminder(visitId, fu);
        } else if (existing.followUpDate != fu) {
          // Follow-up date changed — cancel old, create new.
          await ref
              .read(remindersProvider.notifier)
              .deleteReminder(existing.id);
          await ref
              .read(remindersProvider.notifier)
              .createReminder(visitId, fu);
        }
      }

      // Refresh the list so VisitListScreen rebuilds after pop.
      if (_specialityId != null) {
        await ref.read(visitsProvider.notifier).loadBySpeciality(
              _specialityId!,
              memberId:
                  _memberId != kDefaultSelfMemberId ? _memberId : null,
            );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Delete (edit mode) ────────────────────────────────────────────────────

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Visit'),
        content: const Text(
            'This will permanently delete the visit and all its attachments.'),
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
    final refs =
        await ref.read(visitsProvider.notifier).deleteVisit(widget.visitId!);
    final paths = refs
        .expand((r) =>
            [r.filePath, if (r.thumbnailPath != null) r.thumbnailPath!])
        .toList();
    if (paths.isNotEmpty) await fileService.deleteFiles(paths);
    if (mounted) {
      setState(() => _saving = false);
      context.pop();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loadingEdit) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visit')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget._isEdit ? 'Edit Visit' : 'New Visit'),
        actions: [
          if (widget._isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: Spacing.xxl),
          children: [
            _SectionTile(
              title: 'Visit Info',
              initiallyExpanded: true,
              children: [
                _DateField(
                  label: 'Visit Date *',
                  controller: _visitDateCtrl,
                  onTap: () => _pickDate(
                    _visitDateCtrl,
                    last: DateTime.now().add(const Duration(days: 1)),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                _DateField(
                  label: 'Follow-up Date',
                  controller: _followUpDateCtrl,
                  onTap: () =>
                      _pickDate(_followUpDateCtrl, first: DateTime.now()),
                  trailing: _followUpDateCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 18, color: AppColors.textDisabled),
                          onPressed: () =>
                              setState(() => _followUpDateCtrl.clear()),
                        )
                      : null,
                ),
                const SizedBox(height: Spacing.sm),
                // Speciality dropdown — shown only when not pre-set.
                if (widget.specialityId == null) ...[
                  _SpecialityDropdown(
                    value: _specialityId,
                    onChanged: (v) => setState(() => _specialityId = v),
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
                _FormField(
                  label: 'Doctor Name',
                  controller: _doctorNameCtrl,
                  icon: Icons.person_outlined,
                ),
                const SizedBox(height: Spacing.sm),
                _FormField(
                  label: 'Clinic / Hospital',
                  controller: _clinicNameCtrl,
                  icon: Icons.local_hospital_outlined,
                ),
                const SizedBox(height: Spacing.sm),
                _FormField(
                  label: 'Clinic Phone',
                  controller: _clinicPhoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _FormField(
                        label: 'Doctor Fees',
                        controller: _doctorFeesCtrl,
                        icon: Icons.currency_rupee,
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
              ],
            ),
            _SectionTile(
              title: 'Clinical',
              children: [
                _FormField(
                  label: 'Symptoms',
                  controller: _symptomsCtrl,
                  icon: Icons.sick_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: Spacing.sm),
                _FormField(
                  label: 'Diagnosis',
                  controller: _diagnosisCtrl,
                  icon: Icons.fact_check_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: Spacing.sm),
                _FormField(
                  label: 'Notes',
                  controller: _notesCtrl,
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),
              ],
            ),
            _SectionTile(
              title: 'Attachments',
              children: [
                if (_existingAtts.isNotEmpty) ...[
                  Text('Saved (${_existingAtts.length})',
                      style: AppText.caption),
                  const SizedBox(height: Spacing.xs),
                  Wrap(
                    children: _existingAtts
                        .map((att) => _ExistingThumb(
                              att: att,
                              onDelete: () => _deleteExistingAtt(att),
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
                      (i) => _DraftThumb(
                        draft: _drafts[i],
                        onDelete: () => _removeDraft(i),
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
                OutlinedButton.icon(
                  onPressed: _addAttachment,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add Attachment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _SectionTile({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

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

// _DateField wraps a readOnly TextFormField with a GestureDetector for the
// date picker — the field itself uses AbsorbPointer so the keyboard never appears.
class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DateField({
    required this.label,
    required this.controller,
    required this.onTap,
    this.trailing,
  });

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
            prefixIcon:
                const Icon(Icons.calendar_today_outlined, size: 18),
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

class _SpecialityDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _SpecialityDropdown({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Speciality *',
        prefixIcon: Icon(Icons.medical_services_outlined, size: 18),
        border: OutlineInputBorder(),
        isDense: true,
      ),
      hint: const Text('Select speciality'),
      items: kSpecialities
          .map((s) => DropdownMenuItem(value: s.id, child: Text(s.label)))
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

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.borderStrong,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

// ── Draft thumbnail ───────────────────────────────────────────────────────────

class _DraftThumb extends StatelessWidget {
  final _DraftAtt draft;
  final VoidCallback onDelete;
  const _DraftThumb({required this.draft, required this.onDelete});

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
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: AppColors.error, size: 28),
                        const SizedBox(height: 2),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _typeLabel(draft.type),
                            style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Image.file(File(draft.path),
                      fit: BoxFit.cover, width: 88, height: 88),
            ),
          ),
          // Type label strip
          Positioned(
            left: 4,
            right: 0,
            bottom: 4,
            child: Container(
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.sm),
                    bottomRight: Radius.circular(AppRadius.sm)),
              ),
              alignment: Alignment.center,
              child: Text(
                _typeLabel(draft.type),
                style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          // Delete button
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String t) => const {
        'prescription': 'Rx',
        'medicine': 'Med',
        'bill': 'Bill',
        'report': 'Rpt',
      }[t] ??
      t;
}

// ── Existing attachment thumbnail (edit mode) ─────────────────────────────────

class _ExistingThumb extends StatelessWidget {
  final Attachment att;
  final VoidCallback onDelete;
  const _ExistingThumb({required this.att, required this.onDelete});

  bool get _isPdf => att.mimeType == 'application/pdf';
  String get _displayPath => att.thumbnailPath ?? att.filePath;

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
                        const SizedBox(height: 2),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            att.type,
                            style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
