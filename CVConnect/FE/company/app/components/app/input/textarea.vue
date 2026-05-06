<template>
  <div class="textarea-input" :class="{ disabled: isDisabled }">
    <!-- Label -->
    <div class="label">
      <div class="name">
        <span>{{ props.label }}</span>
        <UTooltip v-if="tooltip" :text="props.tooltip">
          <Icon name="mdi:help-circle-outline" class="tooltip" />
        </UTooltip>
      </div>
      <div v-if="props.required" class="required">Bắt buộc</div>
    </div>

    <div v-if="props.desc" class="desc">
      {{ props.desc }}
    </div>

    <div :class="{ error: !!props.error }" class="input-wrapper">
      <div class="input" :class="{ disabled: props.isDisabled }">
        <UTextarea
          v-model="localValue"
          variant="none"
          class="w-full"
          :disabled="props.isDisabled"
          :placeholder="props.placeholder"
          autoresize
        />
        <Icon
          v-if="props.isSecured"
          class="secure-toggle"
          :name="isTextHidden ? 'mdi:eye-off-outline' : 'mdi:eye-outline'"
          @click="isTextHidden = !isTextHidden"
        />
      </div>
    </div>

    <!-- Error message -->
    <div v-if="!props.slimError" class="error-message">
      {{ props.showError ? error : "" }}
    </div>
  </div>
</template>

<script setup lang="ts">
export type TInputTextProps = {
  modelValue?: string;
  label?: string;
  desc?: string;
  tooltip?: string;
  placeholder?: string;
  row?: number;
  error?: string;
  showError?: boolean;
  slimError?: boolean;
  required?: boolean;
  isDisabled?: boolean;
  isSecured?: boolean;
};

const props = withDefaults(defineProps<TInputTextProps>(), {
  modelValue: "",
  label: "",
  desc: "",
  tooltip: "",
  placeholder: "",
  error: "",
  showError: true,
  row: 4,
  slimError: false,
  required: false,
  isDisabled: false,
  isSecured: false,
});

const emit = defineEmits<{
  (e: "update:modelValue", value: string): void;
}>();

// Handle v-model binding
const localValue = computed({
  get: () => props.modelValue,
  set: (val: string) => emit("update:modelValue", val),
});

// Secure toggle (if needed)
const isTextHidden = ref(true);
</script>

<style lang="scss" scoped>
.textarea-input {
  display: flex;
  flex-direction: column;
  gap: 4px;
  width: 100%;

  &.disabled {
    cursor: default;
  }

  .label {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;

    .name {
      font-size: 14px;
      color: $text-light;
      display: flex;
      align-items: center;

      .tooltip {
        margin-left: 4px;
        cursor: pointer;
      }
    }
    .required {
      font-size: 12px;
      font-style: italic;
      color: $color-danger;
    }
  }

  .desc {
    font-size: 12px;
    color: $color-gray-500;
  }

  .input-wrapper {
    border-radius: 12px;
    // border: 3px solid transparent;
    transition-duration: 200ms;

    &.error {
      // border: 3px solid rgba($color-danger, 0.3);

      .input {
        border: 1px solid rgba($color-danger, 1);
      }
    }

    .input {
      border-radius: 10px;
      border: 1px solid rgba($color-primary-800, 0.1);
      display: flex;
      align-items: center;
      color: $text-light;
      transition: border 200ms;

      :deep(textarea) {
        border: none;
        &::placeholder {
          color: $color-gray-300;
        }

        &:disabled {
          opacity: 100%;
          cursor: default;
        }
      }

      .secure-toggle {
        cursor: pointer;
        margin-left: 8px;
      }

      &:hover:not(.disabled),
      &:focus-within:not(.disabled) {
        border: 1px solid rgba($color-primary-400, 1);
      }

      &.disabled {
        border: 1px solid $color-gray-300;
      }
    }
    //
    // &:focus-within {
    //   border: 3px solid rgba($color-primary-400, 0.4);
    // }
  }

  .error-message {
    min-height: 16px;
    color: $color-danger;
    font-size: 12px;
    line-height: 16px;
  }
}
</style>
