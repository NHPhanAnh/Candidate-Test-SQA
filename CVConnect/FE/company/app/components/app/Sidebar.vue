<template>
  <div class="sidebar">
    <div class="main-sidebar" :class="{ isExpanded: isExpanded }">
      <div v-if="isExpanded" class="logo cursor-pointer" @click="handleGoToHome">
        <img src="/logo-horizontal.svg" />
      </div>
      <div v-else class="small-logo cursor-pointer" @click="handleGoToHome">
        <img src="/favicon-icon.svg" />
      </div>
      <div
        ref="mainSection"
        class="main-section"
        :class="{
          expanded: isExpanded,
          'has-scrollbar': hasMainSidebarScrollbar,
        }"
      >
        <AppSidebarItem
          v-for="menu in sidebarData"
          :key="menu.id"
          :item="menu"
          :is-sidebar-expanded="isExpanded"
          :is-first-level="true"
          @expand="handleItemExpand"
        />
      </div>
      <div class="expand-button" @click="() => (isExpanded = !isExpanded)">
        <Icon
          :name="
            isExpanded ? 'mdi:chevron-double-left' : 'mdi:chevron-double-right'
          "
        />
      </div>
    </div>
    <div class="role-selection" :class="{ isExpanded: isExpanded }">
      <div v-show="isAllRolesShow" class="role-list">
        <div
          v-for="role of roles"
          :key="role.id"
          :title="isExpanded ? '' : role.name"
          :class="{ isActive: isCurrentRole(role) }"
          class="role-item"
        >
          <div
            class="float"
            :class="{ expanded: isExpanded, hidden: !isExpanded }"
          >
            <div class="wrapper">
              <div
                class="menu-child"
                :class="{ default: isCurrentRole(role) }"
                @click.stop="handleSetRole(role)"
              >
                Đổi vai trò
              </div>
              <div
                class="menu-child"
                :class="{ default: isSetDefault(role) }"
                @click.stop="
                  isSetDefault(role) ? () => {} : handleSetRoleDefault(role)
                "
              >
                {{ isSetDefault(role) ? "Mặc định" : "Đặt mặc định" }}
              </div>
            </div>
          </div>
          <Icon class="role-icon" :name="roleIcon(role.code)" />
          <div v-if="isExpanded" class="role-name">{{ role.name }}</div>
          <Icon
            v-if="isSetDefault(role)"
            class="star-icon"
            :class="{ small: !isExpanded }"
            name="material-symbols:star-rounded"
          />
        </div>
      </div>
      <div v-if="isAllRolesShow" class="divider"></div>
      <div
        class="role-switcher"
        @click="() => (isAllRolesShow = !isAllRolesShow)"
      >
        <div
          class="role-item toggler"
          :title="isExpanded ? '' : 'Chuyển đổi vai trò'"
        >
          <Icon class="role-icon" name="mdi:account-convert" />
          <div v-if="isExpanded">Chuyển đổi vai trò</div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ROLE_ICON_DEFAULT, ROLE_ICON_MAP } from "~/const/role";
import type { TSidebarItemExpandPayload } from "./sidebar/item.vue";

const sidebarStore = useSidebarStore();
const { setMenus } = sidebarStore;
const { sidebarData } = storeToRefs(sidebarStore);
const authStore = useAuthStore();
const { setCurrentRole, setRoles } = authStore;
const { currentRole, roles } = storeToRefs(authStore);
const { setLoading } = useLoadingStore();
const { getMenus, setDefaultRole } = useAuth();
const toast = useToast();
const route = useRoute();
const router = useRouter();

const isAllRolesShow = ref(false);
const mainSection = useTemplateRef("mainSection");
const hasMainSidebarScrollbar = ref<boolean>(false);

const observer = ref<ResizeObserver | null>(null);

onMounted(() => {
  observer.value = new ResizeObserver(() => {
    if (mainSection.value) {
      hasMainSidebarScrollbar.value =
        mainSection.value.scrollHeight > mainSection.value.clientHeight;
    }
  });

  if (mainSection.value) {
    observer.value.observe(mainSection.value);
  }
});

onBeforeUnmount(() => {
  if (observer.value && mainSection.value) {
    observer.value.unobserve(mainSection.value);
  }
});

watch(
  currentRole,
  async (newRole) => {
    if (newRole) {
      setLoading(true);
      const menus = await getMenus(newRole);
      setLoading(false);

      if (menus) {
        setMenus(menus);
      }
    }
  },
  { immediate: true },
);

function handleGoToHome() {
  router.push({ path: "/" });
}

const isCurrentRole = computed(() => {
  return (role: TAccountRole) => {
    return role.id === currentRole.value?.id;
  };
});

const isSetDefault = computed(() => {
  return (role: TAccountRole) => {
    const currentDefaultRole = roles.value.filter((role) => role.isDefault);
    if (
      currentDefaultRole.length &&
      currentDefaultRole[0] &&
      currentDefaultRole[0].id == role.id
    ) {
      return true;
    }
    return false;
  };
});

const roleIcon = computed(() => {
  return (role: TRole | null | undefined) => {
    if (!role) {
      return ROLE_ICON_DEFAULT;
    }
    return ROLE_ICON_MAP[role];
  };
});

