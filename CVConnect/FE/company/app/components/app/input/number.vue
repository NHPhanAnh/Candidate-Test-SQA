<template>
  <div class="number-input" :class="{ disabled: isDisabled }">
    <div v-if="props.label" class="label">
      <div class="name">
        <span>{{ label }}</span>
        <UTooltip v-if="tooltip" :text="props.tooltip">
          <Icon
            v-if="tooltip"
            name="mdi:help-circle-outline"
            class="tooltip"
          ></Icon>
        </UTooltip>
      </div>
      <div v-if="required" class="required">Bắt buộc</div>
    </div>
    <div v-if="desc" class="desc">
      {{ desc }}
    </div>
    <div :class="{ error: error }" class="input-wrapper">
      <div class="input" :class="{ disabled: isDisabled }">
        <input
          :disabled="isDisabled"
          :max="props.maxValue"
          :min="props.minValue"
          type="text"
          :value="displayValue"
          :placeholder="placeholder"
          :class="{ disabled: isDisabled }"
          @input="onInput"
          @blur="onBlur"
        />
      </div>
    </div>
    <div v-if="!props.slimError" class="error-message">
      {{ props.showError ? error : "" }}
    </div>
  </div>
</template>
<script setup lang="ts">
export type TInputTextProps = {
  label?: string;
  desc?: string;
  required?: boolean;
  value: number | string | null | undefined;
  error?: string;
  isDisabled?: boolean;
  maxValue?: number;
  minValue?: number;
  placeholder?: string;
  showError?: boolean;
  tooltip?: string;
  slimError?: boolean;
};

const emit = defineEmits<{
  (e: "input", value: any): void;
  (e: "blur"): void;
}>();

const props = withDefaults(defineProps<TInputTextProps>(), {
  desc: "",
  label: "",
  required: false,
  isSecured: false,
  isDisabled: false,
  error: "",
  maxValue: undefined,
  minValue: undefined,
  showError: true,
  tooltip: "",
  placeholder: "",
  slimError: false,
});

const { label, desc, required, value, isDisabled } = toRefs(props);

const displayValue = computed(() => {
  if (value.value === null || value.value === "" || isNaN(Number(value.value)))
    return "";
  return new Intl.NumberFormat("en-US").format(Number(value.value));
});

function onInput(event: Event) {
  if (isDisabled.value) return;

  const raw = (event.target as HTMLInputElement).value;
  const numericString = raw.replace(/[^\d.-]/g, "");
  const numericValue = numericString ? Number(numericString) : null;

  emit("input", numericValue);
}
</script>
<style lang="scss" scoped>
.number-input {
  display: flex;
  flex-direction: column;
  gap: 4px;

  &.isDisabled {
    cursor: default;
  }

  .label {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;
    width: fit-content;
    .name {
      font-size: 14px;
      color: $text-light;
      display: flex;
      align-items: center;

      .tooltip {
        margin-left: 4px;
        cursor: pointer;
        display: inline-block;
      }
    }
    .required {
      font-size: 12px;
      font-style: italic;
      color: $color-danger;
    }
  }
  .input-wrapper {
    border-radius: 12px;
    display: flex;
    transition-duration: 200ms;
    margin-top: 1px;
    margin-bottom: 1px;

    &.error {
      // border: 3px solid rgba($color-danger, 0.3);
      // &:focus-within {
      //   border: 3px solid rgba($color-danger, 0.3);
      // }
      .input {
        border: 1px solid rgba($color-danger, 1);

        &:hover,
        &:focus-within {
          border: 1px solid rgba($color-danger, 1);
        }
      }
    }

    .input {
      border-radius: 10px;
      padding: 8px 10px;
      border: 1px solid rgba($color-primary-800, 0.1);
      flex: 1;
      transition-duration: 200ms;
      display: flex;
      align-items: center;
      flex-direction: row;
      color: $text-light;
      min-width: 0;

      .secure-toggle {
        cursor: pointer;
      }

      input {
        flex: 1;
        font-size: 16px;
        outline: none;
        border: none;
        min-width: 0;

        &::placeholder {
          color: $color-gray-300;
        }
      }

      &.disabled {
        border: 1px solid rgba($color-gray-300, 1);
      }

      &:hover:not(.disabled),
      &:focus-within:not(.disabled) {
        border: 1px solid rgba($color-primary-400, 1);
      }
    }
    // &:focus-within {
    //   border: 3px solid rgba($color-primary-400, 0.4);
    // }
  }

  .error-message {
    min-height: 16px;
    display: inline-block;
    color: $color-danger;
    font-size: 12px;
    line-height: 16px;
  }
}
</style>
