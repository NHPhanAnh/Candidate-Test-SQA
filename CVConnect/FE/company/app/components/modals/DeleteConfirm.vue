<template>
  <div class="delete-confirm">
    <div class="body">
      <div class="icon">
        <Icon name="fluent:warning-24-filled" class="warning-icon"></Icon>
      </div>
      <div class="text" v-html="message">
      </div>
    </div>
    <div class="footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  deleteList: string[];
};

const props = defineProps<TProps>();

const message = computed(() => {
  if (props.deleteList.length == 1) {
    return `<strong>${props.deleteList}</strong> sẽ bị xóa bỏ.\nHành động xóa bỏ là <strong>vĩnh viễn</strong> và <strong>không thể khôi phục</strong> được. Bạn có chắc chắn muốn xóa?`;
  }
  return `<strong>${props.deleteList.length} mục</strong> sẽ bị xóa bỏ.\nHành động xóa bỏ là <strong>vĩnh viễn</strong> và <strong>không thể khôi phục</strong> được. Bạn có chắc chắn muốn xóa?`;
});
</script>
<style lang="scss" scoped>
.delete-confirm {
  display: flex;
  flex-direction: column;

  .body {
    display: flex;
    flex-direction: row;
    align-items: center;
    margin-bottom: 12px;
    .icon {
      font-size: 32px;
      padding: 4px 4px 4px 0px;
      color: $color-primary-400;
      margin-right: 4px;
      .warning-icon {
        display: block;
      }
    }
    .text {
      color: $text-light;
      font-size: 13px;
      line-height: 20px;
      white-space: pre-line;
    }
  }

  .footer {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;
    justify-content: flex-end;

    :deep(.modal-delete-submit) {
      background-color: $color-primary-400;
      color: $text-dark;

      padding: 4px 14px 4px 14px;

      .button-text {
        font-size: 14px;
      }
    }
  }
}
</style>
