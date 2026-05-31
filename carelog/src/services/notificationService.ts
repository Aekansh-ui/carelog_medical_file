import * as Notifications from 'expo-notifications';
import { parseISO, subDays, setHours, setMinutes } from 'date-fns';

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

async function requestPermissions(): Promise<boolean> {
  const { status } = await Notifications.requestPermissionsAsync();
  return status === 'granted';
}

function at9am(date: Date): Date {
  return setMinutes(setHours(date, 9), 0);
}

export const notificationService = {
  /**
   * Schedules D-1 (day before) and D-0 (day of) notifications at 09:00 AM.
   * Returns the OS notification identifiers.
   */
  async scheduleFollowUp(
    visitId: string,
    followUpDate: string,
  ): Promise<{ d1Id: string; d0Id: string }> {
    const granted = await requestPermissions();
    if (!granted) return { d1Id: '', d0Id: '' };

    const followUp = parseISO(followUpDate);
    const now = new Date();
    const d1Trigger = at9am(subDays(followUp, 1));
    const d0Trigger = at9am(followUp);

    const d1Id =
      d1Trigger > now
        ? await Notifications.scheduleNotificationAsync({
            content: {
              title: 'Follow-up Tomorrow',
              body: 'You have a medical follow-up appointment tomorrow.',
              data: { visitId },
            },
            trigger: { date: d1Trigger } as any,
          })
        : '';

    const d0Id =
      d0Trigger > now
        ? await Notifications.scheduleNotificationAsync({
            content: {
              title: 'Follow-up Today',
              body: 'You have a medical follow-up appointment today.',
              data: { visitId },
            },
            trigger: { date: d0Trigger } as any,
          })
        : '';

    return { d1Id, d0Id };
  },

  /** Cancels both the D-1 and D-0 notifications for a reminder. */
  async cancelNotifications(d1Id: string, d0Id: string): Promise<void> {
    if (d1Id) await Notifications.cancelScheduledNotificationAsync(d1Id);
    if (d0Id) await Notifications.cancelScheduledNotificationAsync(d0Id);
  },
};
