<template>
  <button
    class="button"
    :class="{ disabled: isDisabled, loading: isLoading }"
    :disabled="isDisabled"
    @click.stop="handleClick($event)"
  >
    <slot name="icon" />
    <div class="button-text">{{ text }}</div>
    <div v-if="isLoading" class="loading-icon">
      <Icon :name="'line-md:loading-twotone-loop'" />
    </div>
  </button>
</template>
<script setup lang="ts">

export type TButtonProps = {
  text: string;
  isLoading?: boolean;
  isDisabled?: boolean;
};
const props = withDefaults(defineProps<TButtonProps>(), {
  isLoading: false,
  isDisabled: false,
});

const emit = defineEmits<{
  (e: "click"): void;
}>();

const handleClick = (event) => {
  if (props.isLoading || props.isDisabled) {
    return;
  }

  emit("click", event);
};
</script>
<style lang="scss" scoped>
.button {
  padding: 10px 16px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  gap: 8px;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  transition: filter 200ms;
  outline: none;

  .loading-icon {
    display: flex;
    align-items: center;
  }

  &.disabled {
    background-color: $color-gray-400;
    cursor: default;
  }

  &.loading {
    cursor: default;
  }

  &:hover:not(.disabled, .loading) {
    filter: brightness(0.96);
  }
}
</style>
