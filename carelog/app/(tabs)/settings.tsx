import React, { useState, useEffect } from 'react';
import { View, ScrollView, StyleSheet, Alert } from 'react-native';
import { List, Switch, SegmentedButtons, Button, Text, Divider, TextInput } from 'react-native-paper';
import { Stack } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useSettingsStore } from '@src/store/settingsStore';
import { exportService } from '@src/services/exportService';
import { fileService } from '@src/services/fileService';
import { getDb } from '@src/db/database';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Colors, Spacing } from '@src/utils/theme';

export default function SettingsScreen() {
  const { currency, notificationsEnabled, reminderTime, setSetting } = useSettingsStore();
  const [exporting, setExporting] = useState(false);
  const [storageUsed, setStorageUsed] = useState<string>('–');
  const [reminderInput, setReminderInput] = useState(reminderTime);

  useEffect(() => {
    fileService.getStorageUsedBytes()
      .then(bytes => setStorageUsed((bytes / (1024 * 1024)).toFixed(1) + ' MB'))
      .catch(() => setStorageUsed('–'));
  }, []);

  useEffect(() => {
    setReminderInput(reminderTime);
  }, [reminderTime]);

  async function handleExport() {
    setExporting(true);
    try {
      const path = await exportService.exportAllData();
      Alert.alert('Export Complete', `Data saved to:\n${path}`);
    } catch {
      Alert.alert('Error', 'Export failed. Please try again.');
    } finally {
      setExporting(false);
    }
  }

  function handleDeleteAll() {
    Alert.alert(
      'Delete All Data',
      'This will permanently delete all visits, attachments, and reminders. This cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete Everything',
          style: 'destructive',
          onPress: async () => {
            const db = getDb();
            db.execSync('DELETE FROM reminders;');
            db.execSync('DELETE FROM attachments;');
            db.execSync('DELETE FROM visits;');
            db.execSync('DELETE FROM visit_drafts;');
            await fileService.deleteAllAttachments();
            await AsyncStorage.removeItem('@CareLog_seeded_v1');
            Alert.alert('Done', 'All data has been deleted.');
          },
        },
      ],
    );
  }

  function handleReminderTimeBlur() {
    const valid = /^\d{2}:\d{2}$/.test(reminderInput.trim());
    if (valid) {
      setSetting('reminderTime', reminderInput.trim());
    } else {
      setReminderInput(reminderTime);
    }
  }

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right']}>
      <Stack.Screen
        options={{
          title: 'Settings',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
        }}
      />

      <ScrollView contentContainerStyle={styles.content}>
        <List.Section>
          <List.Subheader>General</List.Subheader>
          <List.Item
            title="Currency"
            description="Used for doctor fees"
            right={() => (
              <SegmentedButtons
                value={currency}
                onValueChange={v => setSetting('currency', v)}
                buttons={[
                  { value: 'INR', label: '₹ INR' },
                  { value: 'USD', label: '$ USD' },
                ]}
                style={styles.segment}
              />
            )}
          />
        </List.Section>

        <Divider />

        <List.Section>
          <List.Subheader>Notifications</List.Subheader>
          <List.Item
            title="Enable Reminders"
            description="Receive follow-up alerts"
            right={() => (
              <Switch
                value={notificationsEnabled}
                onValueChange={v => setSetting('notificationsEnabled', v)}
              />
            )}
          />
          <List.Item
            title="Reminder Time"
            description="Daily alert hour (HH:MM, 24-hr)"
            right={() => (
              <View style={styles.timeInputWrap}>
                <TextInput
                  value={reminderInput}
                  onChangeText={setReminderInput}
                  onBlur={handleReminderTimeBlur}
                  onSubmitEditing={handleReminderTimeBlur}
                  keyboardType="numbers-and-punctuation"
                  style={styles.timeInput}
                  dense
                  mode="outlined"
                  returnKeyType="done"
                  maxLength={5}
                  placeholder="09:00"
                />
              </View>
            )}
          />
        </List.Section>

        <Divider />

        <List.Section>
          <List.Subheader>Data</List.Subheader>
          <List.Item
            title="Storage Used"
            description="Space used by attachments"
            right={() => <Text style={styles.meta}>{storageUsed}</Text>}
          />
          <View style={styles.buttonRow}>
            <Button
              mode="outlined"
              icon="export"
              onPress={handleExport}
              loading={exporting}
              style={styles.actionButton}
            >
              Export All Data
            </Button>
          </View>
          <View style={styles.buttonRow}>
            <Button
              mode="outlined"
              icon="delete-forever"
              onPress={handleDeleteAll}
              textColor={Colors.error}
              style={[styles.actionButton, styles.dangerButton]}
            >
              Delete All Data
            </Button>
          </View>
        </List.Section>

        <Divider />

        <List.Section>
          <List.Subheader>About</List.Subheader>
          <List.Item title="App Version" right={() => <Text style={styles.meta}>CareLog v1.0.0</Text>} />
          <List.Item title="Environment" right={() => <Text style={styles.meta}>Expo SDK 51</Text>} />
        </List.Section>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  content: { paddingBottom: Spacing.xl },
  segment: { marginRight: Spacing.sm },
  timeInputWrap: {
    justifyContent: 'center',
    marginRight: Spacing.sm,
  },
  timeInput: {
    width: 84,
    backgroundColor: Colors.surface,
    fontSize: 14,
  },
  buttonRow: { paddingHorizontal: Spacing.md, marginBottom: Spacing.sm },
  actionButton: { width: '100%' },
  dangerButton: { borderColor: Colors.error },
  meta: { color: Colors.textSecondary, alignSelf: 'center' },
});
