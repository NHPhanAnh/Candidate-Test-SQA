import { FILTER_TAB } from "~/const/notification";
import type {
  TNotification,
  TNotificationFilterTab,
} from "~/types/notification";

export const useNotificationStore = defineStore("notification", () => {
  const notifications = ref<TNotification[]>([]);
  const isFetching = ref<boolean>(false);
  const unread = ref<number>(0);
  const params = ref<Record<string, any>>({
    pageIndex: 0,
    pageSize: 20,
  });

  function resetStore() {
    notifications.value = [];
    isFetching.value = false;
    unread.value = 0;
    params.value = {
      pageIndex: 0,
      pageSize: 20,
    };
  }

  function setUnread(_unread: number) {
    unread.value = _unread;
  }

  function setNotifications(_notifications: TNotification[]) {
    notifications.value = _notifications;
  }

  function fetchNextPage() {
    // call api to get next page
  }

  function setFilterType(type: TNotificationFilterTab) {
    if (type === FILTER_TAB.READ) {
      params.value.isRead = true;
    } else if (type === FILTER_TAB.UNREAD) {
      params.value.isRead = false;
    } else {
      params.value.isRead = undefined;
    }
    params.value.pageIndex = 0;
    params.value.pageSize = 0;
  }

  return {};
});
