import React, { useEffect, useState, useCallback } from 'react';
import {
  View, ScrollView, StyleSheet, Alert, Linking, Modal, Image, Pressable, Dimensions,
} from 'react-native';
import { Text, Chip, Button, Divider } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Stack, router, useLocalSearchParams, useFocusEffect } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { insuranceRepository } from '@src/db/insuranceRepository';
import { useMemberStore } from '@src/store/memberStore';
import { InsuranceDocument, InsurancePolicy } from '@src/types/Insurance';
import { PLAN_TYPES, INSURANCE_EXPIRY_SOON_DAYS } from '@src/constants/insurance';
import { MemberBadge } from '@src/components/MemberBadge';
import { AttachmentThumbnail } from '@src/components/AttachmentThumbnail';
import { formatVisitDate, getExpiryStatus } from '@src/utils/dateUtils';
import { formatCurrency } from '@src/utils/formatters';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';

const { width: SCREEN_W, height: SCREEN_H } = Dimensions.get('window');

// ─── Document viewer ────────────────────────────────────────────────────────

function DocViewer({ doc, onClose }: { doc: InsuranceDocument | null; onClose: () => void }) {
  if (!doc) return null;
  const isPdf = doc.mime_type === 'application/pdf';
  const uri = doc.file_path.startsWith('file://') ? doc.file_path : `file://${doc.file_path}`;

  return (
    <Modal visible animationType="fade" statusBarTranslucent onRequestClose={onClose}>
      <View style={viewer.container}>
        <SafeAreaView style={viewer.topBar} edges={['top', 'left', 'right']}>
          <Pressable onPress={onClose} style={viewer.closeBtn} hitSlop={8}>
            <MaterialCommunityIcons name="close" size={26} color="#FFF" />
          </Pressable>
          <Text style={viewer.fileName} numberOfLines={1}>{doc.file_name}</Text>
          <View style={viewer.closeBtn} />
        </SafeAreaView>

        {isPdf ? (
          <View style={viewer.pdfFallback}>
            <MaterialCommunityIcons name="file-pdf-box" size={80} color={Colors.error} />
            <Text style={viewer.pdfName}>{doc.file_name}</Text>
            <Button
              mode="contained"
              style={{ marginTop: Spacing.md }}
              onPress={() =>
                Linking.openURL(uri).catch(() =>
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
            <Image source={{ uri }} style={viewer.image} resizeMode="contain" />
          </ScrollView>
        )}
      </View>
    </Modal>
  );
}

// ─── InfoRow / SectionCard ──────────────────────────────────────────────────

function InfoRow({ icon, label, value }: { icon: string; label: string; value?: string | number | null }) {
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

function SectionCard({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <View style={styles.sectionCard}>
      <Text style={styles.sectionTitle}>{title}</Text>
      {children}
    </View>
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────

export default function InsuranceDetailScreen() {
  const { policyId } = useLocalSearchParams<{ policyId: string }>();
  const members = useMemberStore(s => s.members);
  const loadMembers = useMemberStore(s => s.loadMembers);
  const getMember = useMemberStore(s => s.getMember);

  const [policy, setPolicy] = useState<InsurancePolicy | null>(null);
  const [docs, setDocs] = useState<InsuranceDocument[]>([]);
  const [viewerDoc, setViewerDoc] = useState<InsuranceDocument | null>(null);

  // Reload on focus so edits made on the edit screen are reflected on return.
  useFocusEffect(
    useCallback(() => {
      if (members.length === 0) loadMembers();
      setPolicy(insuranceRepository.findById(policyId));
      setDocs(insuranceRepository.findDocuments(policyId));
    }, [policyId])
  );

  const plan = policy ? PLAN_TYPES.find(p => p.id === policy.plan_type) : undefined;
  const member = policy ? getMember(policy.member_id) : undefined;
  const expiry = getExpiryStatus(policy?.valid_until, INSURANCE_EXPIRY_SOON_DAYS);
  const expiryColor =
    expiry.status === 'expired'
      ? Colors.error
      : expiry.status === 'expiring'
        ? Colors.accent
        : Colors.secondary;

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right', 'bottom']}>
      <Stack.Screen
        options={{
          title: policy?.insurer_name ?? 'Insurance',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
          headerRight: policy
            ? () => (
                <Pressable
                  onPress={() => router.push(`/insurance/edit/${policyId}`)}
                  style={styles.headerBtn}
                  hitSlop={8}
                >
                  <MaterialCommunityIcons name="pencil" size={22} color="#FFF" />
                </Pressable>
              )
            : undefined,
        }}
      />

      {!policy ? (
        <View style={styles.centered}>
          <MaterialCommunityIcons name="alert-circle-outline" size={48} color={Colors.textDisabled} />
          <Text style={styles.notFound}>Policy not found</Text>
        </View>
      ) : (
        <>
          <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
            {/* ── Header: plan + member + expiry ─── */}
            <View style={[styles.headerCard, Shadow.card]}>
              <View style={styles.chips}>
                {plan ? (
                  <Chip
                    style={styles.chip}
                    textStyle={{ fontSize: 12 }}
                    icon={() => <MaterialCommunityIcons name={plan.icon as any} size={14} color={Colors.primary} />}
                  >
                    {plan.label}
                  </Chip>
                ) : null}
                {member ? <MemberBadge name={member.name} color={member.color} /> : null}
              </View>

              {expiry.status !== 'none' ? (
                <View style={[styles.expiryBadge, { backgroundColor: expiryColor + '18' }]}>
                  <MaterialCommunityIcons
                    name={expiry.status === 'expired' ? 'alert' : 'shield-check'}
                    size={14}
                    color={expiryColor}
                  />
                  <Text style={[styles.expiryText, { color: expiryColor }]}>{expiry.label}</Text>
                </View>
              ) : null}
            </View>

            {/* ── Policy ─── */}
            <Divider />
            <SectionCard title="Policy">
              <InfoRow icon="domain" label="Insurer" value={policy.insurer_name} />
              <InfoRow icon="pound" label="Policy Number" value={policy.policy_number} />
              <InfoRow icon="account" label="Policy Holder" value={policy.policy_holder} />
            </SectionCard>

            {/* ── Coverage ─── */}
            {(policy.sum_insured != null || policy.premium != null || policy.valid_from || policy.valid_until) && (
              <>
                <Divider />
                <SectionCard title="Coverage & Validity">
                  {policy.sum_insured != null && (
                    <InfoRow icon="shield-check" label="Sum Insured" value={formatCurrency(policy.sum_insured, policy.currency)} />
                  )}
                  {policy.premium != null && (
                    <InfoRow icon="cash" label="Premium" value={formatCurrency(policy.premium, policy.currency)} />
                  )}
                  {policy.valid_from && (
                    <InfoRow icon="calendar-start" label="Valid From" value={formatVisitDate(policy.valid_from)} />
                  )}
                  {policy.valid_until && (
                    <InfoRow icon="calendar-end" label="Valid Until" value={formatVisitDate(policy.valid_until)} />
                  )}
                </SectionCard>
              </>
            )}

            {/* ── Contact ─── */}
            {(policy.helpline_phone || policy.agent_name) && (
              <>
                <Divider />
                <SectionCard title="Contact">
                  {policy.helpline_phone ? (
                    <View style={styles.infoRow}>
                      <MaterialCommunityIcons name="phone" size={16} color={Colors.textSecondary} />
                      <View style={[styles.infoText, styles.phoneRow]}>
                        <View>
                          <Text style={styles.infoLabel}>Helpline</Text>
                          <Text style={styles.infoValue}>{policy.helpline_phone}</Text>
                        </View>
                        <Button
                          mode="contained-tonal"
                          compact
                          icon="phone"
                          onPress={() => Linking.openURL(`tel:${policy.helpline_phone}`)}
                        >
                          Call
                        </Button>
                      </View>
                    </View>
                  ) : null}
                  <InfoRow icon="account-tie" label="Agent" value={policy.agent_name} />
                </SectionCard>
              </>
            )}

            {/* ── Documents ─── */}
            {docs.length > 0 && (
              <>
                <Divider />
                <SectionCard title={`Documents (${docs.length})`}>
                  <View style={styles.docGrid}>
                    {docs.map(doc => (
                      <AttachmentThumbnail
                        key={doc.id}
                        attachment={doc as any}
                        onPress={() => setViewerDoc(doc)}
                        size={88}
                      />
                    ))}
                  </View>
                </SectionCard>
              </>
            )}

            {/* ── Notes ─── */}
            {policy.notes && (
              <>
                <Divider />
                <SectionCard title="Notes">
                  <Text style={styles.bodyText}>{policy.notes}</Text>
                </SectionCard>
              </>
            )}
          </ScrollView>

          <DocViewer doc={viewerDoc} onClose={() => setViewerDoc(null)} />
        </>
      )}
    </SafeAreaView>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  headerBtn: { paddingHorizontal: Spacing.sm },
  centered: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: Spacing.sm },
  notFound: { fontSize: 15, color: Colors.textSecondary },
  content: { paddingBottom: Spacing.xxl },
  headerCard: {
    backgroundColor: Colors.surface,
    padding: Spacing.md,
    gap: Spacing.sm,
    marginBottom: 1,
  },
  chips: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    gap: Spacing.xs,
  },
  chip: { minHeight: 32 },
  expiryBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    alignSelf: 'flex-start',
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 4,
  },
  expiryText: { fontSize: 12, fontWeight: '700' as const },
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
  infoRow: { flexDirection: 'row', alignItems: 'flex-start', gap: Spacing.sm },
  infoText: { flex: 1 },
  infoLabel: { fontSize: 11, color: Colors.textSecondary },
  infoValue: { fontSize: 14, color: Colors.textPrimary, marginTop: 1 },
  phoneRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  bodyText: { fontSize: 14, color: Colors.textPrimary, lineHeight: 22 },
  docGrid: { flexDirection: 'row', flexWrap: 'wrap', marginHorizontal: -4 },
});

const viewer = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.md,
    paddingBottom: Spacing.sm,
    backgroundColor: 'rgba(0,0,0,0.7)',
  },
  closeBtn: { width: 40, height: 40, alignItems: 'center', justifyContent: 'center' },
  fileName: { flex: 1, color: '#FFF', fontSize: 14, textAlign: 'center', marginHorizontal: Spacing.sm },
  imgScroll: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  image: { width: SCREEN_W, height: SCREEN_H },
  pdfFallback: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: Spacing.xl, gap: Spacing.sm },
  pdfName: { color: '#FFF', fontSize: 15, textAlign: 'center', marginTop: Spacing.sm },
});
