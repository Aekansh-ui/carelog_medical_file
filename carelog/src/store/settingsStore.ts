import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface SettingsState {
  currency: string;
  notificationsEnabled: boolean;
  reminderTime: string;
  appLockEnabled: boolean;
  isLoaded: boolean;
  load: () => Promise<void>;
  setSetting: (key: string, value: unknown) => Promise<void>;
}

const STORAGE_KEY = '@CareLog_settings';

export const useSettingsStore = create<SettingsState>((setState) => ({
  currency: 'INR',
  notificationsEnabled: true,
  reminderTime: '09:00',
  appLockEnabled: false,
  isLoaded: false,

  load: async () => {
    const raw = await AsyncStorage.getItem(STORAGE_KEY);
    if (raw) {
      const saved = JSON.parse(raw);
      setState({ ...saved, isLoaded: true });
    } else {
      setState({ isLoaded: true });
    }
  },

  setSetting: async (key, value) => {
    setState((prev) => {
      const updated = { ...prev, [key]: value };
      AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
      return updated;
    });
  },
}));
