import React, { useEffect, useRef, useState } from 'react';
import { View, StyleSheet, Alert, Pressable, ActivityIndicator } from 'react-native';
import { Button } from 'react-native-paper';
import { Stack, router, useLocalSearchParams } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useVisitsStore } from '@src/store/visitsStore';
import { useRemindersStore } from '@src/store/remindersStore';
import { attachmentsRepository } from '@src/db/attachmentsRepository';
import { remindersRepository } from '@src/db/remindersRepository';
import { getDb } from '@src/db/database';
import { fileService } from '@src/services/fileService';
import { notificationService } from '@src/services/notificationService';
import { Attachment } from '@src/types/Attachment';
import { CreateVisitInput } from '@src/types/Visit';
import { validateVisitForm } from '@src/utils/validators';
import { Colors, Spacing } from '@src/utils/theme';
import { VisitForm, VisitFormHandle } from '@src/components/VisitForm';

export default function EditVisitScreen() {
  const { visitId } = useLocalSearchParams<{ visitId: string }>();
  const formRef = useRef<VisitFormHandle>(null);

  const selectedVisit = useVisitsStore(s => s.selectedVisit);
  const loadVisitById = useVisitsStore(s => s.loadVisitById);
  const updateVisit = useVisitsStore(s => s.updateVisit);
  const createReminder = useRemindersStore(s => s.createReminder);

  const [attachments, setAttachments] = useState<Attachment[]>([]);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (visitId) {
      loadVisitById(visitId);
      setAttachments(attachmentsRepository.findByVisitId(visitId));
    }
  }, [visitId]);

  async function handleDeleteAttachment(att: Attachment) {
    try { await fileService.deleteAttachment(att.file_path); } catch { /* ignore missing files */ }
    attachmentsRepository.delete(att.id);
    setAttachments(prev => prev.filter(a => a.id !== att.id));
  }

  async function handleSave() {
    if (!formRef.current || saving || !visitId) return;
    const form = formRef.current.getForm();
    const drafts = formRef.current.getDraftAttachments();
    const draftId = formRef.current.getDraftId();

    const errors = validateVisitForm(form);
    if (errors.length) { Alert.alert('Cannot Save', errors.join('\n')); return; }

    setSaving(true);
    try {
      updateVisit(visitId, form);

      // Persist any newly-added draft attachments
      for (const draft of drafts) {
        const { filePath, fileName, thumbnailPath, sizeBytes } =
          await fileService.saveAttachment(visitId, draft.type, draft.uri, draft.mimeType);
        attachmentsRepository.create({
          visit_id: visitId, type: draft.type,
          file_path: filePath, file_name: fileName,
          mime_type: draft.mimeType as any, size_bytes: sizeBytes,
          thumbnail_path: thumbnailPath,
        });
      }

      // Handle follow_up_date change: cancel old reminder, create new one
      const oldFollowUp = selectedVisit?.follow_up_date ?? null;
      const newFollowUp = (form as CreateVisitInput).follow_up_date ?? null;
      if (oldFollowUp !== newFollowUp) {
        const existing = remindersRepository.findByVisitId(visitId);
        if (existing) {
          await notificationService.cancelNotifications(
            existing.notification_id_d1 ?? '',
            existing.notification_id_d0 ?? '',
          );
          remindersRepository.delete(existing.id);
        }
        if (newFollowUp) {
          await createReminder(visitId, newFollowUp);
        }
      }

      try { getDb().runSync('DELETE FROM visit_drafts WHERE id = ?', [draftId]); } catch {}
      router.back();
    } catch {
      Alert.alert('Error', 'Failed to save changes. Please try again.');
    } finally {
      setSaving(false);
    }
  }

  // Loading state — visit hasn't been fetched from DB yet
  if (!selectedVisit) {
    return (
      <SafeAreaView style={styles.safe} edges={['bottom']}>
        <Stack.Screen
          options={{
            title: 'Edit Visit',
            headerStyle: { backgroundColor: Colors.primary },
            headerTintColor: '#FFF',
          }}
        />
        <View style={styles.loading}>
          <ActivityIndicator size="large" color={Colors.primary} />
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safe} edges={['bottom']}>
      <Stack.Screen
        options={{
          title: 'Edit Visit',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
          headerLeft: () => (
            <Pressable onPress={() => router.back()} style={styles.headerBtn} hitSlop={8}>
              <MaterialCommunityIcons name="close" size={24} color="#FFF" />
            </Pressable>
          ),
          headerRight: () => (
            <Button
              mode="text" textColor="#FFF" onPress={handleSave}
              loading={saving} disabled={saving} style={styles.headerSaveBtn}
            >
              Save
            </Button>
          ),
        }}
      />
      {/*
       * VisitForm is mounted only after selectedVisit is loaded, so initialForm
       * is fully populated on first mount — no re-initialisation needed.
       */}
      <VisitForm
        ref={formRef}
        initialForm={{
          body_part_id: selectedVisit.body_part_id,
          speciality_id: selectedVisit.speciality_id,
          custom_speciality: selectedVisit.custom_speciality,
          visit_date: selectedVisit.visit_date,
          follow_up_date: selectedVisit.follow_up_date,
          doctor_name: selectedVisit.doctor_name,
          clinic_name: selectedVisit.clinic_name,
          clinic_phone: selectedVisit.clinic_phone,
          doctor_fees: selectedVisit.doctor_fees,
          currency: selectedVisit.currency ?? 'INR',
          symptoms: selectedVisit.symptoms,
          diagnosis: selectedVisit.diagnosis,
          notes: selectedVisit.notes,
        }}
        existingAttachments={attachments}
        onDeleteExisting={handleDeleteAttachment}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  loading: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  headerBtn: { paddingHorizontal: Spacing.sm },
  headerSaveBtn: { marginRight: -Spacing.xs },
});
