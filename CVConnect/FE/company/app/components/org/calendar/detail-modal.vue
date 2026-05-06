<template>
  <UModal
    v-model:open="isOpen"
    title="Chi tiết lịch hẹn"
    :ui="{ content: 'min-w-[720px]' }"
  >
    <template #body>
      <div v-if="isLoading" class="spinner">
        <AppSpinnerHalfCircle />
      </div>
      <div v-else class="body">
        <OrgCalendarDetailModalLeft :detail="detail" />
        <OrgCalendarDetailModalRight :detail="detail" />
      </div>
    </template>
    <template #footer>
      <div class="modal-footer">
        <AppButton class="submit-btn btn" :text="'OK'" @click="handleCancel" />
      </div>
    </template>
  </UModal>
</template>
<script setup lang="ts">
type TProps = {
  modelValue: any;
  targetId: any;
};

const { getScheduleDetail } = useCalendarApi();
const props = defineProps<TProps>();

const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const isLoading = ref<boolean>(false);

const detail = ref<any>({});

function handleCancel() {
  emits("update:modelValue", false);
}

watch(
  () => props.modelValue,
  async (newVal) => {
    if (!newVal) {
      // clear everything
      detail.value = {};
    } else {
      isLoading.value = true;
      const res = await getScheduleDetail(props.targetId.calendarId, props.targetId.candidateInfoId);
      detail.value = res.data;
      isLoading.value = false;
    }
  },
);
</script>
<style lang="scss" scoped>
.spinner {
  display: flex;
  flex-direction: row;
  height: 240px;
  align-items: center;
  justify-content: center;
}
.body {
  display: flex;
  flex-direction: row;
  gap: 8px;
  height: 100%;
  max-height: 65vh;
}

.modal-footer {
  width: 100%;
  display: flex;
  flex-direction: row;
  gap: 8px;
  justify-content: flex-end;
}

.btn {
  font-size: 14px;
  padding: 6px 12px;
  min-width: 64px;

  &.cancel-btn {
    border: 1px solid $color-primary-500;
    color: $color-primary-500;
  }

  &.submit-btn {
    background-color: $color-primary-500;
    border: 1px solid $color-primary-500;
    color: $text-dark;

    &.disabled {
      background-color: $color-gray-400;
      border: 1px solid $color-gray-400;
    }
  }
}
</style>
