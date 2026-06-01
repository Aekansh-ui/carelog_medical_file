import React, { useEffect, useState } from 'react';
import {
  View, ScrollView, StyleSheet, Alert, Linking, Modal, Image,
  Pressable, Dimensions,
} from 'react-native';
import { Text, Chip, Button, Divider } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Stack, router, useLocalSearchParams } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useVisitsStore } from '@src/store/visitsStore';
import { useMemberStore } from '@src/store/memberStore';
import { attachmentsRepository } from '@src/db/attachmentsRepository';
import { fileService } from '@src/services/fileService';
import { Attachment } from '@src/types/Attachment';
import { SPECIALITIES } from '@src/constants/specialities';
import { BODY_PARTS } from '@src/constants/bodyParts';
import { AttachmentGrid } from '@src/components/AttachmentGrid';
import { MemberBadge } from '@src/components/MemberBadge';
import { formatVisitDate, formatDaysRemaining, isOverdue } from '@src/utils/dateUtils';
import { formatCurrency } from '@src/utils/formatters';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

// ─── Attachment viewer modal ───────────────────────────────────────────────

function AttachmentViewer({
  attachment,
  onClose,
}: {
  attachment: Attachment | null;
  onClose: () => void;
}) {
  if (!attachment) return null;
  const isPdf = attachment.mime_type === 'application/pdf';
  const fileUri = attachment.file_path.startsWith('file://')
    ? attachment.file_path
    : `file://${attachment.file_path}`;

  return (
    <Modal visible animationType="fade" statusBarTranslucent onRequestClose={onClose}>
      <View style={viewer.container}>
        <SafeAreaView style={viewer.topBar} edges={['top', 'left', 'right']}>
          <Pressable onPress={onClose} style={viewer.closeBtn} hitSlop={8}>
            <MaterialCommunityIcons name="close" size={26} color="#FFF" />
          </Pressable>
          <Text style={viewer.fileName} numberOfLines={1}>{attachment.file_name}</Text>
          <View style={viewer.closeBtn} />
        </SafeAreaView>

        {isPdf ? (
          <View style={viewer.pdfFallback}>
            <MaterialCommunityIcons name="file-pdf-box" size={80} color={Colors.error} />
            <Text style={viewer.pdfName}>{attachment.file_name}</Text>
            <Button
              mode="contained"
              style={{ marginTop: Spacing.md }}
              onPress={() =>
                Linking.openURL(fileUri).catch(() =>
                  Alert.alert('Cannot open', 'No PDF viewer found on this device.'),
                )
              }
            >
              Open with System Viewer
            </Button>
          </View>
        ) : (
          <ScrollView
            contentContainerStyle={viewer.imgScroll}
            maximumZoomScale={4}
            minimumZoomScale={1}
            bouncesZoom
            centerContent
            showsVerticalScrollIndicator={false}
          >
            <Image
              source={{ uri: fileUri }}
              style={viewer.image}
              resizeMode="contain"
            />
          </ScrollView>
        )}
      </View>
    </Modal>
  );
}

// ─── InfoRow ──────────────────────────────────────────────────────────────

function InfoRow({
  icon,
  label,
  value,
}: {
  icon: string;
  label: string;
  value?: string | number | null;
}) {
  if (value == null || value === '') return null;
  return (
    <View style={styles.infoRow}>
      <MaterialCommunityIcons name={icon as any} size={16} color={Colors.textSecondary} />
      <View style={styles.infoText}>
        <Text style={styles.infoLabel}>{label}</Text>
        <Text style={styles.infoValue}>{String(value)}</Text>
      </View>
    </View>
  );
}

// ─── SectionCard ─────────────────────────────────────────────────────────

function SectionCard({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <View style={styles.sectionCard}>
      <Text style={styles.sectionTitle}>{title}</Text>
      {children}
    </View>
  );
}

// ─── Main screen ──────────────────────────────────────────────────────────

