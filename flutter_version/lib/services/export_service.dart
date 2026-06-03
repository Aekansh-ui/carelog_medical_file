import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/database.dart';

/// Exports all CareLog data (members, visits, reminders, insurance) as a
/// styled PDF, then shares it via the platform share sheet.
///
/// The RN exportService only exported a single visit; this Flutter version
/// exports the full dataset as specified in §9 of the Flutter PRD.
class ExportService {
  static final _primary = PdfColor.fromHex('#1A6B8A');
  static final _textSecondary = PdfColor.fromHex('#6B7280');
  static final _border = PdfColor.fromHex('#ECEFF3');

  Future<void> exportAllData(AppDatabase db) async {
    // Query all tables — sort in Dart to avoid importing drift query helpers.
    final members = await db.select(db.members).get();
    final visits = await db.select(db.visits).get();
    visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    final reminders = await db.select(db.reminders).get();
    final activeReminders = reminders
        .where((r) => r.isActive == 1)
        .toList()
      ..sort((a, b) => a.followUpDate.compareTo(b.followUpDate));

    final policies = await db.select(db.insurancePolicies).get();
    policies.sort((a, b) {
      if (a.validUntil == null && b.validUntil == null) return 0;
      if (a.validUntil == null) return 1;
      if (b.validUntil == null) return -1;
      return a.validUntil!.compareTo(b.validUntil!);
    });

    final documents = await db.select(db.insuranceDocuments).get();

    // Build lookup maps.
    final membersMap = {for (final m in members) m.id: m};
    final visitsMap = {for (final v in visits) v.id: v};
    final docCountByPolicy = <String, int>{};
    for (final doc in documents) {
      docCountByPolicy[doc.policyId] = (docCountByPolicy[doc.policyId] ?? 0) + 1;
    }
    final visitCountByMember = <String, int>{};
    for (final v in visits) {
      if (v.memberId != null) {
        visitCountByMember[v.memberId!] =
            (visitCountByMember[v.memberId!] ?? 0) + 1;
      }
    }

    final doc = pw.Document(title: 'CareLog Health Records Export');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        header: (_) => _header(),
        footer: (ctx) => _footer(ctx),
        build: (_) => [
          _summarySection(
              members.length, visits.length, activeReminders.length, policies.length),
          pw.SizedBox(height: 20),
          _membersSection(members, visitCountByMember),
          pw.SizedBox(height: 20),
          _visitsSection(visits, membersMap),
          pw.SizedBox(height: 20),
          _remindersSection(activeReminders, visitsMap, membersMap),
          pw.SizedBox(height: 20),
          _insuranceSection(policies, membersMap, docCountByPolicy),
        ],
      ),
    );

    final bytes = await doc.save();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'CareLog_export_$stamp.pdf',
    );
  }

  // ---------------------------------------------------------------------------
  // Page header / footer
  // ---------------------------------------------------------------------------

  pw.Widget _header() {
    return pw.Container(
      decoration: pw.BoxDecoration(color: _primary),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'CareLog — Health Records Export',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
            style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _footer(pw.Context ctx) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'CareLog v1.0 — Offline Health Record',
          style: pw.TextStyle(color: PdfColors.grey, fontSize: 9),
        ),
        pw.Text(
          'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
          style: pw.TextStyle(color: PdfColors.grey, fontSize: 9),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------

  pw.Widget _summarySection(int numMembers, int numVisits, int numReminders, int numPolicies) {
    return _section('Summary', [
      _keyValueRow('Family Members', '$numMembers'),
      _keyValueRow('Total Visits', '$numVisits'),
      _keyValueRow('Active Reminders', '$numReminders'),
      _keyValueRow('Insurance Policies', '$numPolicies'),
    ]);
  }

  pw.Widget _membersSection(List<Member> members, Map<String, int> visitCounts) {
    if (members.isEmpty) {
      return _section('Family Members', [_empty('No members.')]);
    }
    return _section(
      'Family Members (${members.length})',
      members.map((m) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Row(
            children: [
              pw.Container(
                width: 9,
                height: 9,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex(m.color),
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Expanded(
                child: pw.Text(
                  '${m.name}  ·  ${m.relationship}',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Text(
                '${visitCounts[m.id] ?? 0} visits',
                style: pw.TextStyle(color: _textSecondary, fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _visitsSection(List<Visit> visits, Map<String, Member> members) {
    if (visits.isEmpty) {
      return _section('Visits', [_empty('No visits recorded.')]);
    }
    return _section(
      'Visits (${visits.length})',
      visits.map((v) {
        final memberName = v.memberId != null ? members[v.memberId!]?.name : null;
        return _card([
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                v.visitDate,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              if (memberName != null)
                pw.Text(memberName,
                    style: pw.TextStyle(color: _textSecondary, fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            [
              v.specialityId,
              if (v.doctorName != null) v.doctorName!,
              if (v.clinicName != null) v.clinicName!,
            ].join(' · '),
            style: pw.TextStyle(fontSize: 10),
          ),
          if (v.diagnosis != null && v.diagnosis!.isNotEmpty)
            pw.Text('Dx: ${v.diagnosis}',
                style: pw.TextStyle(color: _textSecondary, fontSize: 10)),
          if (v.followUpDate != null)
            pw.Text('Follow-up: ${v.followUpDate}',
                style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#E67E22'))),
        ]);
      }).toList(),
    );
  }

  pw.Widget _remindersSection(
    List<Reminder> reminders,
    Map<String, Visit> visits,
    Map<String, Member> members,
  ) {
    if (reminders.isEmpty) {
      return _section('Active Reminders', [_empty('No active reminders.')]);
    }
    return _section(
      'Active Reminders (${reminders.length})',
      reminders.map((r) {
        final visit = visits[r.visitId];
        final memberName =
            (visit?.memberId != null) ? members[visit!.memberId!]?.name : null;
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  r.followUpDate,
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                ),
              ),
              if (memberName != null)
                pw.Text(memberName,
                    style: pw.TextStyle(color: _textSecondary, fontSize: 10)),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _insuranceSection(
    List<InsurancePolicy> policies,
    Map<String, Member> members,
    Map<String, int> docCounts,
  ) {
    if (policies.isEmpty) {
      return _section('Insurance Policies', [_empty('No policies recorded.')]);
    }
    return _section(
      'Insurance Policies (${policies.length})',
      policies.map((pol) {
        final memberName = members[pol.memberId]?.name;
        return _card([
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  pol.insurerName,
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                ),
              ),
              if (memberName != null)
                pw.Text(memberName,
                    style: pw.TextStyle(color: _textSecondary, fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            [
              pol.planType,
              if (pol.policyNumber != null) '# ${pol.policyNumber}',
            ].join(' · '),
            style: pw.TextStyle(fontSize: 10),
          ),
          if (pol.validUntil != null)
            pw.Text(
              'Valid: ${pol.validFrom ?? 'N/A'} → ${pol.validUntil}',
              style: pw.TextStyle(color: _textSecondary, fontSize: 10),
            ),
          pw.Text(
            '${docCounts[pol.id] ?? 0} document(s)',
            style: pw.TextStyle(fontSize: 10),
          ),
        ]);
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Layout helpers
  // ---------------------------------------------------------------------------

  pw.Widget _section(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: _primary,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        ...children,
      ],
    );
  }

  pw.Widget _keyValueRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(label,
                style: pw.TextStyle(color: _textSecondary, fontSize: 11)),
          ),
          pw.Text(value, style: pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _card(List<pw.Widget> children) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  pw.Widget _empty(String message) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(message, style: pw.TextStyle(color: _textSecondary, fontSize: 11)),
    );
  }
}

final exportService = ExportService();
