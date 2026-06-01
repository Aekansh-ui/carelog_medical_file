import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { Stack } from 'expo-router';
import { Colors, Spacing } from '@src/utils/theme';

export default function NewMemberScreen() {
  return (
    <View style={styles.container}>
      <Stack.Screen options={{ title: 'Add Member' }} />
      <Text style={styles.text}>Member form — coming in F5</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Colors.background,
    padding: Spacing.lg,
  },
  text: {
    color: Colors.textSecondary,
    fontSize: 16,
  },
});