const handleSetRole = async (role: TAccountRole) => {
  if (currentRole.value && currentRole.value.id == role.id) {
    return;
  }
  setCurrentRole(role);
  isAllRolesShow.value = false;
  toast.add({
    title: "Chuyển đổi vai trò thành công",
    color: "success",
  });
  location.reload();
};

const handleSetRoleDefault = async (role: TAccountRole) => {
  isAllRolesShow.value = false;
  const res = await setDefaultRole(role);
  if (res) {
    toast.add({
      title: "Đặt vai trò làm mặc định thành công",
      color: "success",
    });
    if (currentRole.value && currentRole.value.id !== role.id) {
      const roleList = roles.value.map((_role) => {
        if (_role.id !== role.id) {
          return _role;
        }

        return {
          ..._role,
          isDefault: true,
        };
      });
      setRoles(roleList);
      setCurrentRole(role);
    }
    location.reload();
  }
};

const handleItemExpand = ({ id, state }: TSidebarItemExpandPayload) => {
  sidebarStore.expandItem(id, state, sidebarStore.sidebarData);
};

const isExpanded = ref(true);
</script>
<style lang="scss" scoped>
.sidebar {
  padding: 16px 8px 16px 16px;
  height: 100vh;
  max-height: 100vh;
  display: flex;
  flex-direction: column;
  gap: 4px;
  .main-sidebar {
    border-radius: 8px;
    flex: 1;
    margin-bottom: 18px;
    min-height: 0px;
    .logo {
      padding: 16px;
    }
    .small-logo {
      padding: 4px;
      margin-bottom: 8px;
    }

    .main-section {
      @include custom-scrollbar;
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 4px;
      overflow-y: auto;
      overflow-x: hidden;

      &.has-scrollbar {
        margin-right: -4px;
      }
    }

    .expand-button {
      padding: 8px;
      border-radius: 999px;
      cursor: pointer;
      display: flex;
      justify-content: center;
      align-items: center;
      transition-duration: 200ms;
      color: $text-light;
      font-size: 20px;
      background-color: white;
      border: 2px solid $color-gray-200;
      width: 34px;
      height: 34px;
      margin-left: auto;
      margin-right: auto;
      margin-bottom: -24px;

      &:hover {
        color: $color-primary-700;
        border: 2px solid $color-primary-200;
      }
    }

    display: flex;
    gap: 4px;
    flex-direction: column;
    width: 52px;
    background-color: white;
    box-shadow: rgba(100, 100, 111, 0.2) 0px 7px 29px 0px;
    padding: 8px;

    &.isExpanded {
      width: 240px;
    }
  }

  .role-selection {
    border-radius: 8px;
    padding: 8px;
    background-color: white;
    box-shadow: rgba(100, 100, 111, 0.2) 0px 7px 29px 0px;
    width: 52px;
    max-height: fit-content;
    display: flex;
    flex-direction: column;
    gap: 8px;

    .role-list {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }

    .divider {
      display: block;
      height: 1px;
      width: 100%;
      background-color: $color-gray-200;
    }

    .role-item {
      font-size: 14px;
      line-height: 20px;
      color: $text-light;
      display: flex;
      flex-direction: row;
      gap: 8px;
      align-items: center;
      padding: 8px;
      cursor: pointer;
      border-radius: 8px;
      font-weight: 600;
      transition: background-color 200ms;
      position: relative;

      .role-name {
        flex: 1;
      }

      .star-icon {
        display: flex;
        color: $color-goldenrod;
        font-size: 20px;
        margin-left: -8px;

        &.small {
          position: absolute;
          font-size: 18px;
          top: 2px;
          right: 2px;
        }
      }

      &.toggler {
        &:hover {
          background-color: rgba($color-primary-100, 0.6);
          color: $color-primary-400;
        }
      }

      .float {
        display: none;
        position: absolute;
        z-index: 4;
        padding-left: 12px;

        .wrapper {
          padding: 4px;
          border-radius: 12px;
          min-width: 120px;
          background-color: white;
          box-shadow: rgba(100, 100, 111, 0.2) 0px 7px 29px 0px;

          .menu-child {
            font-size: 14px;
            line-height: 20px;
            color: $text-light;
            display: flex;
            flex-direction: row;
            gap: 16px;
            align-items: center;
            padding: 8px;
            cursor: pointer;
            border-radius: 8px;
            font-weight: 600;
            transition: background-color 200ms;
            position: relative;

            &.default {
              cursor: default;
              color: $color-gray-300;
            }

            &.active:not(.default) {
              background-color: rgba($color-primary-100, 0.6);
              color: $color-primary-400;
            }

            &:hover:not(.default) {
              background-color: rgba($color-primary-100, 0.6);
              color: $color-primary-400;
            }
          }
        }

        top: -4px;
        &.expanded {
          margin-left: 216px;
        }
        &.hidden {
          margin-left: 27px;
        }
      }

      &:hover > .float,
      &:hover .float,
      .float:hover {
        display: block;
      }

      &.isActive {
        background-color: rgba($color-primary-100, 0.6);
        color: $color-primary-400;
      }

      .role-icon {
        font-size: 20px;
      }
    }

    &.isExpanded {
      width: 240px;
    }
  }
}
</style>
