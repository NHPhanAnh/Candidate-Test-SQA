<template>
  <div class="page403">
    <div class="notice">403 - Forbidden</div>
    <div class="message">Bạn không có quyền truy cập trang này.</div>
    <AppButton
      :text="'Đưa tôi về trang login'"
      class="back-to-login"
      @click="handleToLogin"
    />
  </div>
</template>
<script setup lang="ts">
definePageMeta({
  layout: false,
});

const { logout } = useAuth();
const router = useRouter();
const { setLoading } = useLoadingStore();

async function handleToLogin() {
  setLoading(true);
  await logout();
  setLoading(false);
  router.push({ path: "/auth/login" });
}
</script>
<style lang="scss" scoped>
.page403 {
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

  .back-to-login {
    padding: 8px 12px;
    background-color: $color-primary-500;
    color: $text-dark;
  }
}
</style>
