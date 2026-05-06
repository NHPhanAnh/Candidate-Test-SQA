<template>
  <div class="notification" :class="{'unread': !props.isRead}" @click="handleClickNoti()">
    <div class="noti-title">
      <div v-html="props.title"></div>
    </div>
    <div class="noti-body">
      <div v-html="props.message"></div>
    </div>
    <div class="time">
      {{ relativeTime }}
    </div>
  </div>
</template>
<script lang="ts" setup>
type TProps = {
  title: string,
  message: string,
  createdAt: number,
  isRead: boolean,
}

const props = defineProps<TProps>();

const emits = defineEmits<{
  (e: "click"): void;
}>();

const relativeTime = useMomentRelativeTime(props.createdAt);

function handleClickNoti() {
  emits("click");
}
</script>
<style lang="scss" scoped>
.notification {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 8px;
  border-top: 1px solid $color-gray-300;
  border-bottom: 1px solid $color-gray-300;
  cursor: pointer;

  &.unread {
    background-color: rgba($color-primary-50, 0.6);
  }

  .noti-title {
    :deep(div) {
      font-size: 14px;
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
</style>
