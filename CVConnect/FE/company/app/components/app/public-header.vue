<template>
  <header class="public-header">
    <div class="right flex-1">
      <div class="logo" @click="handleClickLogo">
        <img src="/logo-horizontal.svg" />
      </div>
      <div class="v-divider"></div>
      <NuxtLink :to="'/jobs'" class="header-item">
        <Icon name="material-symbols:document-search-outline-rounded"></Icon>
        Tìm việc ngay
      </NuxtLink>
      <!-- <UNavigationMenu :items="items" class="flex-1" /> -->
    </div>
    <div class="right">
      <template v-if="avatarInfo">
        <div class="header-btn">
          <Icon name="mingcute:wechat-fill" />
        </div>
        <AppPublicHeaderAvatar />
      </template>
      <template v-else>
        <NuxtLink :to="'/auth/org-register'" class="button ghost"
          >Đăng tuyển ngay</NuxtLink
        >
        <div class="wrapper button">
          <NuxtLink :to="loginRedirectLink">Đăng nhập</NuxtLink>
          <!-- <div class="button-divider"></div> -->
          <NuxtLink :to="registerRedirectLink">Đăng ký</NuxtLink>
        </div>
      </template>
    </div>
  </header>
</template>
<script setup lang="ts">
const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);
const authStore = useAuthStore();
const { currentRole, roles } = storeToRefs(authStore);
const { setRoles } = authStore;
const items = ref<any>([
  {
    label: "Tìm việc ngay",
    to: "/docs/getting-started",
    children: [
      {
        label: "Introduction",
        description: "Fully styled and customizable components for Nuxt.",
        icon: "i-lucide-house",
      },
      {
        label: "Installation",
        description:
          "Learn how to install and configure Nuxt UI in your application.",
        icon: "i-lucide-cloud-download",
      },
      {
        label: "Icons",
        icon: "i-lucide-smile",
        description:
          "You have nothing to do, @nuxt/icon will handle it automatically.",
      },
      {
        label: "Colors",
        icon: "i-lucide-swatch-book",
        description:
          "Choose a primary and a neutral color from your Tailwind CSS theme.",
      },
      {
        label: "Theme",
        icon: "i-lucide-cog",
        description:
          "You can customize components by using the `class` / `ui` props or in your app.config.ts.",
      },
    ],
  },
]);

const avatarInfo = computed(() => {
  console.log(roles.value);
  if (!userInfo.value) {
    return null;
  }

  return {
    avatarUrl: userInfo.value.avatarUrl,
    fullName: userInfo.value.fullName,
    id: userInfo.value.id,
  };
});

const registerRedirectLink = computed(() => {
  return `/auth/register?redirect=${route.fullPath}`;
});

const loginRedirectLink = computed(() => {
  return `/auth/login?redirect=${route.fullPath}`;
});

function handleClickLogo() {
  router.push({ path: "/" });
}
</script>
<style lang="scss" scoped>
.public-header {
  position: sticky;
  top: 0px;
  z-index: 2;
  background-color: white;
  @include box-shadow;
  height: 54px;
  padding: 8px 36px;
  display: flex;
  flex-direction: row;
  gap: 8px;
  justify-content: space-between;
  align-items: center;

  .v-divider {
    margin-right: 12px;
    height: 32px;
    display: block;
    width: 1px;
    background-color: $color-gray-300;
  }

  .header-item {
    color: $color-primary-500;
    font-weight: 600;
    cursor: pointer;
    font-size: 14px;
    transition-duration: 200ms;
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 4px;

    .iconify {
      display: block;
      font-size: 16px;
      height: 16px;
      width: 16px;
    }
  }

  :deep(a),
  :deep(button) {
    cursor: pointer !important;
  }

  .logo {
    cursor: pointer;
    margin-right: 36px;
    img {
      height: 38px;
    }
  }

  .header-btn {
    background-color: $color-gray-200;
    border-radius: 999px;
    height: 36px;
    width: 36px;
    display: flex;
    justify-content: center;
    align-items: center;

    .iconify {
      display: block;
      font-size: 24px;
      height: 24px;
      width: 24px;
      cursor: pointer;
    }
  }

  .right {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;

    .link {
      font-size: 13px;
      color: $color-primary-500;
      text-decoration: underline;
      cursor: pointer;
      font-weight: 400;
    }

    .name {
      display: flex;
      flex-direction: column;
      gap: 2px;
      text-align: right;
      .text {
        font-size: 13px;
        color: $text-light;
        font-weight: 600;
      }
    }
  }

  .button {
    font-size: 14px;
    height: 36px;
    min-width: 102px;
    padding: 0px 12px;
    text-align: center;
    cursor: pointer;
    color: $text-dark;
    background-color: $color-primary-500;
    display: flex;
    align-items: center;
    border-radius: 999px;
    gap: 8px;

    &.ghost {
      background-color: $color-gray-100;
      color: $color-primary-500;
    }

    .button-divider {
      height: 100%;
      width: 1px;
      display: block;
      background-color: white;
    }
  }
}
</style>