export default function VisitDetailScreen() {
  const { visitId } = useLocalSearchParams<{ visitId: string }>();
  const selectedVisit = useVisitsStore(s => s.selectedVisit);
  const loadVisitById = useVisitsStore(s => s.loadVisitById);
  const deleteVisit = useVisitsStore(s => s.deleteVisit);
  const members = useMemberStore(s => s.members);
  const loadMembers = useMemberStore(s => s.loadMembers);
  const getMember = useMemberStore(s => s.getMember);
  const [attachments, setAttachments] = useState<Attachment[]>([]);
  const [viewerAtt, setViewerAtt] = useState<Attachment | null>(null);

  useEffect(() => {
    if (visitId) {
      loadVisitById(visitId);
      setAttachments(attachmentsRepository.findByVisitId(visitId));
      if (members.length === 0) loadMembers();
    }
  }, [visitId]);

  const visit = selectedVisit;
  const speciality = visit ? SPECIALITIES.find(s => s.id === visit.speciality_id) : undefined;
  const bodyPart = visit ? BODY_PARTS.find(b => b.id === visit.body_part_id) : undefined;
  const member = visit ? getMember(visit.member_id) : undefined;

  const prescriptions = attachments.filter(a => a.type === 'prescription');
  const medicines = attachments.filter(a => a.type === 'medicine');
  const bills = attachments.filter(a => a.type === 'bill');
  const reports = attachments.filter(a => a.type === 'report');

  async function handleDeleteAttachment(att: Attachment) {
    Alert.alert('Delete Attachment', `Delete "${att.file_name}"?`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        style: 'destructive',
        onPress: async () => {
          try { await fileService.deleteAttachment(att.file_path); } catch { /* file may already be gone */ }
          attachmentsRepository.delete(att.id);
          setAttachments(prev => prev.filter(a => a.id !== att.id));
        },
      },
    ]);
  }

  async function handleDeleteVisit() {
    Alert.alert(
      'Delete Visit',
      'This will permanently delete the visit and all its attachments. This cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            for (const att of attachments) {
              try { await fileService.deleteAttachment(att.file_path); } catch { /* ignore */ }
            }
            deleteVisit(visitId!);
            router.back();
          },
        },
      ],
    );
  }

  const followUpOverdue = visit?.follow_up_date ? isOverdue(visit.follow_up_date) : false;
  const followUpColor = followUpOverdue ? Colors.error : Colors.secondary;

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right', 'bottom']}>
      <Stack.Screen
        options={{
          title: visit?.doctor_name ?? 'Visit Detail',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
          headerRight: visit
            ? () => (
                <View style={styles.headerActions}>
                  <Pressable
                    onPress={() => router.push(`/visits/edit/${visitId}`)}
                    style={styles.headerBtn}
                    hitSlop={8}
                  >
                    <MaterialCommunityIcons name="pencil" size={22} color="#FFF" />
                  </Pressable>
                  <Pressable
                    onPress={handleDeleteVisit}
                    style={styles.headerBtn}
                    hitSlop={8}
                  >
                    <MaterialCommunityIcons name="delete-outline" size={22} color="#FFF" />
                  </Pressable>
                </View>
              )
            : undefined,
        }}
      />

      {!visit ? (
        <View style={styles.centered}>
          <MaterialCommunityIcons name="alert-circle-outline" size={48} color={Colors.textDisabled} />
          <Text style={styles.notFound}>Visit not found</Text>
        </View>
      ) : (
        <>
          <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>

            {/* ── Header: speciality + body part chips + dates ─── */}
            <View style={[styles.headerCard, Shadow.card]}>
              <View style={styles.chips}>
                {speciality && (
                  <Chip
                    style={[styles.chip, { backgroundColor: speciality.color + '22' }]}
                    textStyle={{ color: speciality.color, fontSize: 12 }}
                    icon={() => (
                      <MaterialCommunityIcons
                        name={speciality.icon as any}
                        size={14}
                        color={speciality.color}
                      />
                    )}
                  >
                    {speciality.label}
                  </Chip>
                )}
                {bodyPart && (
                  <Chip style={styles.chip} textStyle={{ fontSize: 12 }}>
                    {bodyPart.label}
                  </Chip>
                )}
                {member && (
                  <MemberBadge name={member.name} color={member.color} />
                )}
              </View>

              <InfoRow icon="calendar" label="Visit Date" value={formatVisitDate(visit.visit_date)} />

              {visit.follow_up_date && (
                <View style={styles.infoRow}>
                  <MaterialCommunityIcons name="calendar-clock" size={16} color={Colors.textSecondary} />
                  <View style={styles.infoText}>
                    <Text style={styles.infoLabel}>Follow-up</Text>
                    <View style={styles.followUpRow}>
                      <Text style={styles.infoValue}>
                        {formatVisitDate(visit.follow_up_date)}
                      </Text>
                      <View style={[styles.followUpBadge, { backgroundColor: followUpColor + '18' }]}>
                        <Text style={[styles.followUpText, { color: followUpColor }]}>
                          {formatDaysRemaining(visit.follow_up_date)}
                        </Text>
                      </View>
                    </View>
                  </View>
                </View>
              )}
            </View>

            {/* ── Doctor Details ─────────────────────────────────── */}
            {(visit.doctor_name || visit.clinic_name || visit.clinic_phone || visit.doctor_fees != null) && (
              <>
                <Divider />
                <SectionCard title="Doctor">
                  <InfoRow icon="doctor" label="Doctor" value={visit.doctor_name} />
                  <InfoRow icon="hospital-building" label="Clinic" value={visit.clinic_name} />
                  {visit.clinic_phone && (
                    <View style={styles.infoRow}>
                      <MaterialCommunityIcons name="phone" size={16} color={Colors.textSecondary} />
                      <View style={[styles.infoText, styles.phoneRow]}>
                        <View>
                          <Text style={styles.infoLabel}>Phone</Text>
                          <Text style={styles.infoValue}>{visit.clinic_phone}</Text>
                        </View>
                        <Button
                          mode="contained-tonal"
                          compact
                          icon="phone"
                          onPress={() => Linking.openURL(`tel:${visit.clinic_phone}`)}
                        >
                          Call
                        </Button>
                      </View>
                    </View>
                  )}
                  {visit.doctor_fees != null && (
                    <InfoRow
                      icon="currency-inr"
                      label="Fees"
                      value={formatCurrency(visit.doctor_fees, visit.currency)}
                    />
                  )}
                </SectionCard>
              </>
            )}

            {/* ── Symptoms ────────────────────────────────────────── */}
            {visit.symptoms && (
              <>
                <Divider />
                <SectionCard title="Symptoms">
                  <Text style={styles.bodyText}>{visit.symptoms}</Text>
                </SectionCard>
              </>
            )}

            {/* ── Diagnosis ───────────────────────────────────────── */}
            {visit.diagnosis && (
              <>
                <Divider />
                <SectionCard title="Diagnosis">
                  <Text style={styles.bodyText}>{visit.diagnosis}</Text>
                </SectionCard>
              </>
            )}

            {/* ── Prescriptions ───────────────────────────────────── */}
            {prescriptions.length > 0 && (
              <>
                <Divider />
                <SectionCard title={`Prescriptions (${prescriptions.length})`}>
                  <AttachmentGrid
                    attachments={prescriptions}
                    type="prescription"
                    onAdd={() => {}}
                    onDelete={id => {
                      const att = prescriptions.find(a => a.id === id);
                      if (att) handleDeleteAttachment(att);
                    }}
                    onView={att => setViewerAtt(att)}
                    maxFiles={0}
                  />
                </SectionCard>
              </>
            )}

            {/* ── Medicines ───────────────────────────────────────── */}
            {medicines.length > 0 && (
              <>
                <Divider />
                <SectionCard title={`Medicines (${medicines.length})`}>
                  <AttachmentGrid
                    attachments={medicines}
                    type="medicine"
                    onAdd={() => {}}
                    onDelete={id => {
                      const att = medicines.find(a => a.id === id);
                      if (att) handleDeleteAttachment(att);
                    }}
                    onView={att => setViewerAtt(att)}
                    maxFiles={0}
                  />
                </SectionCard>
              </>
            )}

            {/* ── Bills ───────────────────────────────────────────── */}
            {bills.length > 0 && (
              <>
                <Divider />
                <SectionCard title={`Bills (${bills.length})`}>
                  <AttachmentGrid
                    attachments={bills}
                    type="bill"
                    onAdd={() => {}}
                    onDelete={id => {
                      const att = bills.find(a => a.id === id);
                      if (att) handleDeleteAttachment(att);
                    }}
                    onView={att => setViewerAtt(att)}
                    maxFiles={0}
                  />
                </SectionCard>
              </>
            )}

            {/* ── Reports ─────────────────────────────────────────── */}
            {reports.length > 0 && (
              <>
                <Divider />
                <SectionCard title={`Reports (${reports.length})`}>
                  <AttachmentGrid
                    attachments={reports}
                    type="report"
                    onAdd={() => {}}
                    onDelete={id => {
                      const att = reports.find(a => a.id === id);
                      if (att) handleDeleteAttachment(att);
                    }}
                    onView={att => setViewerAtt(att)}
                    maxFiles={0}
                  />
                </SectionCard>
              </>
            )}

            {/* ── Notes ───────────────────────────────────────────── */}
            {visit.notes && (
              <>
                <Divider />
                <SectionCard title="Notes">
                  <Text style={styles.bodyText}>{visit.notes}</Text>
                </SectionCard>
              </>
            )}
          </ScrollView>

          {/* Full-screen attachment viewer */}
          <AttachmentViewer attachment={viewerAtt} onClose={() => setViewerAtt(null)} />
        </>
      )}
    </SafeAreaView>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  headerActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerBtn: {
    paddingHorizontal: Spacing.sm,
  },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: Spacing.sm,
  },
  notFound: {
    fontSize: 15,
    color: Colors.textSecondary,
  },
  content: {
    paddingBottom: Spacing.xxl,
  },
  headerCard: {
    backgroundColor: Colors.surface,
    padding: Spacing.md,
    gap: Spacing.sm,
    marginBottom: 1,
  },
  chips: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.xs,
    marginBottom: Spacing.xs,
  },
  chip: {
    height: 28,
  },
  followUpRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.sm,
    flexWrap: 'wrap',
  },
  followUpBadge: {
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
  },
  followUpText: {
    fontSize: 12,
    fontWeight: '700',
  },
  sectionCard: {
    backgroundColor: Colors.surface,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.md,
    gap: Spacing.sm,
  },
  sectionTitle: {
    fontSize: 11,
    fontWeight: '700',
    color: Colors.textSecondary,
    textTransform: 'uppercase',
    letterSpacing: 0.6,
    marginBottom: 2,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: Spacing.sm,
  },
  infoText: {
    flex: 1,
  },
  infoLabel: {
    fontSize: 11,
    color: Colors.textSecondary,
  },
  infoValue: {
    fontSize: 14,
    color: Colors.textPrimary,
    marginTop: 1,
  },
  phoneRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  bodyText: {
    fontSize: 14,
    color: Colors.textPrimary,
    lineHeight: 22,
  },
});

const viewer = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.md,
    paddingBottom: Spacing.sm,
    backgroundColor: 'rgba(0,0,0,0.7)',
  },
  closeBtn: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  fileName: {
    flex: 1,
    color: '#FFF',
    fontSize: 14,
    textAlign: 'center',
    marginHorizontal: Spacing.sm,
  },
  imgScroll: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  image: {
    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT,
  },
  pdfFallback: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: Spacing.xl,
    gap: Spacing.sm,
  },
  pdfName: {
    color: '#FFF',
    fontSize: 15,
    textAlign: 'center',
    marginTop: Spacing.sm,
  },
});
