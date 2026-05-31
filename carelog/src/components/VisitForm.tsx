import React, {
  useState, useEffect, useRef, forwardRef, useImperativeHandle,
} from 'react';
import {
  View, ScrollView, StyleSheet, Alert, Modal, FlatList, Pressable,
  Image, Dimensions, Linking,
} from 'react-native';
import { List, TextInput, Text, Divider } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import * as ImagePicker from 'expo-image-picker';
import * as DocumentPicker from 'expo-document-picker';
import uuid from 'react-native-uuid';
import { useVisitsStore } from '@src/store/visitsStore';
import { getDb } from '@src/db/database';
import { fileService } from '@src/services/fileService';
import { SPECIALITIES } from '@src/constants/specialities';
import { BODY_PARTS } from '@src/constants/bodyParts';
import { CreateVisitInput } from '@src/types/Visit';
import { Attachment, AttachmentType, ATTACHMENT_LIMITS } from '@src/types/Attachment';
import { AttachmentGrid } from './AttachmentGrid';
import { today } from '@src/utils/dateUtils';
import { Colors, Spacing, BorderRadius } from '@src/utils/theme';

// ─── Public types ─────────────────────────────────────────────────────────────

export interface DraftAttachment {
  id: string;
  uri: string;
  type: AttachmentType;
  mimeType: string;
}

export interface VisitFormHandle {
  getForm: () => Partial<CreateVisitInput>;
  getDraftAttachments: () => DraftAttachment[];
  getDraftId: () => string;
}

interface VisitFormProps {
  initialForm?: Partial<CreateVisitInput>;
  existingAttachments?: Attachment[];
  onDeleteExisting?: (att: Attachment) => void;
}

type SectionKey = 'visitInfo' | 'doctor' | 'diagnosis' | 'attachments' | 'notes';

const { width: SCREEN_W, height: SCREEN_H } = Dimensions.get('window');

// ─── Attachment viewer modal ───────────────────────────────────────────────

