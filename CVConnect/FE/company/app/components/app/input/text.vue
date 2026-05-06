<template>
  <div class="text-input" :class="{ disabled: isDisabled }">
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
      <slot name="icon"></slot>
      <div v-if="required" class="required">Bắt buộc</div>
    </div>
    <div v-if="desc" class="desc">
      {{ desc }}
    </div>
    <div :class="{ error: error }" class="input-wrapper">
      <div class="input" :class="{ disabled: isDisabled }">
        <slot name="input-icon"></slot>
        <input
          :disabled="isDisabled"
          :maxlength="maxLength"
          :value="value"
          :type="isSecured && isTextHidden ? 'password' : 'text'"
          :placeholder="placeholder"
          :class="{ disabled: isDisabled }"
          @input="updateValue"
          @blur="emit('blur')"
          @keydown.enter="emit('enter')"
          @focus="emit('focus')"
        />
        <Icon
          v-if="isSecured"
          class="secure-toggle"
          :name="isTextHidden ? 'mdi:eye-off-outline' : 'mdi:eye-outline'"
          @click="() => (isTextHidden = !isTextHidden)"
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
  label: string;
  desc?: string;
  required?: boolean;
  value: string;
  error: string;
  isSecured?: boolean;
  isDisabled?: boolean;
  maxLength?: number;
  placeholder?: string;
  showError?: boolean;
  tooltip?: string;
  slimError?: boolean;
};

const emit = defineEmits<{
  (e: "input", value: string): void;
  (e: "blur" | "enter" | "focus"): void;
}>();

const props = withDefaults(defineProps<TInputTextProps>(), {
  desc: "",
  required: false,
  isSecured: false,
  isDisabled: false,
  maxLength: 80,
  showError: true,
  tooltip: "",
  placeholder: "",
  slimError: false,
});

const { label, desc, required, value, isDisabled, isSecured } = toRefs(props);
const updateValue = (event: Event) => {
  if (isDisabled.value) {
    return;
  }

  const value = (event.target as HTMLInputElement)?.value || "";

  emit("input", isSecured.value ? value : value.trimStart());
};
const isTextHidden = ref(true);
</script>
<style lang="scss" scoped>
.text-input {
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
    margin-top: 1px;
    margin-bottom: 1px;
    transition-duration: 200ms;

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
      gap: 8px;
      transition-duration: 200ms;
      display: flex;
      align-items: center;
      flex-direction: row;
      color: $text-light;

      .secure-toggle {
        cursor: pointer;
      }

      input {
        flex: 1;
        font-size: 16px;
        outline: none;
        border: none;

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
