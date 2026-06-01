import { useEffect, useState } from 'react';
import { View, StyleSheet, ActivityIndicator } from 'react-native';
import { Stack } from 'expo-router';
import { PaperProvider, MD3LightTheme, Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { initDatabase } from '@src/db/database';
import { seedIfNeeded } from '@src/db/seed';
import { useSettingsStore } from '@src/store/settingsStore';

const theme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    primary: '#1A6B8A',
    secondary: '#2E9E6B',
    tertiary: '#E67E22',
  },
};

function SplashScreen() {
  return (
    <View style={styles.splash}>
      <MaterialCommunityIcons name="heart-pulse" size={72} color="#1A6B8A" />
      <Text variant="headlineMedium" style={styles.splashTitle}>CareLog</Text>
      <Text variant="bodySmall" style={styles.splashSub}>Your health, organised</Text>
      <ActivityIndicator
        size="large"
        color="#1A6B8A"
        style={styles.splashSpinner}
      />
    </View>
  );
}

export default function RootLayout() {
  const loadSettings = useSettingsStore(s => s.load);
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    (async () => {
      await initDatabase();
      await seedIfNeeded();
      await loadSettings();
      setIsReady(true);
    })();
  }, []);

  // Hold all navigation behind the splash until the database is ready.
  // This prevents any screen from querying SQLite before migrations have run.
  if (!isReady) {
    return (
      <PaperProvider theme={theme}>
        <SplashScreen />
      </PaperProvider>
    );
  }

  return (
    <PaperProvider theme={theme}>
      <Stack>
        <Stack.Screen
          name="(tabs)"
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name="speciality/[bodyPartId]"
          options={{ title: 'Select Speciality', headerStyle: { backgroundColor: '#1A6B8A' }, headerTintColor: '#FFFFFF' }}
        />
        <Stack.Screen
          name="visits/list/[specialityId]"
          options={{ title: 'Visits', headerStyle: { backgroundColor: '#1A6B8A' }, headerTintColor: '#FFFFFF' }}
        />
        <Stack.Screen
          name="visits/[visitId]"
          options={{ title: 'Visit Detail', headerStyle: { backgroundColor: '#1A6B8A' }, headerTintColor: '#FFFFFF' }}
        />
        <Stack.Screen
          name="visits/new"
          options={{ title: 'Add Visit', presentation: 'modal', headerStyle: { backgroundColor: '#1A6B8A' }, headerTintColor: '#FFFFFF' }}
        />
        <Stack.Screen
          name="visits/edit/[visitId]"
          options={{ title: 'Edit Visit', presentation: 'modal', headerStyle: { backgroundColor: '#1A6B8A' }, headerTintColor: '#FFFFFF' }}
        />
        <Stack.Screen
          name="search"
          options={{ title: 'Search', headerStyle: { backgroundColor: '#1A6B8A' }, headerTintColor: '#FFFFFF' }}
        />
        <Stack.Screen
          name="member/[memberId]"
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name="members/new"
          options={{ title: 'Add Member', presentation: 'modal', headerStyle: { backgroundColor: '#1A6B8A' }, headerTintColor: '#FFFFFF' }}
        />
        <Stack.Screen
          name="members/edit/[memberId]"
          options={{ title: 'Edit Member', presentation: 'modal', headerStyle: { backgroundColor: '#1A6B8A' }, headerTintColor: '#FFFFFF' }}
        />
      </Stack>
    </PaperProvider>
  );
}

const styles = StyleSheet.create({
  splash: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  splashTitle: {
    color: '#1A6B8A',
    fontWeight: '700',
    marginTop: 8,
  },
  splashSub: {
    color: '#757575',
  },
  splashSpinner: {
    marginTop: 32,
  },
});
