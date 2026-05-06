<template>
  <div class="notifications-list-wrapper">
    <div class="filters">
      <div class="left">
        <div
          class="tab"
          :class="{ active: filterTab === FILTER_TAB.ALL }"
          @click="handleFilterChange(FILTER_TAB.ALL)"
        >
          Tất cả
        </div>
        <div
          class="tab"
          :class="{ active: filterTab === FILTER_TAB.UNREAD }"
          @click="handleFilterChange(FILTER_TAB.UNREAD)"
        >
          Chưa đọc
        </div>
        <div
          class="tab"
          :class="{ active: filterTab === FILTER_TAB.READ }"
          @click="handleFilterChange(FILTER_TAB.READ)"
        >
          Đã đọc
        </div>
      </div>
      <div class="right">
        <div class="filter-wrapper">
          <div
            class="filter-button"
            @click="isDateFilterDropdownShow = !isDateFilterDropdownShow"
          >
            <Icon name="material-symbols:filter-alt" />
          </div>
          <div v-if="isDateFilterDropdownShow" class="dropdown">
            <div class="body">
              <AppInputDatepicker
                :label="'Từ'"
                :required="false"
                :value="dateFilter.from"
                :error="''"
                :placeholder="''"
                @input="handleInput('from', $event)"
              />
              <AppInputDatepicker
                :label="'Đến'"
                :required="false"
                :value="dateFilter.to"
                :error="''"
                :placeholder="''"
                @input="handleInput('to', $event)"
              />
            </div>
            <div class="footer">
              <AppButton
                class="cancel-button"
                :text="'Đóng'"
                @click="isDateFilterDropdownShow = false"
              />
              <AppButton
                class="cancel-button"
                :text="'Đặt lại'"
                @click="handleResetDateFilter"
              />
              <AppButton
                class="submit-button"
                :text="'OK'"
                @click="handleSubmitDateFilter"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    <div
      v-if="isMarkAllShow"
      class="mark-all-as-read"
      @click="handleMarkAllRead"
    >
      Đánh dấu đã đọc tất cả
    </div>
    <div class="content">
      <NotificationCard
        v-for="notification of filteredNotifications"
        :key="notification.id"
        :title="notification.title"
        :message="notification.message"
        :created-at="notification.createdAt"
        :is-read="notification.isRead"
        @click="handleClickNoti(notification)"
      />
      <div v-if="!isFetching && !notifications.length" class="no-data">
        <AppNoData :text="'Không có thông báo'" />
      </div>
      <div v-if="isFetching" class="spinner">
        <AppSpinnerHalfCircle />
      </div>
    </div>

    <div class="footer">
      <div
        v-if="!isFetching && notifications.length && isShowMoreShow"
        class="fetch-more"
        @click="fetchNotifications"
      >
        Hiển thị thêm
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { vOnClickOutside } from "@vueuse/components";
import { cloneDeep } from "lodash";
import { io } from "socket.io-client";
import { FILTER_TAB } from "~/const/notification";
import { SOCKET_ENDPOINT, SOCKET_EVENT } from "~/const/socket";
import type {
  TNotification,
  TNotificationFilterTab,
} from "~/types/notification";
const authStore = useAuthStore();
const { token } = storeToRefs(authStore);
const { getMyNotification, getUnreadQuantity, markAllRead, markRead } =
  useNotificationApi();
const router = useRouter();

const connection = ref<any>(null);
const isDateFilterDropdownShow = ref<boolean>(false);
const filterTab = ref<TNotificationFilterTab>(FILTER_TAB.ALL);
const isFetching = ref<boolean>(true);
const params = ref<Record<string, any>>({
  pageIndex: 0,
  pageSize: 20,
});
const notifications = ref<TNotification[]>([]);
const totalNotifications = ref<number>(0);
const unread = ref<number>(0);
const dateFilter = ref<Record<string, any>>({
  from: undefined,
  to: undefined,
});

