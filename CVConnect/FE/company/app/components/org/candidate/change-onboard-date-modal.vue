<template>
  <UModal
    v-model:open="isOpen"
    title="Đổi ngày onboard"
    :ui="{ content: 'max-w-[840px]' }"
  >
    <template #body>
      <div class="body" id="modal-body">
        <AppInputDatepicker
          :label="'Ngày onboard'"
          :required="true"
          :value="formInput.onboardDate"
          :hide-navigations="['seconds']"
          :enable-time-picker="true"
          :error="''"
          :slim-error="true"
          :is-teleport="'html'"
          :placeholder="'Chọn ngày'"
          :is-range="false"
          class="onboard-datepicker"
          @input="handleInput('onboardDate', $event)"
        />
      </div>
    </template>
    <template #footer>
      <div class="modal-footer">
        <AppButton
          class="cancel-btn btn"
          :text="'Đóng'"
          @click="handleCancel"
        />
        <AppButton
          class="submit-btn btn"
          :text="'Xác nhận'"
          :is-disabled="isSubmitDisabled"
          :is-loading="isLoading"
          @click="handleSubmit"
        />
      </div>
    </template>
  </UModal>
</template>
<script setup lang="ts">
type TProps = {
  modelValue: boolean;
  changeDateTarget: Record<string, any> | null;
};

const { changeOnboardDate } = useCandidateApi();

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

const formInput = ref<Record<string, any>>({
  onboardDate: undefined,
});

function handleInput(key: string, value: any) {
  formInput.value[key] = value;
}

function handleCancel() {
  emits("update:modelValue", false);
}

const isSubmitDisabled = computed(() => {
  if (!formInput.value.onboardDate) {
    return true;
  }

  return false;
});

async function handleSubmit() {
  isLoading.value = true;
  const success = await changeOnboardDate(props.changeDateTarget?.id, toUtcDateWithTime(formInput.value.onboardDate));
  isLoading.value = false;

  if (success) {
    emits("submit");
  }
}

watch(
  () => props.modelValue,
  (newVal) => {
    if (!newVal) {
      // clear everything
      formInput.value = {
        onboardDate: undefined,
      };
    }
  },
);
</script>
<style lang="scss" scoped>
.body {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .divider {
    width: 100%;
    display: block;
    height: 1px;
    background-color: $color-gray-200;
  }

  :deep(textarea) {
    max-height: 90px;
  }

  .process-section {
    display: flex;
    flex-direction: column;
    gap: 8px;

    .label {
      font-size: 14px;
      color: $text-light;
      font-weight: 500;
    }

    .required {
      color: $color-danger;
      margin-left: 4px;
    }

    .process-list {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .process-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
      height: 39px;
      cursor: pointer;

      &.disabled {
        cursor: default;
        span {
          color: $color-gray-400;
        }

        input[type="radio"] {
          cursor: default;
          &:hover {
            border-color: $color-gray-400;
          }
        }
      }

      .left {
        display: flex;
        flex-direction: row;
        gap: 8px;
        align-items: center;
      }

      .right {
        .date-time {
          font-size: 14px;
          color: $text-light;
        }
      }

      input[type="radio"] {
        appearance: none;
        width: 16px;
        height: 16px;
        border-radius: 50%;
        border: 1px solid $color-gray-400;
        background-color: #fff;
        cursor: pointer;

        &:checked {
          appearance: auto;
          accent-color: $color-primary-500;
        }

        &:hover {
          border-color: $color-primary-500;
        }

        &:focus {
          outline: none;
        }
      }

      span {
        font-size: 14px;
        color: $text-light;
      }
    }
  }

  .required {
    font-size: 12px;
    font-style: italic;
    color: $color-danger;
    margin-left: 8px;
  }

  .preview-button {
    display: flex;
    flex-direction: row;
    gap: 8px;
    cursor: pointer;
    color: $text-light;
    font-size: 14px;

    &.no-preview {
      color: $color-gray-400;
      cursor: default;
    }

    .iconify {
      display: block;
      font-size: 20px;
      width: 20px;
    }
  }

  .checkbox {
    max-width: fit-content;
    :deep(label) {
      color: $text-light;
      font-weight: 400;
      cursor: pointer !important;
    }
    :deep(button) {
      cursor: pointer !important;
    }
  }

  :deep(.text-input) {
    flex: 1;
    .input {
      padding: 4px 6px;
      input {
        font-size: 14px;
      }
    }
  }

  .editor {
    flex: 1;
    .label {
      font-size: 14px;
      color: $text-light;
      margin-bottom: 4px;
    }
  }

  .editor,
  .placeholders {
    display: flex;
    flex-direction: column;
    :deep(.iconify) {
      display: block;
      align-self: center;
    }
    .label {
      font-size: 14px;
      margin-bottom: 4px;
      color: $text-light;
    }
  }

  .ProseMirror {
    max-height: 35vh;
    overflow: auto;
  }

  .placeholders {
    flex: 1;
    max-width: fit-content;
    .placeholder-list {
      display: flex;
      flex-direction: column;
      gap: 4px;
      overflow-y: auto;
      max-height: 35vh;

      .placeholder {
        padding: 4px 6px;
        font-size: 13px;
        font-weight: 500;
        border-radius: 4px;
        border: 1px solid $color-gray-300;
        cursor: grabbing;
        max-width: 240px;
      }
    }
  }
  :deep(.template-body) {
    padding: 8px;
    border-radius: 6px;
    border: 1px solid $color-gray-300;
    font-size: 14px;
    min-height: 120px;
    .chip {
      border: 1px solid $color-gray-300;
      background-color: #ffffff;
      padding: 1px 3px;
      border-radius: 4px;
      font-size: 13px;
    }
  }

  .line {
    display: flex;
    flex-direction: row;
    gap: 8px;
    justify-content: space-between;
    flex: 1;
  }
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

// #teleport-target {
//   position: fixed;
//   height: 100vh;
//   width: 100vw;
//   background-color: blue;
//   top: 0px;
//   left: 0px;
//   z-index: 999999999;
// }
</style>
