import '../data/database.dart';

/// DTOs for JOINed / aggregate queries that don't map to a single table row.
/// Plain table rows use Drift's generated classes (`Visit`, `Member`, …).

/// A reference to on-disk files for a deleted record, returned by cascade
/// deletes so the caller (fileService) can remove them from storage.
class FileRef {
  final String filePath;
  final String? thumbnailPath;
  const FileRef(this.filePath, this.thumbnailPath);
}

/// A visit plus its member's display fields (search results, where the badge
/// is shown). Mirrors the RN `Visit` joined fields `member_name`/`member_color`.
class VisitWithMember {
  final Visit visit;
  final String? memberName;
  final String? memberColor;
  const VisitWithMember({
    required this.visit,
    this.memberName,
    this.memberColor,
  });
}

/// A member plus the per-member stats shown on the Family Home dashboard.
class MemberWithStats {
  final Member member;
  final int visitCount;
  final String? lastVisitDate;
  final String? nextFollowUp;
  const MemberWithStats({
    required this.member,
    required this.visitCount,
    this.lastVisitDate,
    this.nextFollowUp,
  });
}

/// One upcoming follow-up row in the family summary.
class UpcomingFollowUp {
  final String visitId;
  final String memberId;
  final String memberName;
  final String? memberColor;
  final String specialityId;
  final String? doctorName;
  final String followUpDate;
  const UpcomingFollowUp({
    required this.visitId,
    required this.memberId,
    required this.memberName,
    this.memberColor,
    required this.specialityId,
    this.doctorName,
    required this.followUpDate,
  });
}

/// Family-wide totals + upcoming follow-ups for the Family Home header.
class FamilySummary {
  final int totalMembers;
  final int totalVisits;
  final List<UpcomingFollowUp> upcomingFollowUps;
  const FamilySummary({
    required this.totalMembers,
    required this.totalVisits,
    required this.upcomingFollowUps,
  });
}

/// A visit attachment joined to its visit and member (Reports grid — AC-F14).
class AttachmentWithVisit {
  final Attachment attachment;
  final String? visitId;
  final String? visitDate;
  final String? doctorName;
  final String? specialityId;
  final String? memberName;
  final String? memberColor;
  const AttachmentWithVisit({
    required this.attachment,
    this.visitId,
    this.visitDate,
    this.doctorName,
    this.specialityId,
    this.memberName,
    this.memberColor,
  });
}

/// A reminder row joined to its visit and member — mirrors the RN Reminder type
/// which carries joined fields from the reminders × visits × members query.
class ReminderWithVisit {
  final Reminder reminder;
  final String? doctorName;
  final String? specialityId;
  final String? bodyPartId;
  final String? memberName;
  final String? memberColor;
  const ReminderWithVisit({
    required this.reminder,
    this.doctorName,
    this.specialityId,
    this.bodyPartId,
    this.memberName,
    this.memberColor,
  });
}

/// An insurance policy plus its attached-document count (list screen chip).
class PolicyWithDocCount {
  final InsurancePolicy policy;
  final int documentCount;
  const PolicyWithDocCount({
    required this.policy,
    required this.documentCount,
  });
}
