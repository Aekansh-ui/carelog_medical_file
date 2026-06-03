import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/members.dart';
import '../../data/database.dart';
import '../../providers/members_provider.dart';
import '../../services/file_service.dart';
import '../../theme/app_theme.dart';

class MemberFormScreen extends ConsumerStatefulWidget {
  /// null = add mode, non-null = edit mode.
  final String? memberId;

  const MemberFormScreen({super.key, this.memberId});

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;

  String _relationship = 'OTHER';
  String? _gender;
  late String _colorHex;
  bool _saving = false;
  bool _loading = true;
  String? _dobError;
  Member? _editMember;

  bool get _isEdit => widget.memberId != null;
  bool get _isSelf => _editMember?.id == kDefaultSelfMemberId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _initFields();
  }

  void _initFields() {
    final id = widget.memberId;
    if (id == null) {
      // Add mode — auto-assign next palette color
      final count = ref.read(membersProvider).members.length;
      _colorHex = kMemberColorHex[count % kMemberColorHex.length];
      _loading = false;
      return;
    }
    // Edit mode — try in-memory lookup first
    final mws = ref
        .read(membersProvider)
        .members
        .where((m) => m.member.id == id)
        .firstOrNull;
    if (mws != null) {
      _applyMember(mws.member);
    } else {
      _colorHex = kMemberColorHex[0];
      _loadAsync(id);
    }
  }

  void _applyMember(Member m) {
    _editMember = m;
    _nameController.text = m.name;
    _relationship = m.relationship;
    _dobController.text = m.dateOfBirth ?? '';
    _gender = m.gender;
    _colorHex = m.color;
    _loading = false;
  }

  Future<void> _loadAsync(String id) async {
    final m = await ref.read(membersProvider.notifier).findById(id);
    if (!mounted) return;
    if (m != null) {
      setState(() => _applyMember(m));
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = _dobController.text.isNotEmpty
        ? DateTime.tryParse(_dobController.text) ?? DateTime(1990)
        : DateTime(1990);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _dobController.text = formatted;
        _dobError = null;
      });
    }
  }

  bool _validateDob() {
    final v = _dobController.text;
    if (v.isEmpty) {
      setState(() => _dobError = null);
      return true;
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) {
      setState(() => _dobError = 'Must be YYYY-MM-DD');
      return false;
    }
    try {
      DateTime.parse(v);
      setState(() => _dobError = null);
      return true;
    } catch (_) {
      setState(() => _dobError = 'Invalid date');
      return false;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name is required')));
      return;
    }
    if (!_validateDob()) return;

    setState(() => _saving = true);
    try {
      final dob =
          _dobController.text.isEmpty ? null : _dobController.text;
      if (_isEdit) {
        await ref.read(membersProvider.notifier).updateMember(
              widget.memberId!,
              MembersCompanion(
                name: Value(_nameController.text.trim()),
                relationship:
                    Value(_isSelf ? 'SELF' : _relationship),
                dateOfBirth: Value(dob),
                gender: Value(_gender),
                color: Value(_colorHex),
              ),
            );
      } else {
        await ref.read(membersProvider.notifier).createMember(
              MembersCompanion(
                name: Value(_nameController.text.trim()),
                relationship: Value(_relationship),
                dateOfBirth: Value(dob),
                gender: Value(_gender),
                color: Value(_colorHex),
              ),
            );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    if (_isSelf) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text(
          'Delete "${_editMember?.name}"?\n\nAll their visits, attachments, insurance and reminders will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      final refs = await ref
          .read(membersProvider.notifier)
          .deleteMember(widget.memberId!);
      final paths = <String>[];
      for (final r in refs) {
        paths.add(r.filePath);
        if (r.thumbnailPath != null) paths.add(r.thumbnailPath!);
      }
      if (paths.isNotEmpty) await fileService.deleteFiles(paths);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Edit Member' : 'Add Member';

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            Spacing.md, Spacing.md, Spacing.md, Spacing.xxl),
        children: [
          // Name
          const _FieldLabel('Name *'),
          const SizedBox(height: Spacing.xs),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            maxLength: 100,
            decoration: _inputDeco(hintText: 'Full name'),
          ),

          // Relationship
          const SizedBox(height: Spacing.md),
          const _FieldLabel('Relationship'),
          const SizedBox(height: Spacing.xs),
          _RelationshipPicker(
            selected: _relationship,
            locked: _isSelf,
            onChanged: (r) => setState(() => _relationship = r),
          ),

          // Date of birth
          const SizedBox(height: Spacing.md),
          const _FieldLabel('Date of Birth (optional)'),
          const SizedBox(height: Spacing.xs),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            onTap: _pickDate,
            decoration: _inputDeco(
              hintText: 'Select date',
              suffix: const Icon(Icons.calendar_month_outlined,
                  color: AppColors.textSecondary, size: 20),
              errorText: _dobError,
            ),
          ),
          if (_dobController.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () =>
                  setState(() => _dobController.text = ''),
              child: Text('Clear',
                  style: AppText.caption
                      .copyWith(color: AppColors.primary)),
            ),
          ],

          // Gender
          const SizedBox(height: Spacing.md),
          const _FieldLabel('Gender (optional)'),
          const SizedBox(height: Spacing.xs),
          _GenderPicker(
            selected: _gender,
            onChanged: (g) =>
                setState(() => _gender = _gender == g ? null : g),
          ),

          // Color
          const SizedBox(height: Spacing.md),
          const _FieldLabel('Colour'),
          const SizedBox(height: Spacing.xs),
          _ColorPicker(
            selected: _colorHex,
            onChanged: (c) => setState(() => _colorHex = c),
          ),

          // Delete section (edit mode, non-Self)
          if (_isEdit && !_isSelf) ...[
            const SizedBox(height: Spacing.xl),
            const Divider(),
            const SizedBox(height: Spacing.md),
            OutlinedButton.icon(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error),
              label: const Text('Delete Member',
                  style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.sm)),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            const Text(
              'Deletes this member and all their visits, attachments, insurance and reminders.',
              style: AppText.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDeco({
    String? hintText,
    Widget? suffix,
    String? errorText,
  }) =>
      InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.surface,
        counterText: '',
        errorText: errorText,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      );
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppText.caption.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.textSecondary,
        ),
      );
}

