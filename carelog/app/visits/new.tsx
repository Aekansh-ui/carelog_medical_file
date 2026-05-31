import React, { useRef, useState } from 'react';
import { StyleSheet, Alert, Pressable } from 'react-native';
import { Button } from 'react-native-paper';
import { Stack, router, useLocalSearchParams } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useVisitsStore } from '@src/store/visitsStore';
import { useRemindersStore } from '@src/store/remindersStore';
import { attachmentsRepository } from '@src/db/attachmentsRepository';
import { getDb } from '@src/db/database';
import { fileService } from '@src/services/fileService';
import type { BodyPartId } from '@src/constants/bodyParts';
import type { SpecialityId } from '@src/constants/specialities';
import { CreateVisitInput } from '@src/types/Visit';
import { validateVisitForm } from '@src/utils/validators';
import { Colors, Spacing } from '@src/utils/theme';
import { VisitForm, VisitFormHandle } from '@src/components/VisitForm';

export default function NewVisitScreen() {
  const params = useLocalSearchParams<{ bodyPartId: string; specialityId: string }>();
  const formRef = useRef<VisitFormHandle>(null);
  const createVisit = useVisitsStore(s => s.createVisit);
  const createReminder = useRemindersStore(s => s.createReminder);
  const [saving, setSaving] = useState(false);

  const initialForm = {
    body_part_id: params.bodyPartId as BodyPartId | undefined,
    speciality_id: params.specialityId as SpecialityId | undefined,
  };

  async function handleSave() {
    if (!formRef.current || saving) return;
    const form = formRef.current.getForm();
    const drafts = formRef.current.getDraftAttachments();
    const draftId = formRef.current.getDraftId();

    const errors = validateVisitForm(form);
    if (errors.length) { Alert.alert('Cannot Save', errors.join('\n')); return; }

    setSaving(true);
    try {
      const visit = createVisit(form as CreateVisitInput);
      for (const draft of drafts) {
        const { filePath, fileName, thumbnailPath, sizeBytes } =
          await fileService.saveAttachment(visit.id, draft.type, draft.uri, draft.mimeType);
        attachmentsRepository.create({
          visit_id: visit.id, type: draft.type,
          file_path: filePath, file_name: fileName,
          mime_type: draft.mimeType as any, size_bytes: sizeBytes,
          thumbnail_path: thumbnailPath,
        });
      }
      if (form.follow_up_date) await createReminder(visit.id, form.follow_up_date);
      try { getDb().runSync('DELETE FROM visit_drafts WHERE id = ?', [draftId]); } catch {}
      router.back();
    } catch {
      Alert.alert('Error', 'Failed to save visit. Please try again.');
    } finally {
      setSaving(false);
    }
  }

  return (
    <SafeAreaView style={styles.safe} edges={['bottom']}>
      <Stack.Screen
        options={{
          title: 'Add Visit',
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
      <VisitForm ref={formRef} initialForm={initialForm} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  headerBtn: { paddingHorizontal: Spacing.sm },
  headerSaveBtn: { marginRight: -Spacing.xs },
});
