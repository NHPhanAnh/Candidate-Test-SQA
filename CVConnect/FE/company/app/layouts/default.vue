<template>
  <div class="main-layout">
    <AppSidebar />
    <div class="main-content">
      <AppHeader />
      <slot />
    </div>
  </div>
</template>
<script setup lang="ts">
const permittedRole: TRole = "CANDIDATE";

const authStore = useAuthStore();
const { token, currentRole } = storeToRefs(authStore);
const { setUser } = useUserStore();
const { getMe, verifyToken } = useAuth();
const loadingStore = useLoadingStore();
const { setLoading } = loadingStore;
const { isLoading } = storeToRefs(loadingStore);
const router = useRouter();
const route = useRoute();
const { handleRoleValidation, checkPermission } = useDefaultRole();

watch(token, (newVal) => {
  if (newVal === null) {
    router.push({
      name: "auth-login",
      query: {
        redirect: route.fullPath,
      },
    });
  }
});

watch(currentRole, async (newRole) => {
  await checkPermission(permittedRole);
});

onBeforeMount(async () => {
  if (!token.value) {
    router.push({
      name: "auth-login",
      query: {
        redirect: route.fullPath,
      },
    });
    return;
  }
  setLoading(true);
  await verifyToken();
  setLoading(false);

  handleRoleValidation(route.fullPath);

  if (currentRole.value) {
    await checkPermission(permittedRole);
    setLoading(true);
    const res = await getMe(currentRole.value, { isSilent: true });
    setLoading(false);
    if (res) {
      setUser(res.data.data);
    }
  }
});
</script>
<style lang="scss" scoped>
.main-layout {
  display: flex;
  min-height: 100vh;
  height: 100vh;
  background-color: $color-gray-100;

  .main-content {
    max-height: 100%;
    overflow-y: auto;
    overflow-x: hidden;
    padding: 12px 12px;
    flex: 1;
  }
}
</style>