class _RelationshipPicker extends StatelessWidget {
  final String selected;
  final bool locked;
  final ValueChanged<String> onChanged;
  const _RelationshipPicker(
      {required this.selected,
      required this.locked,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.xs,
      children: kRelationships.map((r) {
        final on = r.id == selected;
        final fg = locked
            ? AppColors.textDisabled
            : (on ? Colors.white : AppColors.primary);
        return GestureDetector(
          onTap: locked ? null : () => onChanged(r.id),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm, vertical: 7),
            decoration: BoxDecoration(
              color: on ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: locked
                    ? AppColors.textDisabled
                    : AppColors.primary,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(r.icon, size: 14, color: fg),
                const SizedBox(width: 4),
                Text(r.label,
                    style: TextStyle(
                        fontSize: 13,
                        color: fg,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GenderPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;
  const _GenderPicker(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.xs,
      children: kGenders.map((g) {
        final on = g.id == selected;
        return GestureDetector(
          onTap: () => onChanged(g.id),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm, vertical: 7),
            decoration: BoxDecoration(
              color: on ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Text(
              g.label,
              style: TextStyle(
                fontSize: 13,
                color: on ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _ColorPicker(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: kMemberColorHex.map((hex) {
        final on = hex.toLowerCase() == selected.toLowerCase();
        return GestureDetector(
          onTap: () => onChanged(hex),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorFromHex(hex),
              shape: BoxShape.circle,
              border: on
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: on ? AppShadow.sm : null,
            ),
            child: on
                ? const Icon(Icons.check,
                    color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