onBeforeMount(async () => {
  fetchNotifications();

  const res = await getUnreadQuantity();
  unread.value = res.data;
});

onMounted(() => {
  connect();
});

const isMarkAllShow = computed(() => {
  return unread.value > 0;
});

const isShowMoreShow = computed(() => {
  return totalNotifications.value != notifications.value.length;
});

const filteredNotifications = computed(() => {
  if (filterTab.value == FILTER_TAB.ALL) {
    return notifications.value;
  }
  if (filterTab.value == FILTER_TAB.READ) {
    return notifications.value.filter(
      (notification) => notification.isRead == true,
    );
  }
  return notifications.value.filter(
    (notification) => notification.isRead == false,
  );
});

function notifyUser() {
  try {
    const audio = new Audio("/ping.mp3");
    audio.volume = 0.8;
    audio.play().catch((err) => {
      console.error(err);
    });
  } catch (err) {
    console.error(err);
  }
}

function handleInput(key: string, value: any) {
  console.log(key, value);
  dateFilter.value[key] = value;
}

function connect() {
  if (connection.value) {
    connection.value.disconnect();
  }

  connection.value = io(SOCKET_ENDPOINT, {
    path: "/socket",
    transports: ["websocket"],
    query: { token: token.value },
  });
  connection.value.on(SOCKET_EVENT.NOTIFY, (data: TNotification) => {
    console.log("on notify", data);
    notifications.value = [data, ...notifications.value];
    unread.value += 1;
    totalNotifications.value += 1;
    notifyUser();
  });
  connection.value.on(SOCKET_EVENT.UNREAD_NOTIFY, (data: any) => {
    console.log("on unread", data);
    unread.value = data.quantityUnread;
    if (data.quantityUnread == 0) {
      notifications.value = notifications.value.map((notification) => {
        return {
          ...notification,
          isRead: true,
        };
      });
    } else {
      notifications.value = notifications.value.map((notification) => {
        if (notification.id != data.notificationId) {
          return notification;
        }
        return {
          ...notification,
          isRead: true,
        };
      });
    }
  });
  connection.value.on("connect", () => {
    console.log("✅ Socket connected:", connection.value.id);
  });
}

async function fetchNotifications() {
  isFetching.value = true;
  const _params = cloneDeep(params.value);
  if (filterTab.value === FILTER_TAB.READ) {
    _params.isRead = true;
  } else if (filterTab.value === FILTER_TAB.UNREAD) {
    _params.isRead = false;
  }
  if (dateFilter.value.from) {
    _params.createdAtStart = toUtcDateStart(dateFilter.value.from);
  }
  if (dateFilter.value.to) {
    _params.createdAtEnd = toUtcDateEnd(dateFilter.value.to);
  }
  const res = await getMyNotification(_params);
  if (res) {
    notifications.value = [...notifications.value, ...res.data.data];
    params.value.pageIndex += 1;
    totalNotifications.value = res.data.pageInfo.totalElements;
  }
  console.log(res);
  isFetching.value = false;
}

function handleResetDateFilter() {
  dateFilter.value = {
    from: null,
    to: null,
  };
  notifications.value = [];
  params.value.pageIndex = 0;
  fetchNotifications();
  isDateFilterDropdownShow.value = false;
}

function handleSubmitDateFilter() {
  notifications.value = [];
  params.value.pageIndex = 0;
  fetchNotifications();
  isDateFilterDropdownShow.value = false;
  console.log(dateFilter.value)
}

async function handleClickNoti(notification: TNotification) {
  const resolved = router.resolve({ path: notification.redirectUrl });
  window.open(resolved.href, "_blank");
  const res = await markRead(notification.id);
  if (res) {
    // Do something here?
  }
}

function handleFilterChange(status: TNotificationFilterTab) {
  filterTab.value = status;
  params.value = {
    pageIndex: 0,
    pageSize: 20,
  };
  notifications.value = [];
  fetchNotifications();
}

