import React, { useState } from 'react';
import { View, ScrollView, StyleSheet, Pressable, Alert } from 'react-native';
import { Text, TextInput, Button } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Stack, router } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useMemberStore } from '@src/store/memberStore';
import { RELATIONSHIPS, GENDERS } from '@src/constants/members';
import { isValidDate } from '@src/utils/validators';
import { Colors, Spacing, BorderRadius } from '@src/utils/theme';
import type { RelationshipType, Gender } from '@src/constants/members';

export default function NewMemberScreen() {
  const members = useMemberStore(s => s.members);
  const createMember = useMemberStore(s => s.createMember);

  const defaultRelationship: RelationshipType = members.length === 0 ? 'SELF' : 'OTHER';

  const [name, setName] = useState('');
  const [relationship, setRelationship] = useState<RelationshipType>(defaultRelationship);
  const [dob, setDob] = useState('');
  const [dobError, setDobError] = useState('');
  const [gender, setGender] = useState<Gender | null>(null);
  const [saving, setSaving] = useState(false);

  function validateDob(value: string): boolean {
    if (!value) { setDobError(''); return true; }
    if (!isValidDate(value)) {
      setDobError('Date must be in YYYY-MM-DD format');
      return false;
    }
    setDobError('');
    return true;
  }

  function handleSave() {
    if (!name.trim()) { Alert.alert('Required', 'Name is required.'); return; }
    if (!validateDob(dob)) return;
    setSaving(true);
    try {
      createMember({
        name: name.trim(),
        relationship,
        date_of_birth: dob || undefined,
        gender: gender ?? undefined,
      });
      router.back();
    } catch {
      Alert.alert('Error', 'Failed to save member. Please try again.');
    } finally {
      setSaving(false);
    }
  }

  return (
    <SafeAreaView style={styles.safe} edges={['bottom']}>
      <Stack.Screen
        options={{
          title: 'Add Member',
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

      <ScrollView contentContainerStyle={styles.form} keyboardShouldPersistTaps="handled">
        <Text style={styles.label}>Name *</Text>
        <TextInput
          value={name}
          onChangeText={setName}
          placeholder="Full name"
          style={styles.input}
          autoCapitalize="words"
          maxLength={100}
        />

        <Text style={styles.label}>Relationship</Text>
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.chipRow}
        >
          {RELATIONSHIPS.map(r => (
            <Pressable
              key={r.id}
              onPress={() => setRelationship(r.id)}
              style={[styles.chip, relationship === r.id && styles.chipActive]}
            >
              <MaterialCommunityIcons
                name={r.icon as any}
                size={14}
                color={relationship === r.id ? '#FFF' : Colors.primary}
              />
              <Text style={[styles.chipText, relationship === r.id && styles.chipTextActive]}>
                {r.label}
              </Text>
            </Pressable>
          ))}
        </ScrollView>

        <Text style={styles.label}>Date of Birth (optional)</Text>
        <TextInput
          value={dob}
          onChangeText={v => { setDob(v); if (dobError) validateDob(v); }}
          onBlur={() => validateDob(dob)}
          placeholder="YYYY-MM-DD"
          style={styles.input}
          autoCapitalize="none"
          keyboardType="numeric"
          right={<TextInput.Icon icon="calendar" />}
        />
        {dobError ? <Text style={styles.errorText}>{dobError}</Text> : null}

        <Text style={styles.label}>Gender (optional)</Text>
        <View style={styles.chipRow}>
          {GENDERS.map(g => (
            <Pressable
              key={g.id}
              onPress={() => setGender(prev => prev === g.id ? null : g.id)}
              style={[styles.chip, gender === g.id && styles.chipActive]}
            >
              <Text style={[styles.chipText, gender === g.id && styles.chipTextActive]}>
                {g.label}
              </Text>
            </Pressable>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  headerBtn: { paddingHorizontal: Spacing.sm },
  headerSaveBtn: { marginRight: -Spacing.xs },
  form: {
    padding: Spacing.md,
    paddingBottom: Spacing.xxl,
  },
  label: {
    fontSize: 12,
    fontWeight: '600' as const,
    color: Colors.textSecondary,
    marginTop: Spacing.lg,
    marginBottom: Spacing.xs,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  input: {
    backgroundColor: Colors.surface,
  },
  errorText: {
    fontSize: 12,
    color: Colors.error,
    marginTop: 4,
  },
  chipRow: {
    flexDirection: 'row',
    gap: Spacing.sm,
    paddingVertical: Spacing.xs,
    paddingHorizontal: 2,
    flexWrap: 'wrap',
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
});
