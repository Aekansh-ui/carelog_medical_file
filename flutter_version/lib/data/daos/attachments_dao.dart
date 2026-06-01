import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import '../../models/query_results.dart';

part 'attachments_dao.g.dart';

/// Mirrors `../carelog/src/db/attachmentsRepository.ts`.
@DriftAccessor(tables: [Attachments])
class AttachmentsDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentsDaoMixin {
  AttachmentsDao(super.db);
  static const _uuid = Uuid();

  Future<Attachment> add(AttachmentsCompanion input) async {
    final id = _uuid.v4();
    await into(attachments).insert(input.copyWith(
      id: Value(id),
      createdAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
    return (select(attachments)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<List<Attachment>> findByVisit(String visitId) =>
      (select(attachments)
            ..where((t) => t.visitId.equals(visitId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<int> countByVisit(String visitId) async {
    final c = attachments.id.count();
    final row = await (selectOnly(attachments)
          ..addColumns([c])
          ..where(attachments.visitId.equals(visitId)))
        .getSingle();
    return row.read(c) ?? 0;
  }

  /// Deletes one attachment, returning its file ref for disk cleanup.
  Future<FileRef?> deleteAttachment(String id) async {
    final a =
        await (select(attachments)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (a == null) return null;
    await (delete(attachments)..where((t) => t.id.equals(id))).go();
    return FileRef(a.filePath, a.thumbnailPath);
  }

  /// Most recent attachments across all visits (Reports recent grid).
  Future<List<Attachment>> recent(int limit) => (select(attachments)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(limit))
      .get();
}
