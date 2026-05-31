import { create } from 'zustand';
import { Reminder } from '@src/types/Reminder';
import { remindersRepository } from '@src/db/remindersRepository';
import { notificationService } from '@src/services/notificationService';

interface RemindersState {
  upcoming: Reminder[];
  past: Reminder[];
  load: () => void;
  createReminder: (visitId: string, followUpDate: string) => Promise<void>;
  deactivate: (id: string) => void;
  deleteReminder: (id: string) => void;
}

export const useRemindersStore = create<RemindersState>((set, get) => ({
  upcoming: [],
  past: [],

  load: () => {
    set({
      upcoming: remindersRepository.findUpcoming(),
      past: remindersRepository.findPast(),
    });
  },

  createReminder: async (visitId, followUpDate) => {
    const reminder = remindersRepository.create(visitId, followUpDate);
    const { d1Id, d0Id } = await notificationService.scheduleFollowUp(visitId, followUpDate);
    if (d1Id || d0Id) {
      remindersRepository.updateNotificationIds(reminder.id, d1Id, d0Id);
    }
    get().load();
  },

  deactivate: (id) => {
    remindersRepository.deactivate(id);
    get().load();
  },

  deleteReminder: (id) => {
    remindersRepository.delete(id);
    get().load();
  },
}));
