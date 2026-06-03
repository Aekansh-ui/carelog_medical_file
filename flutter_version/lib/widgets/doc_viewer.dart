import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../data/database.dart';

/// Pushes a full-screen viewer for a visit [Attachment] above the GoRouter stack.
void showDocViewer(BuildContext context, Attachment attachment) =>
    _pushViewer(context, attachment.filePath, attachment.fileName,
        attachment.mimeType);

/// Pushes a full-screen viewer for an [InsuranceDocument] above the GoRouter stack.
void showInsuranceDocViewer(BuildContext context, InsuranceDocument doc) =>
    _pushViewer(context, doc.filePath, doc.fileName, doc.mimeType);

void _pushViewer(
    BuildContext context, String filePath, String fileName, String mimeType) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _DocViewerPage(
          filePath: filePath, fileName: fileName, mimeType: mimeType),
    ),
  );
}

class _DocViewerPage extends StatelessWidget {
  final String filePath;
  final String fileName;
  final String mimeType;
  const _DocViewerPage(
      {required this.filePath,
      required this.fileName,
      required this.mimeType});

  bool get _isPdf => mimeType == 'application/pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: Text(
          fileName,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: _isPdf ? _PdfView(filePath: filePath, fileName: fileName) : _ImageView(filePath: filePath),
    );
  }
}

// ── Image viewer ──────────────────────────────────────────────────────────────

class _ImageView extends StatelessWidget {
  final String filePath;
  const _ImageView({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: Image.file(
          File(filePath),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined, size: 64, color: Colors.white54),
              SizedBox(height: 12),
              Text('Cannot display image',
                  style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PDF view ──────────────────────────────────────────────────────────────────

class _PdfView extends StatelessWidget {
  final String filePath;
  final String fileName;
  const _PdfView({required this.filePath, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Color(0xFFE53935)),
            const SizedBox(height: 16),
            Text(
              fileName,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => OpenFilex.open(filePath),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open with System Viewer'),
            ),
          ],
        ),
      ),
    );
  }
}
