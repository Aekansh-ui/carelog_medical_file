import React, {
  useState, useRef, forwardRef, useImperativeHandle,
} from 'react';
import {
  View, ScrollView, StyleSheet, Alert, Modal, Pressable, Image, Dimensions, Linking,
} from 'react-native';
import { List, TextInput, Text, Divider, SegmentedButtons } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import * as ImagePicker from 'expo-image-picker';
import * as DocumentPicker from 'expo-document-picker';
import { fileService } from '@src/services/fileService';
import { CreateInsuranceInput, InsuranceDocument } from '@src/types/Insurance';
import { PLAN_TYPES, PlanType } from '@src/constants/insurance';
import { AttachmentThumbnail } from './AttachmentThumbnail';
import { Colors, Spacing, BorderRadius } from '@src/utils/theme';

// ─── Public types ─────────────────────────────────────────────────────────────

export interface DraftDoc {
  id: string;
  uri: string;
  mimeType: string;
}

export interface InsuranceFormHandle {
  getForm: () => Partial<CreateInsuranceInput>;
  getDraftDocs: () => DraftDoc[];
}

interface InsuranceFormProps {
  initialForm?: Partial<CreateInsuranceInput>;
  existingDocs?: InsuranceDocument[];
  onDeleteExisting?: (doc: InsuranceDocument) => void;
  // Rendered at the bottom of the form's own ScrollView (e.g. a delete button on edit).
  footer?: React.ReactNode;
}

type SectionKey = 'policy' | 'coverage' | 'contact' | 'documents';

const { width: SCREEN_W, height: SCREEN_H } = Dimensions.get('window');
const MAX_DOCS = 6;

// ─── Document viewer ────────────────────────────────────────────────────────

function DocViewer({ doc, onClose }: { doc: InsuranceDocument | null; onClose: () => void }) {
  if (!doc) return null;
  const isPdf = doc.mime_type === 'application/pdf';
  const uri = doc.file_path.startsWith('file://') ? doc.file_path : `file://${doc.file_path}`;

  return (
    <Modal visible animationType="fade" statusBarTranslucent onRequestClose={onClose}>
      <View style={viewerStyles.container}>
        <SafeAreaView style={viewerStyles.topBar} edges={['top', 'left', 'right']}>
          <Pressable onPress={onClose} style={viewerStyles.closeBtn} hitSlop={8}>
            <MaterialCommunityIcons name="close" size={26} color="#FFF" />
          </Pressable>
          <Text style={viewerStyles.fileName} numberOfLines={1}>{doc.file_name}</Text>
          <View style={viewerStyles.closeBtn} />
        </SafeAreaView>

        {isPdf ? (
          <View style={viewerStyles.pdfFallback}>
            <MaterialCommunityIcons name="file-pdf-box" size={80} color={Colors.error} />
            <Text style={viewerStyles.pdfName}>{doc.file_name}</Text>
            <Pressable
              style={viewerStyles.openBtn}
              onPress={() =>
                Linking.openURL(uri).catch(() =>
                  Alert.alert('Cannot open', 'No PDF viewer found on this device.'),
                )
              }
            >
              <Text style={viewerStyles.openBtnText}>Open with System Viewer</Text>
            </Pressable>
          </View>
        ) : (
          <ScrollView
            contentContainerStyle={viewerStyles.imgScroll}
            maximumZoomScale={4}
            minimumZoomScale={1}
            bouncesZoom
            centerContent
            showsVerticalScrollIndicator={false}
          >
            <Image source={{ uri }} style={viewerStyles.image} resizeMode="contain" />
          </ScrollView>
        )}
      </View>
    </Modal>
  );
}

// ─── InsuranceForm ────────────────────────────────────────────────────────────

