<template>
  <div>
    <IndustryCreateModal v-model="isCreateModalOpen" />
  </div>
</template>
<script setup lang="ts">
definePageMeta({
  layout: false,
});
const isCreateModalOpen = ref<boolean>(true);
</script>
<style lang="scss" scoped></style>
