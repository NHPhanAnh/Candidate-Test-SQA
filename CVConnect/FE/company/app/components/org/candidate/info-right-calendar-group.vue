<template>
  <div class="calendar-group">
    <div class="header">
      {{ props.labelDate }}
    </div>
    <div class="list">
      <div
        v-for="schedule of props.list"
        :key="schedule.calendarId"
        class="schedule-item"
        @click="() => handleClick(schedule)"
      >
        <div class="time">
          {{ timeLabel(schedule.timeFrom, schedule.timeTo) }}
        </div>
        <div class="info">
          <div class="row">
            <div class="type">
              <Icon name="material-symbols:calendar-month" />{{
                schedule.calendarType.displayName
              }}
            </div>
            <div class="process chip">{{ schedule.jobAdProcess.name }}</div>
          </div>
          <div class="sub">
            <div class="name">
              <Icon name="material-symbols:person-add-outline" />{{
                schedule.creator.fullName
              }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  labelDate: any;
  quant: any;
  list: any;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "scheduleClick", payload: any): void;
}>();

const timeLabel = computed(() => {
  return (from: any, to: any) => {
    return `${String(from[0]).padStart(2, "0")}:${String(from[1]).padStart(2, "0")} - ${String(to[0]).padStart(2, "0")}:${String(to[1]).padStart(2, "0")}`;
  };
});

function handleClick(schedule: any) {
  emits("scheduleClick", schedule);
}
</script>
<style lang="scss" scoped>
.calendar-group {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .header {
    font-size: 16px;
    font-weight: 600;

    .counting {
      margin-left: 8px;
      color: $color-gray-400;
      font-weight: 400;
      font-size: 14px;
    }
  }

  .iconify {
    display: block;
    height: 16px;
    width: 16px;
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;
    justify-content: space-between;
    flex: 1;
  }

  .list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    .schedule-item {
      display: flex;
      flex-direction: row;
      gap: 8px;
      padding: 8px;
      border-radius: 8px;
      background-color: $color-gray-50;
      font-size: 14px;
      transition-duration: 300ms;
      cursor: pointer;

      &:hover {
        @include box-shadow;
      }

      .time {
        font-weight: 600;
      }

      .info {
        display: flex;
        flex-direction: column;
        gap: 4px;
        flex: 1;

        .name {
          display: flex;
          flex-direction: row;
          gap: 8px;
          align-items: center;
        }

        .type,
        .process {
          display: flex;
          flex-direction: row;
          gap: 8px;
          align-items: center;
        }

        .sub {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }
      }
    }
  }

  .chip {
    border-radius: 4px;
    padding: 0px 6px;
    font-size: 12px;
    height: 21px;
    display: flex;
    align-items: center;
    font-weight: 500;
    border: 1px solid $color-gray-300;
  }
}
</style>
