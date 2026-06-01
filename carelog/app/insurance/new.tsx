import React, { useRef, useState } from 'react';
import { StyleSheet, Alert, Pressable } from 'react-native';
import { Button } from 'react-native-paper';
import { Stack, router, useLocalSearchParams } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useInsuranceStore } from '@src/store/insuranceStore';
import { insuranceRepository } from '@src/db/insuranceRepository';
import { fileService } from '@src/services/fileService';
import { CreateInsuranceInput } from '@src/types/Insurance';
import { validateInsuranceForm } from '@src/utils/validators';
import { Colors, Spacing } from '@src/utils/theme';
import { InsuranceForm, InsuranceFormHandle } from '@src/components/InsuranceForm';

export default function NewInsuranceScreen() {
  const { memberId } = useLocalSearchParams<{ memberId: string }>();
  const formRef = useRef<InsuranceFormHandle>(null);
  const createPolicy = useInsuranceStore(s => s.createPolicy);
  const [saving, setSaving] = useState(false);

  async function handleSave() {
    if (!formRef.current || saving) return;
    const form = formRef.current.getForm();
    const drafts = formRef.current.getDraftDocs();

    const errors = validateInsuranceForm(form);
    if (errors.length) { Alert.alert('Cannot Save', errors.join('\n')); return; }

    setSaving(true);
    try {
      const policy = createPolicy({
        ...form,
        member_id: memberId,
      } as CreateInsuranceInput);

      for (const draft of drafts) {
        const { filePath, fileName, thumbnailPath, sizeBytes } =
          await fileService.saveInsuranceDocument(policy.id, draft.uri, draft.mimeType);
        insuranceRepository.addDocument({
          policy_id: policy.id,
          file_path: filePath,
          file_name: fileName,
          mime_type: draft.mimeType,
          size_bytes: sizeBytes,
          thumbnail_path: thumbnailPath,
        });
      }
      router.back();
    } catch {
      Alert.alert('Error', 'Failed to save insurance. Please try again.');
    } finally {
      setSaving(false);
    }
  }

  return (
    <SafeAreaView style={styles.safe} edges={['bottom']}>
      <Stack.Screen
        options={{
          title: 'Add Insurance',
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
      <InsuranceForm ref={formRef} initialForm={{ member_id: memberId }} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  headerBtn: { paddingHorizontal: Spacing.sm },
  headerSaveBtn: { marginRight: -Spacing.xs },
});
