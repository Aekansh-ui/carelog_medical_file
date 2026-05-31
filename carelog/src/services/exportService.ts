import * as FileSystem from 'expo-file-system';
import RNHTMLtoPDF from 'react-native-html-to-pdf';
import { Visit } from '@src/types/Visit';
import { Attachment } from '@src/types/Attachment';
import { visitsRepository } from '@src/db/visitsRepository';
import { attachmentsRepository } from '@src/db/attachmentsRepository';
import { SPECIALITIES } from '@src/constants/specialities';
import { BODY_PARTS } from '@src/constants/bodyParts';
import { formatVisitDate, formatDaysRemaining } from '@src/utils/dateUtils';
import { formatCurrency } from '@src/utils/formatters';

function row(label: string, value: string | undefined | null): string {
  if (!value) return '';
  return `
    <tr>
      <td class="label">${label}</td>
      <td class="value">${value}</td>
    </tr>`;
}

function section(title: string, content: string): string {
  return `
    <div class="section">
      <h2>${title}</h2>
      ${content}
    </div>`;
}

function buildHTML(visit: Visit, attachments: Attachment[]): string {
  const speciality = SPECIALITIES.find(s => s.id === visit.speciality_id);
  const bodyPart = BODY_PARTS.find(b => b.id === visit.body_part_id);

  const prescriptions = attachments.filter(a => a.type === 'prescription');
  const medicines = attachments.filter(a => a.type === 'medicine');
  const bills = attachments.filter(a => a.type === 'bill');
  const reports = attachments.filter(a => a.type === 'report');

  const attachmentRows = (items: Attachment[]) =>
    items.map(a => `<li>${a.file_name} (${a.type})</li>`).join('');

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Visit Report — CareLog</title>
  <style>
    body {
      font-family: -apple-system, Helvetica, Arial, sans-serif;
      font-size: 14px;
      color: #212121;
      margin: 0;
      padding: 24px;
    }
    .header {
      background: #1A6B8A;
      color: white;
      padding: 16px 24px;
      margin: -24px -24px 24px;
    }
    .header h1 { margin: 0; font-size: 22px; }
    .header .meta { font-size: 12px; opacity: 0.85; margin-top: 4px; }
    .section { margin-bottom: 20px; border-bottom: 1px solid #E0E0E0; padding-bottom: 16px; }
    .section h2 { font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; color: #757575; margin: 0 0 8px; }
    table { width: 100%; border-collapse: collapse; }
    .label { width: 35%; color: #757575; font-size: 12px; padding: 4px 0; vertical-align: top; }
    .value { color: #212121; padding: 4px 0; }
    .body-text { line-height: 1.6; color: #212121; margin: 0; }
    ul { margin: 0; padding-left: 20px; }
    li { color: #212121; margin-bottom: 2px; }
    .badge {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 999px;
      font-size: 11px;
      font-weight: 600;
      background: #2E9E6B22;
      color: #2E9E6B;
    }
    .footer { font-size: 11px; color: #9E9E9E; text-align: center; margin-top: 32px; }
  </style>
</head>
<body>
  <div class="header">
    <h1>CareLog — Visit Report</h1>
    <div class="meta">Generated ${new Date().toLocaleString()}</div>
  </div>

  ${section('Visit Overview', `<table>
    ${row('Body Part', bodyPart?.label)}
    ${row('Speciality', speciality?.label)}
    ${row('Visit Date', formatVisitDate(visit.visit_date))}
    ${visit.follow_up_date ? row('Follow-up', `${formatVisitDate(visit.follow_up_date)} &nbsp; <span class="badge">${formatDaysRemaining(visit.follow_up_date)}</span>`) : ''}
  </table>`)}

  ${section('Doctor Details', `<table>
    ${row('Doctor', visit.doctor_name)}
    ${row('Clinic', visit.clinic_name)}
    ${row('Phone', visit.clinic_phone)}
    ${visit.doctor_fees != null ? row('Fees', formatCurrency(visit.doctor_fees, visit.currency)) : ''}
  </table>`)}

  ${visit.symptoms ? section('Symptoms', `<p class="body-text">${visit.symptoms}</p>`) : ''}

  ${visit.diagnosis ? section('Diagnosis', `<p class="body-text">${visit.diagnosis}</p>`) : ''}

  ${visit.notes ? section('Notes', `<p class="body-text">${visit.notes}</p>`) : ''}

  ${prescriptions.length > 0 ? section(`Prescriptions (${prescriptions.length})`, `<ul>${attachmentRows(prescriptions)}</ul>`) : ''}
  ${medicines.length > 0 ? section(`Medicines (${medicines.length})`, `<ul>${attachmentRows(medicines)}</ul>`) : ''}
  ${bills.length > 0 ? section(`Bills (${bills.length})`, `<ul>${attachmentRows(bills)}</ul>`) : ''}
  ${reports.length > 0 ? section(`Reports (${reports.length})`, `<ul>${attachmentRows(reports)}</ul>`) : ''}

  <div class="footer">CareLog v1.0.0 &mdash; Offline Health Record</div>
</body>
</html>`;
}

export const exportService = {
  /**
   * Generates a styled PDF for a single visit and returns the file path.
   */
  async exportVisitAsPDF(visit: Visit, attachments: Attachment[]): Promise<string> {
    const html = buildHTML(visit, attachments);
    const doctorSlug = (visit.doctor_name ?? 'visit').replace(/\s+/g, '_').toLowerCase();
    const dateSlug = visit.visit_date.replace(/-/g, '');
    const fileName = `CareLog_${doctorSlug}_${dateSlug}`;

    const result = await RNHTMLtoPDF.convert({
      html,
      fileName,
      directory: 'Documents',
    });

    if (!result.filePath) throw new Error('PDF generation failed — no file path returned');
    return result.filePath;
  },

  /**
   * Exports all visits and attachment metadata as a JSON file.
   */
  async exportAllData(): Promise<string> {
    const visits = visitsRepository.findRecent(10000);
    const attachments = attachmentsRepository.findAll();

    const payload = {
      exported_at: new Date().toISOString(),
      app: 'CareLog',
      version: '1.0.0',
      visits,
      attachments,
    };

    const exportPath = `${FileSystem.documentDirectory}CareLog_export_${Date.now()}.json`;
    await FileSystem.writeAsStringAsync(exportPath, JSON.stringify(payload, null, 2));
    return exportPath;
  },
};
