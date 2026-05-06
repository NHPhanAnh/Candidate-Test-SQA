<template>
  <div v-on-click-outside="closeDropdown" class="user-avatar">
    <div v-if="userInfo" class="avatar" @click="handleClickAvatar">
      <img v-if="userInfo.avatarUrl" :src="userInfo.avatarUrl" />
      <div
        v-else
        class="monogram"
        :style="{ backgroundColor: getMonogramColor(userInfo.id) }"
      >
        {{ getMonogramText(userInfo.fullName) }}
      </div>
    </div>
    <div v-show="isDropdownShow" class="dropdown">
      <div class="dropdown__item">
        <Icon name="mdi:clipboard-account" class="icon" />
        <div class="text">{{ userInfo?.fullName || "Hồ sơ cá nhân" }}</div>
      </div>
      <!-- <div class="divider"></div> -->
      <div class="dropdown__item" @click="handleLogout">
        <Icon name="mdi:logout" class="icon" />
        <div class="text">Đăng xuất</div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { vOnClickOutside } from "@vueuse/components";
import {
  DEFAULT_MONOGRAM_BACKGROUND_COLOR,
  DEFAULT_MONOGRAM_TEXT,
} from "~/const/user";

const { logout } = useAuth();
const { clearToken } = useAuthStore();

const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);
const isDropdownShow = ref<boolean>(false);
const { setLoading } = useLoadingStore();
const toast = useToast();

const closeDropdown = () => {
  isDropdownShow.value = false;
};

const handleClickAvatar = () => {
  isDropdownShow.value = !isDropdownShow.value;
};

const handleLogout = async () => {
  try {
    setLoading(true);
    await logout();
    setLoading(false);
    toast.add({
      title: "Đăng xuất thành công",
      color: "success",
    });
  } catch (err) {
    setLoading(false);
    clearToken();
  }
};

const monogramText = computed(() => {
  const names = userInfo.value?.fullName?.split(/\s+/);
  let name = "";
  if (names && names.length) {
    if (names[0]) {
      name += names[0][0];
    }
    if (names[1]) {
      name += names[1][0];
    }
    if (name.length) {
      return name;
    }
  }
  return DEFAULT_MONOGRAM_TEXT;
});

const monogramColor = computed(() => {
  if (!userInfo.value) {
    return DEFAULT_MONOGRAM_BACKGROUND_COLOR;
  }
  return getMonogramColor(userInfo.value.id);
});
</script>
<style lang="scss" scoped>
.user-avatar {
  position: relative;
  z-index: 3;
  .avatar {
    box-shadow: rgba(0, 0, 0, 0.24) 0px 3px 8px;
    height: 36px;
    width: 36px;
    min-width: 36px;
    border-radius: 999px;
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .monogram {
      width: 100%;
      height: 100%;
      color: $text-dark;
      font-size: 16px;
      font-weight: 600;
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }

  .dropdown {
    background-color: white;
    position: absolute;
    z-index: 3;
    top: 40px;
    width: max-content;
    right: 0px;
    padding: 4px;
    display: flex;
    flex-direction: column;
    @include box-shadow;
    gap: 4px;
    border-radius: 12px;

    .divider {
      height: 1px;
      display: block;
      width: 100%;
      background-color: $color-gray-200;
      margin-top: 4px;
      margin-bottom: 4px;
    }

    &__item {
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
      min-width: fit-content;
      transition: background-color 200ms;

      &:hover {
        background-color: rgba($color-primary-100, 0.6);
        color: $color-primary-400;
      }

      .icon {
        display: inline-block;
        font-size: 20px;
      }
    }
  }
}
</style>
