<template>
  <div class="public-layout">
    <div class="main-content">
      <AppPublicHeader />
      <slot />
    </div>
  </div>
</template>
<script setup lang="ts">
const { setLoading } = useLoadingStore();
const { verifyToken, getMe } = useAuth();
const { getMyRoles } = useRoleApi();
const userStore = useUserStore();
const { setUser } = userStore;
const authStore = useAuthStore();
const { currentRole, roles } = storeToRefs(authStore);
const { setRoles } = authStore;

onBeforeMount(async () => {
  setLoading(true);
  const res = await verifyToken();
  if (res?.data?.isValid) {
    const rolesRes = await getMyRoles();
    if (rolesRes) {
      setRoles(rolesRes.data);
      const myInfoRes = await getMe(rolesRes.data[0]);
      setUser(myInfoRes.data);
    }
  }
  setLoading(false);
});
</script>
<style lang="scss" scoped>
.public-layout {
  display: flex;
  min-height: 100vh;
  height: 100vh;
  max-height: 100vh;
  background-color: $color-gray-100;
  width: 100%;
  overflow: hidden;

  :deep(.main-content) {
    width: 100%;
    max-height: 100%;
    display: flex;
    flex-direction: column;
  }
}
</style>
