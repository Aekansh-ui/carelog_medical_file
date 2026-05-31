import React, { useState } from 'react';
import { View, ScrollView, StyleSheet, Alert } from 'react-native';
import { Appbar, List, Switch, SegmentedButtons, Button, Text, Divider } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useSettingsStore } from '@src/store/settingsStore';
import { exportService } from '@src/services/exportService';
import { fileService } from '@src/services/fileService';
import { getDb } from '@src/db/database';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Colors, Spacing } from '@src/constants/theme';

export default function SettingsScreen() {
  const { currency, notificationsEnabled, setSetting } = useSettingsStore();
  const [exporting, setExporting] = useState(false);

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

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right']}>
      <Appbar.Header style={styles.header}>
        <Appbar.Content title="Settings" titleStyle={styles.headerTitle} />
      </Appbar.Header>

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
        </List.Section>

        <Divider />

        <List.Section>
          <List.Subheader>Data</List.Subheader>
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
  header: { backgroundColor: Colors.primary },
  headerTitle: { color: '#FFF', fontWeight: '700' },
  content: { paddingBottom: Spacing.xl },
  segment: { marginRight: Spacing.sm },
  buttonRow: { paddingHorizontal: Spacing.md, marginBottom: Spacing.sm },
  actionButton: { width: '100%' },
  dangerButton: { borderColor: Colors.error },
  meta: { color: Colors.textSecondary, alignSelf: 'center' },
});