export const InsuranceForm = forwardRef<InsuranceFormHandle, InsuranceFormProps>(
  ({ initialForm = {}, existingDocs = [], onDeleteExisting, footer }, ref) => {
    const [form, setForm] = useState<Partial<CreateInsuranceInput>>({
      plan_type: 'PERSONAL',
      currency: 'INR',
      ...initialForm,
    });
    const [draftDocs, setDraftDocs] = useState<DraftDoc[]>([]);
    const [open, setOpen] = useState<Record<SectionKey, boolean>>({
      policy: true, coverage: true, contact: false, documents: false,
    });
    const [viewerDoc, setViewerDoc] = useState<InsuranceDocument | null>(null);

    const formRef = useRef(form);
    const draftRef = useRef(draftDocs);
    formRef.current = form;
    draftRef.current = draftDocs;

    useImperativeHandle(ref, () => ({
      getForm: () => formRef.current,
      getDraftDocs: () => draftRef.current,
    }), []);

    const currencyPrefix = form.currency === 'USD' ? '$' : '₹';
    const totalDocs = existingDocs.length + draftDocs.length;

    function update(key: keyof CreateInsuranceInput, value: string | number | undefined) {
      setForm(f => ({ ...f, [key]: value }));
    }

    function toggleSection(key: SectionKey) {
      setOpen(prev => ({ ...prev, [key]: !prev[key] }));
    }

    function pickDocument() {
      if (totalDocs >= MAX_DOCS) {
        Alert.alert('Limit reached', `You can attach up to ${MAX_DOCS} documents per policy.`);
        return;
      }
      Alert.alert('Add Document', 'Insurance card or policy PDF', [
        {
          text: 'Take Photo',
          onPress: async () => {
            const perm = await ImagePicker.requestCameraPermissionsAsync();
            if (!perm.granted) { Alert.alert('Permission Required', 'Camera access is needed.'); return; }
            const res = await ImagePicker.launchCameraAsync({ quality: 0.9 });
            if (!res.canceled && res.assets[0]) await addImageDraft(res.assets[0].uri);
          },
        },
        {
          text: 'Choose from Gallery',
          onPress: async () => {
            const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
            if (!perm.granted) { Alert.alert('Permission Required', 'Gallery access is needed.'); return; }
            const res = await ImagePicker.launchImageLibraryAsync({ quality: 0.9 });
            if (!res.canceled && res.assets[0]) await addImageDraft(res.assets[0].uri);
          },
        },
        {
          text: 'Choose PDF',
          onPress: async () => {
            const res = await DocumentPicker.getDocumentAsync({ type: 'application/pdf' });
            if (!res.canceled && res.assets[0]) addDraft(res.assets[0].uri, 'application/pdf');
          },
        },
        { text: 'Cancel', style: 'cancel' },
      ]);
    }

    async function addImageDraft(uri: string) {
      try {
        const compressed = await fileService.compressImage(uri);
        addDraft(compressed, 'image/jpeg');
      } catch {
        addDraft(uri, 'image/jpeg');
      }
    }

    function addDraft(uri: string, mimeType: string) {
      setDraftDocs(prev => [...prev, { id: `draft_${Date.now()}`, uri, mimeType }]);
    }

    function draftToDoc(d: DraftDoc): InsuranceDocument {
      return {
        id: d.id,
        policy_id: 'draft',
        file_path: d.uri,
        file_name: 'document_draft',
        mime_type: d.mimeType,
        size_bytes: 0,
        thumbnail_path: d.mimeType.startsWith('image/') ? d.uri : undefined,
        created_at: '',
      };
    }

    function handleDeleteDoc(doc: InsuranceDocument) {
      if (doc.id.startsWith('draft_')) {
        setDraftDocs(prev => prev.filter(d => d.id !== doc.id));
      } else {
        onDeleteExisting?.(doc);
      }
    }

    const allDocs: InsuranceDocument[] = [...existingDocs, ...draftDocs.map(draftToDoc)];

    return (
      <>
        <ScrollView
          contentContainerStyle={styles.form}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* ── Policy Details ─────────────────────────────────────── */}
          <List.Accordion
            title="Policy Details"
            expanded={open.policy}
            onPress={() => toggleSection('policy')}
            style={styles.accordion}
            titleStyle={styles.accordionTitle}
            left={p => <List.Icon {...p} icon="shield-check" color={Colors.primary} />}
          >
            <View style={styles.sectionBody}>
              <TextInput
                label="Insurer Name *"
                value={form.insurer_name ?? ''}
                onChangeText={v => update('insurer_name', v || undefined)}
                style={styles.input}
                right={<TextInput.Icon icon="domain" />}
              />

              <Text style={styles.fieldLabel}>Plan Type</Text>
              <ScrollView
                horizontal
                showsHorizontalScrollIndicator={false}
                contentContainerStyle={styles.chipRow}
              >
                {PLAN_TYPES.map(p => {
                  const active = form.plan_type === p.id;
                  return (
                    <Pressable
                      key={p.id}
                      onPress={() => update('plan_type', p.id as PlanType)}
                      style={[styles.chip, active && styles.chipActive]}
                    >
                      <MaterialCommunityIcons
                        name={p.icon as any}
                        size={14}
                        color={active ? '#FFF' : Colors.primary}
                      />
                      <Text style={[styles.chipText, active && styles.chipTextActive]}>{p.label}</Text>
                    </Pressable>
                  );
                })}
              </ScrollView>

              <TextInput
                label="Policy Number"
                value={form.policy_number ?? ''}
                onChangeText={v => update('policy_number', v || undefined)}
                style={styles.input}
                autoCapitalize="characters"
                right={<TextInput.Icon icon="pound" />}
              />
              <TextInput
                label="Policy Holder Name"
                value={form.policy_holder ?? ''}
                onChangeText={v => update('policy_holder', v || undefined)}
                style={styles.input}
                autoCapitalize="words"
                right={<TextInput.Icon icon="account" />}
              />
            </View>
          </List.Accordion>

          <Divider />

          {/* ── Coverage & Dates ───────────────────────────────────── */}
          <List.Accordion
            title="Coverage & Validity"
            expanded={open.coverage}
            onPress={() => toggleSection('coverage')}
            style={styles.accordion}
            titleStyle={styles.accordionTitle}
            left={p => <List.Icon {...p} icon="cash-multiple" color={Colors.primary} />}
          >
            <View style={styles.sectionBody}>
              <Text style={styles.fieldLabel}>Currency</Text>
              <SegmentedButtons
                value={form.currency ?? 'INR'}
                onValueChange={v => update('currency', v)}
                buttons={[
                  { value: 'INR', label: '₹ INR' },
                  { value: 'USD', label: '$ USD' },
                ]}
                style={styles.segment}
              />
              <TextInput
                label="Sum Insured / Coverage"
                value={form.sum_insured != null ? String(form.sum_insured) : ''}
                onChangeText={v => update('sum_insured', v ? parseFloat(v) : undefined)}
                keyboardType="numeric"
                style={styles.input}
                left={<TextInput.Affix text={currencyPrefix} />}
              />
              <TextInput
                label="Premium"
                value={form.premium != null ? String(form.premium) : ''}
                onChangeText={v => update('premium', v ? parseFloat(v) : undefined)}
                keyboardType="numeric"
                style={styles.input}
                left={<TextInput.Affix text={currencyPrefix} />}
              />
              <TextInput
                label="Valid From"
                value={form.valid_from ?? ''}
                onChangeText={v => update('valid_from', v || undefined)}
                placeholder="YYYY-MM-DD"
                style={styles.input}
                autoCapitalize="none"
                keyboardType="numbers-and-punctuation"
                right={<TextInput.Icon icon="calendar" />}
              />
              <TextInput
                label="Valid Until (Expiry)"
                value={form.valid_until ?? ''}
                onChangeText={v => update('valid_until', v || undefined)}
                placeholder="YYYY-MM-DD"
                style={styles.input}
                autoCapitalize="none"
                keyboardType="numbers-and-punctuation"
                right={<TextInput.Icon icon="calendar-alert" />}
              />
            </View>
          </List.Accordion>

          <Divider />

          {/* ── Contact & Notes ────────────────────────────────────── */}
          <List.Accordion
            title="Contact & Notes"
            expanded={open.contact}
            onPress={() => toggleSection('contact')}
            style={styles.accordion}
            titleStyle={styles.accordionTitle}
            left={p => <List.Icon {...p} icon="phone" color={Colors.primary} />}
          >
            <View style={styles.sectionBody}>
              <TextInput
                label="Helpline / TPA Phone"
                value={form.helpline_phone ?? ''}
                onChangeText={v => update('helpline_phone', v || undefined)}
                keyboardType="phone-pad"
                style={styles.input}
                right={<TextInput.Icon icon="phone" />}
              />
              <TextInput
                label="Agent Name"
                value={form.agent_name ?? ''}
                onChangeText={v => update('agent_name', v || undefined)}
                style={styles.input}
                autoCapitalize="words"
                right={<TextInput.Icon icon="account-tie" />}
              />
              <TextInput
                label="Notes"
                value={form.notes ?? ''}
                onChangeText={v => update('notes', v.slice(0, 1000) || undefined)}
                multiline
                numberOfLines={4}
                style={styles.input}
                maxLength={1000}
              />
              <Text style={styles.charCount}>{form.notes?.length ?? 0} / 1000</Text>
            </View>
          </List.Accordion>

          <Divider />

          {/* ── Documents ──────────────────────────────────────────── */}
          <List.Accordion
            title={`Documents${totalDocs ? ` (${totalDocs})` : ''}`}
            expanded={open.documents}
            onPress={() => toggleSection('documents')}
            style={styles.accordion}
            titleStyle={styles.accordionTitle}
            left={p => <List.Icon {...p} icon="card-account-details-outline" color={Colors.primary} />}
          >
            <View style={styles.sectionBody}>
              <Text style={styles.docHint}>
                Attach the insurance card (front/back) or the policy PDF.
              </Text>
              <View style={styles.docGrid}>
                {allDocs.map(doc => (
                  <AttachmentThumbnail
                    key={doc.id}
                    attachment={doc as any}
                    onPress={() => setViewerDoc(doc)}
                    onDelete={() => handleDeleteDoc(doc)}
                    size={88}
                  />
                ))}
                {totalDocs < MAX_DOCS ? (
                  <Pressable onPress={pickDocument} style={styles.addCard}>
                    <MaterialCommunityIcons name="plus" size={26} color={Colors.primary} />
                    <Text style={styles.addLabel}>Add</Text>
                  </Pressable>
                ) : null}
              </View>
            </View>
          </List.Accordion>

          {footer}
        </ScrollView>

        <DocViewer doc={viewerDoc} onClose={() => setViewerDoc(null)} />
      </>
    );
  },
);

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  form: {
    paddingBottom: Spacing.xxl,
  },
  accordion: {
    backgroundColor: Colors.surface,
  },
  accordionTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: Colors.textPrimary,
  },
  sectionBody: {
    backgroundColor: Colors.background,
    paddingTop: Spacing.xs,
    paddingBottom: Spacing.sm,
  },
  input: {
    marginHorizontal: Spacing.md,
    marginBottom: Spacing.sm,
    backgroundColor: Colors.surface,
  },
  fieldLabel: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginHorizontal: Spacing.md,
    marginBottom: Spacing.xs,
    fontWeight: '600',
  },
  segment: {
    marginHorizontal: Spacing.md,
    marginBottom: Spacing.sm,
  },
  charCount: {
    fontSize: 11,
    color: Colors.textSecondary,
    textAlign: 'right',
    marginRight: Spacing.md,
    marginTop: -Spacing.xs,
    marginBottom: Spacing.sm,
  },
  chipRow: {
    flexDirection: 'row',
    gap: Spacing.sm,
    paddingHorizontal: Spacing.md,
    paddingBottom: Spacing.sm,
  },
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 7,
    borderRadius: BorderRadius.full,
    borderWidth: 1.5,
    borderColor: Colors.primary,
    backgroundColor: Colors.surface,
  },
  chipActive: {
    backgroundColor: Colors.primary,
    borderColor: Colors.primary,
  },
  chipText: {
    fontSize: 13,
    color: Colors.primary,
    fontWeight: '500' as const,
  },
  chipTextActive: {
    color: '#FFF',
  },
  docHint: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginHorizontal: Spacing.md,
    marginBottom: Spacing.xs,
  },
  docGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: Spacing.md - 4,
    paddingTop: Spacing.xs,
  },
  addCard: {
    width: 88,
    height: 88,
    margin: 4,
    borderRadius: BorderRadius.sm,
    borderWidth: 1.5,
    borderColor: Colors.primary,
    borderStyle: 'dashed',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 2,
    backgroundColor: Colors.primary + '08',
  },
  addLabel: {
    fontSize: 10,
    color: Colors.primary,
    fontWeight: '500',
  },
});

const viewerStyles = StyleSheet.create({
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
    width: SCREEN_W,
    height: SCREEN_H,
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
  },
  openBtn: {
    marginTop: Spacing.md,
    backgroundColor: Colors.primary,
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.sm,
    borderRadius: BorderRadius.full,
  },
  openBtnText: {
    color: '#FFF',
    fontWeight: '600',
    fontSize: 14,
  },
});
