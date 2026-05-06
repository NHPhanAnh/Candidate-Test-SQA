<template>
  <div class="page404">
    <div class="notice">404 - Not Found</div>
    <div class="message">Trang không tồn tại.</div>
    <AppButton
      v-if="canGoBack"
      :text="'Đưa tôi quay lại'"
      class="back-to-last"
      @click="handleGoBack"
    />
  </div>
</template>
<script setup lang="ts">
definePageMeta({
  layout: false,
});

const router = useRouter();

const canGoBack = computed(() => {
  return window.history.state?.back;
})

function handleGoBack() {
  if (canGoBack.value) {
    router.back();
  }
}
</script>
<style lang="scss" scoped>
.page404 {
  color: $text-light;
  display: flex;
  height: 100vh;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  .notice {
    font-size: 26px;
    line-height: 30px;
    font-weight: 500;
  }

  .message {
    font-size: 14px;
    line-height: 20px;
    font-weight: 400;
  }

  .back-to-last {
    padding: 8px 12px;
    background-color: $color-primary-500;
    color: $text-dark;
  }
}
</style>
