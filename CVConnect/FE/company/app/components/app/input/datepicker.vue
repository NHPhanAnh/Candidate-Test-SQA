<template>
  <div class="datepicker-input">
    <div v-if="props.label" class="label">
      <span v-if="props.label" class="text">{{ props.label }}</span>
      <slot name="icon"></slot>
      <span v-if="props.required" class="required">Bắt buộc</span>
    </div>
    <VueDatePicker
      :hide-navigation="props.hideNavigations"
      :enable-time-picker="props.enableTimePicker"
      :range="props.isRange"
      class="date-input"
      :class="{ disabled: props.isDisabled, error: props.error }"
      :teleport="props.isTeleport"
      :model-value="props.value"
      :placeholder="props.placeholder"
      :disabled="props.isDisabled"
      @update:model-value="handleInput($event)"
      @cleared="emits('clear')"
      @closed="emits('close')"
    />
    <div v-if="!props.slimError" class="error-message">{{ error }}</div>
  </div>
</template>
<script lang="ts" setup>
type TProps = {
  label?: string;
  required?: boolean;
  value: any;
  error?: string;
  isDisabled?: boolean;
  placeholder?: string;
  isRange?: boolean;
  slimError?: boolean;
  isTeleport?: boolean | string;
  hideNavigations?: string[];
  enableTimePicker?: boolean;
};

const props = withDefaults(defineProps<TProps>(), {
  label: "",
  required: false,
  error: "",
  placeholder: "Mời chọn ngày",
  isDisabled: false,
  isRange: false,
  slimError: false,
  isTeleport: true,
  hideNavigations: () => ["time", "minutes", "hours", "seconds"],
  enableTimePicker: false,
});

const emits = defineEmits<{
  (e: "input", value: any): void;
  (e: "clear" | "close"): void;
}>();

function handleInput(value: any) {
  emits("input", value);
}
</script>
<style lang="scss" scoped>
.datepicker-input {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;

  .label {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;
    width: fit-content;

    .text {
      font-size: 14px;
      line-height: 21px;
    }

    .required {
      font-size: 12px;
      font-style: italic;
      color: $color-danger;
    }
  }

  .error-message {
    min-height: 16px;
    display: inline-block;
    color: $color-danger;
    font-size: 12px;
    line-height: 16px;
  }

  :deep(.date-input) {
    &.error {
      .dp__input {
        border: 1px solid $color-danger !important;
      }
    }
    &:disabled {
      .dp__input {
        border: 1px solid rgba($color-gray-300, 1) !important;
        cursor: default;
        opacity: 100%;
      }
    }
  }

  :deep(.dp__input_wrap) {
    input::placeholder {
      color: $color-gray-500;
      font-weight: 400;
      font-size: 14px;
    }
    .dp__input {
      margin: 1px 0px;
      border-radius: 10px;
      padding-top: 6px;
      padding-bottom: 6px;
      font-weight: 400 !important;
      opacity: 100%;
      color: $text-light;
      font-size: 14px;
      line-height: 20px;
      background-color: white !important;

      border: 1px solid rgba($color-primary-800, 0.1) !important;

      &:hover:not(:disabled) {
        border: 1px solid rgba($color-primary-400, 1) !important;
      }

      &::placeholder {
        font-size: 14px;
        line-height: 21px;
        color: $color-gray-300;
        font-weight: 400 !important;
        opacity: 100%;
      }

      &.error {
        border: 1px solid $color-danger !important;
      }
      &:disabled {
        border: 1px solid rgba($color-gray-300, 1) !important;
        cursor: default;
        opacity: 100%;
      }
    }
  }
}
</style>