async function handleMarkAllRead() {
  const res = await markAllRead();
  if (res) {
    // do something here?
  }
}

onBeforeUnmount(() => {
  if (connection.value) {
    connection.value.disconnect();
    console.log("Socket cleaned up");
  }
});

watch(token, (newToken, oldToken) => {
  if (newToken != oldToken) {
    connect();
  }
});
watch(isDateFilterDropdownShow, (newVal) => {
  console.log(newVal);
});
</script>
<style lang="scss" scoped>
.notifications-list-wrapper {
  border-radius: 8px;
  background-color: #ffffff;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 8px 0px;
  max-height: 100%;
  height: 100%;
  .filters {
    display: flex;
    flex-direction: row;
    gap: 8px;
    padding: 0px 8px 4px 8px;
    width: 100%;
    flex-wrap: wrap;
    justify-content: space-between;

    .left {
      display: flex;
      flex-direction: row;
      gap: 8px;
      flex-wrap: wrap;
    }

    .filter-wrapper {
      position: relative;

      .dropdown {
        position: absolute;
        width: 350px;
        background-color: #ffffff;
        top: 32px;
        right: 0px;
        border: 1px solid $color-gray-300;
        @include box-shadow;
        border-radius: 6px;
        padding: 12px;
        display: flex;
        flex-direction: column;
        gap: 12px;

        .footer {
          display: flex;
          flex-direction: row;
          gap: 8px;
          justify-content: flex-end;

          .cancel-button {
            padding: 4px 6px;
            color: $color-primary-500;
            border: 1px solid $color-primary-500;
            font-size: 14px;
            min-width: 82px;
          }

          .submit-button {
            padding: 4px 6px;
            background-color: $color-primary-500;
            border: 1px solid $color-primary-500;
            font-size: 14px;
            min-width: 82px;
            color: $text-dark;
          }
        }
      }
    }

    .filter-button {
      height: 25px;
      width: 25px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 999px;
      background-color: $color-primary-500;
      cursor: pointer;

      .iconify {
        display: block;
        font-size: 18px;
        color: $text-dark;
      }
    }

    .tab {
      background-color: white;
      border-radius: 999px;
      padding: 2px 4px;
      font-size: 13px;
      border: 1px solid $color-gray-300;
      min-width: 72px;
      text-align: center;
      cursor: pointer;

      &.active {
        background-color: $color-primary-500;
        color: $text-dark;
        border: 1px solid $color-primary-500;
      }
    }
  }

  .mark-all-as-read {
    font-size: 13px;
    width: 100%;
    padding-right: 8px;
    color: $color-primary-500;
    cursor: pointer;
    text-align: right;
  }

  .content {
    @include custom-scrollbar;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    flex: 1;
    min-height: 0;
    border-top: 1px solid $color-gray-300;
    border-bottom: 1px solid $color-gray-300;
    width: 100%;

    .notification {
      display: flex;
      flex-direction: column;
      gap: 4px;
      padding: 8px 16px;
      border-top: 1px solid $color-gray-300;
      border-bottom: 1px solid $color-gray-300;
      width: 100%;

      .noti-title {
        :deep(div) {
          font-size: 13px;
        }
      }

      .noti-body {
        :deep(div) {
          font-size: 12px;
          color: $color-gray-500;
        }
      }

      .time {
        text-align: right;
        color: $color-gray-400;
        font-size: 12px;
      }
    }

    .spinner {
      :deep(.iconify) {
        display: block;
        font-size: 20px;
        height: 20px;
      }
      display: flex;
      justify-content: center;
      min-height: 64px;
      align-items: center;
    }
  }

  .footer {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: flex-end;
    width: 100%;

    padding: 0px 8px;

    .fetch-more {
      font-size: 13px;
      color: $color-primary-500;
      cursor: pointer;
    }

    .view-all {
      font-size: 13px;
      color: $color-primary-500;
      cursor: pointer;
    }
  }
}
</style>
