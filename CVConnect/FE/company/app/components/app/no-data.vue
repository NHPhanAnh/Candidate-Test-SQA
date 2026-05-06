<template>
  <div class="no-data">
    <!-- <Icon name="material-symbols-light:folder-limited-outline-rounded" class="icon" /> -->
    <AppNoDataNew />
    <div class="text">{{ props.text }}</div>
  </div>
</template>
<script setup lang="ts">
export type TNoDataProps = {
  text?: string;
};

const props = withDefaults(defineProps<TNoDataProps>(), {
  text: "Không có dữ liệu",
});
</script>
<style lang="scss" scoped>
.no-data {
  padding: 24px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  .icon {
    display: block;
    font-size: 64px;
    color: $color-gray-500;
  }
  .text {
    color: $color-gray-500;
  }

  :deep(svg) {
    height: 84px;
  }
}
</style>