function Viewer({ attachment, onClose }: { attachment: Attachment | null; onClose: () => void }) {
  if (!attachment) return null;
  const isPdf = attachment.mime_type === 'application/pdf';
  const uri = attachment.file_path.startsWith('file://')
    ? attachment.file_path
    : `file://${attachment.file_path}`;

  return (
    <Modal visible animationType="fade" statusBarTranslucent onRequestClose={onClose}>
      <View style={viewerStyles.container}>
        <SafeAreaView style={viewerStyles.topBar} edges={['top', 'left', 'right']}>
          <Pressable onPress={onClose} style={viewerStyles.closeBtn} hitSlop={8}>
            <MaterialCommunityIcons name="close" size={26} color="#FFF" />
          </Pressable>
          <Text style={viewerStyles.fileName} numberOfLines={1}>{attachment.file_name}</Text>
          <View style={viewerStyles.closeBtn} />
        </SafeAreaView>

        {isPdf ? (
          <View style={viewerStyles.pdfFallback}>
            <MaterialCommunityIcons name="file-pdf-box" size={80} color={Colors.error} />
            <Text style={viewerStyles.pdfName}>{attachment.file_name}</Text>
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

// ─── VisitForm ─────────────────────────────────────────────────────────────

export const VisitForm = forwardRef<VisitFormHandle, VisitFormProps>(
  ({ initialForm = {}, existingAttachments = [], onDeleteExisting }, ref) => {
    const getAutocompleteDoctors = useVisitsStore(s => s.getAutocompleteDoctors);
    const getAutocompleteClinics = useVisitsStore(s => s.getAutocompleteClinics);

    const [form, setForm] = useState<Partial<CreateVisitInput>>({
      visit_date: today(),
      currency: 'INR',
      ...initialForm,
    });
    const [draftAttachments, setDraftAttachments] = useState<DraftAttachment[]>([]);
    const [open, setOpen] = useState<Record<SectionKey, boolean>>({
      visitInfo: true, doctor: true, diagnosis: true, attachments: false, notes: false,
    });
    const [doctorSuggestions, setDoctorSuggestions] = useState<string[]>([]);
    const [clinicSuggestions, setClinicSuggestions] = useState<string[]>([]);
    const [showBodyPicker, setShowBodyPicker] = useState(false);
    const [showSpecPicker, setShowSpecPicker] = useState(false);
    const [viewerAtt, setViewerAtt] = useState<Attachment | null>(null);

    // Refs so the interval always reads latest state without being recreated
    const formRef = useRef(form);
    const draftRef = useRef(draftAttachments);
    useEffect(() => { formRef.current = form; }, [form]);
    useEffect(() => { draftRef.current = draftAttachments; }, [draftAttachments]);

    const draftId = useRef(uuid.v4() as string).current;

    useImperativeHandle(ref, () => ({
      getForm: () => formRef.current,
      getDraftAttachments: () => draftRef.current,
      getDraftId: () => draftId,
    }), []);

    // Auto-save draft every 30 s (best-effort)
    useEffect(() => {
      const interval = setInterval(() => {
        try {
          const now = new Date().toISOString();
          getDb().runSync(
            `INSERT OR REPLACE INTO visit_drafts (id, form_data, created_at, updated_at)
             VALUES (?, ?, ?, ?)`,
            [draftId, JSON.stringify(formRef.current), now, now],
          );
        } catch { /* table may not be ready yet */ }
      }, 30_000);
      return () => clearInterval(interval);
    }, []);

    const bodyPart = BODY_PARTS.find(b => b.id === form.body_part_id);
    const speciality = SPECIALITIES.find(s => s.id === form.speciality_id);
    const currencyPrefix = form.currency === 'USD' ? '$' : '₹';

    function update(key: keyof CreateVisitInput, value: string | number | undefined) {
      setForm(f => ({ ...f, [key]: value }));
    }

    function toggleSection(key: SectionKey) {
      setOpen(prev => ({ ...prev, [key]: !prev[key] }));
    }

    function onDoctorChange(text: string) {
      update('doctor_name', text || undefined);
      setDoctorSuggestions(text.length >= 2 ? getAutocompleteDoctors(text) : []);
    }

    function onClinicChange(text: string) {
      update('clinic_name', text || undefined);
      setClinicSuggestions(text.length >= 2 ? getAutocompleteClinics(text) : []);
    }

    async function pickAttachment(type: AttachmentType) {
      Alert.alert('Add Attachment', type.charAt(0).toUpperCase() + type.slice(1), [
        {
          text: 'Take Photo',
          onPress: async () => {
            const perm = await ImagePicker.requestCameraPermissionsAsync();
            if (!perm.granted) { Alert.alert('Permission Required', 'Camera access is needed.'); return; }
            const res = await ImagePicker.launchCameraAsync({ quality: 0.9 });
            if (!res.canceled && res.assets[0]) await addImageDraft(type, res.assets[0].uri);
          },
        },
        {
          text: 'Choose from Gallery',
          onPress: async () => {
            const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
            if (!perm.granted) { Alert.alert('Permission Required', 'Gallery access is needed.'); return; }
            const res = await ImagePicker.launchImageLibraryAsync({ quality: 0.9 });
            if (!res.canceled && res.assets[0]) await addImageDraft(type, res.assets[0].uri);
          },
        },
        {
          text: 'Choose PDF',
          onPress: async () => {
            const res = await DocumentPicker.getDocumentAsync({ type: 'application/pdf' });
            if (!res.canceled && res.assets[0]) addDraft(type, res.assets[0].uri, 'application/pdf');
          },
        },
        { text: 'Cancel', style: 'cancel' },
      ]);
    }

    async function addImageDraft(type: AttachmentType, uri: string) {
      try {
        const compressed = await fileService.compressImage(uri);
        addDraft(type, compressed, 'image/jpeg');
      } catch {
        addDraft(type, uri, 'image/jpeg');
      }
    }

    function addDraft(type: AttachmentType, uri: string, mimeType: string) {
      setDraftAttachments(prev => [
        ...prev,
        { id: `draft_${Date.now()}`, uri, type, mimeType },
      ]);
    }

    function draftToAttachment(d: DraftAttachment): Attachment {
      return {
        id: d.id,
        visit_id: 'draft',
        type: d.type,
        file_path: d.uri,
        file_name: `${d.type}_draft`,
        mime_type: d.mimeType as any,
        size_bytes: 0,
        thumbnail_path: d.mimeType.startsWith('image/') ? d.uri : undefined,
        created_at: '',
      };
    }

    // Merged list: existing (saved) + drafts (not yet saved) for a given type
    function allForType(type: AttachmentType): Attachment[] {
      return [
        ...existingAttachments.filter(a => a.type === type),
        ...draftAttachments.filter(d => d.type === type).map(draftToAttachment),
      ];
    }

    function handleGridDelete(type: AttachmentType, id: string) {
      if (id.startsWith('draft_')) {
        setDraftAttachments(prev => prev.filter(d => d.id !== id));
      } else {
        const att = existingAttachments.find(a => a.id === id);
        if (att) onDeleteExisting?.(att);
      }
    }

    return (
      <>
        <ScrollView
          contentContainerStyle={styles.form}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* ── Visit Info ────────────────────────────────────────── */}
          <List.Accordion
            title="Visit Info"
            expanded={open.visitInfo}
            onPress={() => toggleSection('visitInfo')}
            style={styles.accordion}
            titleStyle={styles.accordionTitle}
            left={p => <List.Icon {...p} icon="calendar-check" color={Colors.primary} />}
          >
            <View style={styles.sectionBody}>
              <TextInput
                label="Visit Date *"
                value={form.visit_date ?? ''}
                onChangeText={v => update('visit_date', v || undefined)}
                placeholder="YYYY-MM-DD"
                style={styles.input}
                autoCapitalize="none"
                right={<TextInput.Icon icon="calendar" />}
              />
              <TextInput
                label="Follow-up Date"
                value={form.follow_up_date ?? ''}
                onChangeText={v => update('follow_up_date', v || undefined)}
                placeholder="YYYY-MM-DD (optional)"
                style={styles.input}
                autoCapitalize="none"
                right={<TextInput.Icon icon="calendar-clock" />}
              />
              <TextInput
                label="Symptoms"
                value={form.symptoms ?? ''}
                onChangeText={v => update('symptoms', v.slice(0, 500) || undefined)}
                multiline
                numberOfLines={3}
                style={styles.input}
                maxLength={500}
              />
              <Text style={styles.charCount}>{form.symptoms?.length ?? 0} / 500</Text>
            </View>
          </List.Accordion>

          <Divider />

          {/* ── Doctor Details ────────────────────────────────────── */}
          <List.Accordion
            title="Doctor Details"
            expanded={open.doctor}
            onPress={() => toggleSection('doctor')}
            style={styles.accordion}
            titleStyle={styles.accordionTitle}
            left={p => <List.Icon {...p} icon="doctor" color={Colors.primary} />}
          >
            <View style={styles.sectionBody}>
              {/* Body Part */}
              <Pressable onPress={() => setShowBodyPicker(true)} style={styles.pickerBtn}>
                <Text style={styles.pickerLabel}>Body Part</Text>
                <Text style={[styles.pickerValue, !bodyPart && styles.pickerPlaceholder]}>
                  {bodyPart?.label ?? 'Tap to select'}
                </Text>
              </Pressable>

              {/* Speciality */}
              <Pressable onPress={() => setShowSpecPicker(true)} style={styles.pickerBtn}>
                <Text style={styles.pickerLabel}>Speciality</Text>
                <View style={styles.pickerValueRow}>
                  {speciality ? (
                    <>
                      <MaterialCommunityIcons
                        name={speciality.icon as any}
                        size={16}
                        color={speciality.color}
                      />
                      <Text style={[styles.pickerValue, { color: speciality.color, marginLeft: 4 }]}>
                        {speciality.label}
                      </Text>
                    </>
                  ) : (
                    <Text style={styles.pickerPlaceholder}>Tap to select</Text>
                  )}
                </View>
              </Pressable>

              {form.speciality_id === 'OTHER' && (
                <TextInput
                  label="Custom Speciality"
                  value={form.custom_speciality ?? ''}
                  onChangeText={v => update('custom_speciality', v || undefined)}
                  style={styles.input}
                />
              )}

              {/* Doctor name + autocomplete */}
              <View style={styles.autocompleteWrap}>
                <TextInput
                  label="Doctor Name"
                  value={form.doctor_name ?? ''}
                  onChangeText={onDoctorChange}
                  style={styles.input}
                  right={<TextInput.Icon icon="account-search" />}
                />
                {doctorSuggestions.length > 0 && (
                  <View style={styles.suggestions}>
                    {doctorSuggestions.map(s => (
                      <Pressable
                        key={s}
                        style={styles.suggestionItem}
                        onPress={() => { update('doctor_name', s); setDoctorSuggestions([]); }}
                      >
                        <MaterialCommunityIcons name="account" size={14} color={Colors.textSecondary} />
                        <Text style={styles.suggestionText}>{s}</Text>
                      </Pressable>
                    ))}
                  </View>
                )}
              </View>

              {/* Clinic name + autocomplete */}
              <View style={styles.autocompleteWrap}>
                <TextInput
                  label="Clinic Name"
                  value={form.clinic_name ?? ''}
                  onChangeText={onClinicChange}
                  style={styles.input}
                  right={<TextInput.Icon icon="hospital-building" />}
                />
                {clinicSuggestions.length > 0 && (
                  <View style={styles.suggestions}>
                    {clinicSuggestions.map(s => (
                      <Pressable
                        key={s}
                        style={styles.suggestionItem}
                        onPress={() => { update('clinic_name', s); setClinicSuggestions([]); }}
                      >
                        <MaterialCommunityIcons name="hospital-building" size={14} color={Colors.textSecondary} />
                        <Text style={styles.suggestionText}>{s}</Text>
                      </Pressable>
                    ))}
                  </View>
                )}
              </View>

              <TextInput
                label="Clinic Phone"
                value={form.clinic_phone ?? ''}
                onChangeText={v => update('clinic_phone', v || undefined)}
                keyboardType="phone-pad"
                style={styles.input}
                right={<TextInput.Icon icon="phone" />}
              />
              <TextInput
                label="Doctor Fees"
                value={form.doctor_fees != null ? String(form.doctor_fees) : ''}
                onChangeText={v => update('doctor_fees', v ? parseFloat(v) : undefined)}
                keyboardType="numeric"
                style={styles.input}
                left={<TextInput.Affix text={currencyPrefix} />}
              />
            </View>
          </List.Accordion>

          <Divider />

          {/* ── Diagnosis ─────────────────────────────────────────── */}
          <List.Accordion
            title="Diagnosis"
            expanded={open.diagnosis}
            onPress={() => toggleSection('diagnosis')}
            style={styles.accordion}
            titleStyle={styles.accordionTitle}
            left={p => <List.Icon {...p} icon="clipboard-text" color={Colors.primary} />}
          >
            <View style={styles.sectionBody}>
              <TextInput
                label="Diagnosis"
                value={form.diagnosis ?? ''}
                onChangeText={v => update('diagnosis', v.slice(0, 500) || undefined)}
                multiline
                numberOfLines={3}
                style={styles.input}
                maxLength={500}
              />
              <Text style={styles.charCount}>{form.diagnosis?.length ?? 0} / 500</Text>
            </View>
          </List.Accordion>

          <Divider />

          {/* ── Attachments ───────────────────────────────────────── */}
          <List.Accordion
            title="Attachments"
            expanded={open.attachments}
            onPress={() => toggleSection('attachments')}
            style={styles.accordion}
            titleStyle={styles.accordionTitle}
            left={p => <List.Icon {...p} icon="paperclip" color={Colors.primary} />}
          >
            <View style={styles.sectionBody}>
              {(['prescription', 'medicine', 'bill', 'report'] as AttachmentType[]).map(type => (
                <View key={type} style={styles.attachBlock}>
                  <Text style={styles.attachLabel}>
                    {type.charAt(0).toUpperCase() + type.slice(1)}
                  </Text>
                  <AttachmentGrid
                    attachments={allForType(type)}
                    type={type}
                    onAdd={() => pickAttachment(type)}
                    onDelete={id => handleGridDelete(type, id)}
                    onView={att => setViewerAtt(att)}
                    maxFiles={ATTACHMENT_LIMITS[type].maxFiles}
                  />
                </View>
              ))}
            </View>
          </List.Accordion>

          <Divider />

          {/* ── Notes ─────────────────────────────────────────────── */}
          <List.Accordion
            title="Notes"
            expanded={open.notes}
            onPress={() => toggleSection('notes')}
            style={styles.accordion}
            titleStyle={styles.accordionTitle}
            left={p => <List.Icon {...p} icon="note-text" color={Colors.primary} />}
          >
            <View style={styles.sectionBody}>
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
        </ScrollView>

        {/* ── Body Part picker ──────────────────────────────────── */}
        <Modal
          visible={showBodyPicker}
          animationType="slide"
          onRequestClose={() => setShowBodyPicker(false)}
        >
          <SafeAreaView style={styles.modal}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Select Body Part</Text>
              <Pressable onPress={() => setShowBodyPicker(false)} hitSlop={8}>
                <MaterialCommunityIcons name="close" size={24} color={Colors.textPrimary} />
              </Pressable>
            </View>
            <FlatList
              data={BODY_PARTS}
              keyExtractor={b => b.id}
              renderItem={({ item }) => (
                <Pressable
                  style={styles.modalItem}
                  onPress={() => { update('body_part_id', item.id); setShowBodyPicker(false); }}
                >
                  <View style={styles.modalItemLeft}>
                    <MaterialCommunityIcons
                      name={item.icon as any}
                      size={22}
                      color={Colors.primary}
                      style={{ marginRight: Spacing.sm }}
                    />
                    <View>
                      <Text style={styles.modalItemText}>{item.label}</Text>
                      <Text style={styles.modalItemSub}>{item.description}</Text>
                    </View>
                  </View>
                  {form.body_part_id === item.id && (
                    <MaterialCommunityIcons name="check-circle" size={20} color={Colors.primary} />
                  )}
                </Pressable>
              )}
            />
          </SafeAreaView>
        </Modal>

        {/* ── Speciality picker ────────────────────────────────── */}
        <Modal
          visible={showSpecPicker}
          animationType="slide"
          onRequestClose={() => setShowSpecPicker(false)}
        >
          <SafeAreaView style={styles.modal}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Select Speciality</Text>
              <Pressable onPress={() => setShowSpecPicker(false)} hitSlop={8}>
                <MaterialCommunityIcons name="close" size={24} color={Colors.textPrimary} />
              </Pressable>
            </View>
            <FlatList
              data={SPECIALITIES}
              keyExtractor={s => s.id}
              renderItem={({ item }) => (
                <Pressable
                  style={styles.modalItem}
                  onPress={() => { update('speciality_id', item.id); setShowSpecPicker(false); }}
                >
                  <View style={styles.modalItemLeft}>
                    <View style={[styles.specCircle, { backgroundColor: item.color + '18' }]}>
                      <MaterialCommunityIcons name={item.icon as any} size={18} color={item.color} />
                    </View>
                    <Text style={styles.modalItemText}>{item.label}</Text>
                  </View>
                  {form.speciality_id === item.id && (
                    <MaterialCommunityIcons name="check-circle" size={20} color={Colors.primary} />
                  )}
                </Pressable>
              )}
            />
          </SafeAreaView>
        </Modal>

        {/* Attachment viewer */}
        <Viewer attachment={viewerAtt} onClose={() => setViewerAtt(null)} />
      </>
    );
  },
);

// ─── Styles ───────────────────────────────────────────────────────────────

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
  charCount: {
    fontSize: 11,
    color: Colors.textSecondary,
    textAlign: 'right',
    marginRight: Spacing.md,
    marginTop: -Spacing.xs,
    marginBottom: Spacing.sm,
  },
  pickerBtn: {
    marginHorizontal: Spacing.md,
    marginBottom: Spacing.sm,
    padding: Spacing.md,
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.sm,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  pickerLabel: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginBottom: 2,
  },
  pickerValueRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  pickerValue: {
    fontSize: 14,
    color: Colors.textPrimary,
  },
  pickerPlaceholder: {
    fontSize: 14,
    color: Colors.textDisabled,
  },
  autocompleteWrap: {
    zIndex: 10,
  },
  suggestions: {
    marginHorizontal: Spacing.md,
    marginTop: -Spacing.sm,
    marginBottom: Spacing.sm,
    backgroundColor: Colors.surface,
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: BorderRadius.sm,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  suggestionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.sm,
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  suggestionText: {
    fontSize: 14,
    color: Colors.textPrimary,
  },
  attachBlock: {
    marginHorizontal: Spacing.md,
    marginBottom: Spacing.md,
  },
  attachLabel: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.textSecondary,
    marginBottom: Spacing.xs,
    textTransform: 'capitalize',
  },
  modal: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  modalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.md,
    backgroundColor: Colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  modalTitle: {
    fontSize: 17,
    fontWeight: '700',
    color: Colors.textPrimary,
  },
  modalItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.md,
    backgroundColor: Colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  modalItemLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  modalItemText: {
    fontSize: 15,
    color: Colors.textPrimary,
  },
  modalItemSub: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginTop: 1,
  },
  specCircle: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.sm,
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
