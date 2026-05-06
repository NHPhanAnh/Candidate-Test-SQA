<template>
  <div class="create-user-group-footer">
    <slot />
  </div>
</template>
<style lang="scss" scoped>
.create-user-group-footer {
  width: 100%;
  :deep(.buttons) {
    margin-top: 24px;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: flex-end;
    gap: 8px;

    .cancel-button,
    .submit-button {
      padding: 4px 14px 4px 14px;

      :deep(.button-text) {
        font-size: 14px;
      }
    }

    .submit-button {
      background-color: $color-primary-400;
      color: $text-dark;

      &.disabled {
        background-color: $color-gray-400;
      }
    }
    .cancel-button {
      padding: 3px 14px 3px 14px;
      background-color: white;
      color: $color-primary-400;
      border: 1px solid $color-primary-400;
    }
  }
}
</style>
