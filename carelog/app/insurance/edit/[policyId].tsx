import React, { useEffect, useRef, useState } from 'react';
import { View, StyleSheet, Alert, Pressable, ActivityIndicator } from 'react-native';
import { Button } from 'react-native-paper';
import { Stack, router, useLocalSearchParams } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useInsuranceStore } from '@src/store/insuranceStore';
import { insuranceRepository } from '@src/db/insuranceRepository';
import { fileService } from '@src/services/fileService';
import { InsuranceDocument, InsurancePolicy } from '@src/types/Insurance';
import { validateInsuranceForm } from '@src/utils/validators';
import { Colors, Spacing } from '@src/utils/theme';
import { InsuranceForm, InsuranceFormHandle } from '@src/components/InsuranceForm';

export default function EditInsuranceScreen() {
  const { policyId } = useLocalSearchParams<{ policyId: string }>();
  const formRef = useRef<InsuranceFormHandle>(null);

  const updatePolicy = useInsuranceStore(s => s.updatePolicy);
  const deletePolicy = useInsuranceStore(s => s.deletePolicy);

  const [policy, setPolicy] = useState<InsurancePolicy | null>(null);
  const [docs, setDocs] = useState<InsuranceDocument[]>([]);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (policyId) {
      setPolicy(insuranceRepository.findById(policyId));
      setDocs(insuranceRepository.findDocuments(policyId));
    }
  }, [policyId]);

  async function handleDeleteDoc(doc: InsuranceDocument) {
    try { await fileService.deleteAttachment(doc.file_path); } catch { /* ignore */ }
    if (doc.thumbnail_path) {
      try { await fileService.deleteAttachment(doc.thumbnail_path); } catch { /* ignore */ }
    }
    insuranceRepository.deleteDocument(doc.id);
    setDocs(prev => prev.filter(d => d.id !== doc.id));
  }

  async function handleSave() {
    if (!formRef.current || saving || !policyId) return;
    const form = formRef.current.getForm();
    const drafts = formRef.current.getDraftDocs();

    const errors = validateInsuranceForm(form);
    if (errors.length) { Alert.alert('Cannot Save', errors.join('\n')); return; }

    setSaving(true);
    try {
      updatePolicy(policyId, form);

      for (const draft of drafts) {
        const { filePath, fileName, thumbnailPath, sizeBytes } =
          await fileService.saveInsuranceDocument(policyId, draft.uri, draft.mimeType);
        insuranceRepository.addDocument({
          policy_id: policyId,
          file_path: filePath,
          file_name: fileName,
          mime_type: draft.mimeType,
          size_bytes: sizeBytes,
          thumbnail_path: thumbnailPath,
        });
      }
      router.back();
    } catch {
      Alert.alert('Error', 'Failed to save changes. Please try again.');
    } finally {
      setSaving(false);
    }
  }

  function handleDeletePolicy() {
    Alert.alert(
      'Delete Insurance',
      'This will permanently delete this policy and all its documents. This cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            const removedFiles = deletePolicy(policyId!);
            for (const f of removedFiles) {
              try { await fileService.deleteAttachment(f.filePath); } catch { /* ignore */ }
              if (f.thumbnailPath) {
                try { await fileService.deleteAttachment(f.thumbnailPath); } catch { /* ignore */ }
              }
            }
            // Pop back past the (now-deleted) detail screen to the policy list.
            router.back();
            router.back();
          },
        },
      ],
    );
  }

  if (!policy) {
    return (
      <SafeAreaView style={styles.safe} edges={['bottom']}>
        <Stack.Screen
          options={{
            title: 'Edit Insurance',
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
          title: 'Edit Insurance',
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

      <InsuranceForm
        ref={formRef}
        initialForm={{
          member_id: policy.member_id,
          insurer_name: policy.insurer_name,
          plan_type: policy.plan_type,
          policy_number: policy.policy_number,
          policy_holder: policy.policy_holder,
          sum_insured: policy.sum_insured,
          premium: policy.premium,
          currency: policy.currency ?? 'INR',
          valid_from: policy.valid_from,
          valid_until: policy.valid_until,
          helpline_phone: policy.helpline_phone,
          agent_name: policy.agent_name,
          notes: policy.notes,
        }}
        existingDocs={docs}
        onDeleteExisting={handleDeleteDoc}
        footer={
          <View style={styles.deleteSection}>
            <Button
              mode="outlined"
              onPress={handleDeletePolicy}
              textColor={Colors.error}
              style={styles.deleteBtn}
              icon="trash-can-outline"
            >
              Delete Insurance
            </Button>
          </View>
        }
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  loading: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  headerBtn: { paddingHorizontal: Spacing.sm },
  headerSaveBtn: { marginRight: -Spacing.xs },
  deleteSection: {
    marginTop: Spacing.lg,
    paddingHorizontal: Spacing.md,
    paddingTop: Spacing.lg,
    borderTopWidth: 1,
    borderTopColor: Colors.border,
  },
  deleteBtn: {
    borderColor: Colors.error,
  },
});
