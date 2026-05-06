import type { FILTER_TAB } from "~/const/notification";

export type TNotificationFilterTab =
  (typeof FILTER_TAB)[keyof typeof FILTER_TAB];

export type TNotification = {
  id: string;
  title: string;
  message: string;
  redirectUrl: string;
  isRead: boolean;
  createdAt: number;
};
