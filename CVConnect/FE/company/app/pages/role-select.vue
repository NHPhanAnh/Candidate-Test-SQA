<template>
  <div class="role-select">
    <div class="role-selector">
      <img src="/logo-horizontal.svg" class="logo" />
      <div class="title">Đăng nhập với tư cách</div>
      <div class="role-list">
        <div
          v-for="role of roles"
          :key="role.id"
          class="role-item"
          :class="{ isSelected: isRoleSelected(role) }"
          @click="handleClickRole(role)"
        >
          <Icon class="role-icon" :name="roleIcon(role.code)" />
          <div class="role-name">
            {{ role.name }}
          </div>
        </div>
      </div>
      <div class="actions">
        <label class="default-check" :class="{ disabled: !isFormValid }">
          <UCheckbox
            v-model="setDefault"
            class="custom-checkbox"
            :disabled="!isFormValid"
            size="lg"
            color="secondary"
            label="Đặt làm mặc định"
          />
        </label>
        <AppButton
          :text="'Tiếp tục'"
          :is-disabled="!isFormValid"
          class="next-btn"
          @click="handleButtonClick"
        />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ROLE_COLORED_ICON_DEFAULT, ROLE_COLORED_ICON_MAP } from "~/const/role";
definePageMeta({ layout: false });

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();
const { setCurrentRole } = authStore;
const { setDefaultRole } = useAuth();
const { setLoading } = useLoadingStore();
const { roles } = storeToRefs(authStore);
const setDefault = ref(false);
const selectedRole = ref<TAccountRole | null>(null);
const isRoleSelected = computed(() => {
  return (role: TAccountRole) => {
    if (!selectedRole.value) {
      return false;
    }
    return selectedRole.value.id == role.id;
  };
});

const isFormValid = computed(() => {
  return !!selectedRole.value;
});

const roleIcon = computed(() => {
  return (role: TRole | null | undefined) => {
    if (!role) {
      return ROLE_COLORED_ICON_DEFAULT;
    }
    return ROLE_COLORED_ICON_MAP[role];
  };
});

const handleClickRole = (role: TAccountRole) => {
  if (selectedRole.value && selectedRole.value.id == role.id) {
    selectedRole.value = null;
    setDefault.value = false;
    return;
  }

  selectedRole.value = role;
};

const handleButtonClick = async () => {
  if (!selectedRole.value) {
    return;
  }

  setCurrentRole(selectedRole.value);
  if (setDefault.value) {
    setLoading(true);
    await setDefaultRole(selectedRole.value);
    setLoading(false);
  }

  const redirectTo = route.query.redirect as string;
  const defaultRoute = getDefaultRoute(selectedRole.value);
  if (redirectTo) {
    router.push(redirectTo);
  } else {
    router.push({
      path: defaultRoute,
    });
  }
};
</script>
<style lang="scss" scoped>
.role-select {
  position: relative;
  overflow: hidden;
  width: 100vw;
  height: 100vh;
  display: flex;
  align-items: center;
  background-color: white;
  .role-selector {
    position: relative;
    margin: auto;
    width: 90%;
    flex: 1;

    z-index: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 16px 16px 16px 16px;
    gap: 24px;

    .logo {
      height: 76px;
    }

    .title {
      text-align: center;
      font-weight: 900;
      font-size: 30px;
      color: $text-light;
      line-height: 24px;
    }

    .role-list {
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;
      padding: 24px 48px;
      gap: 12px;
      overflow-y: auto;
      min-height: 268px;
      max-height: 360px;
      @include custom-scrollbar;

      @media (max-width: 646px) {
        justify-content: center;
      }

      .role-item {
        display: flex;
        flex-direction: column;
        align-items: center;

        gap: 16px;
        border-radius: 16px;
        background-color: white;
        padding: 16px;
        color: $text-light;
        font-weight: 600;
        @include box-shadow;
        transition:
          box-shadow 200ms,
          background-color 200ms;
        border: 2px solid $color-gray-200;

        &.isSelected {
          background: rgba($color-lime, 0.1);
          box-shadow: rgba($color-lime, 0.2) 0px 8px 24px;
          border: 2px solid rgba($color-lime, 0.8);
        }

        width: 220px;
        height: 220px;

        .role-icon {
          font-size: 100px;
          flex: 1;
        }

        &:hover {
          @include box-shadow;
          cursor: pointer;
        }
      }
    }

    .actions {
      display: flex;
      flex-direction: column;
      gap: 12px;
      width: 240px;
      align-items: center;

      .default-check {
        .custom-checkbox {
          :deep(label) {
            color: $text-light;
          }
          :deep(.iconify) {
            color: $text-dark;
          }
        }
      }

      .next-btn {
        background-color: $color-primary-500;
        width: 100%;
        color: $text-dark;

        &.disabled {
          background-color: rgba($color-gray-300, 1);
          color: $color-gray-500;
        }
      }
    }
  }
}
</style>
