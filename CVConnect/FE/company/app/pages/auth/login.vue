<template>
  <div class="login-page">
    <div class="form-wrapper">
      <div class="login-form">
        <div class="form-header">
          <div class="logo">
            <img src="/logo-horizontal.svg" />
          </div>
          <div class="welcome-message">Đăng nhập</div>
          <div class="welcome-desc">
            Đăng nhập với tên đăng nhập và mật khẩu
          </div>
        </div>
        <div class="form-content">
          <AppInputText
            :value="formInput.username"
            :label="'Tên đăng nhập'"
            :required="true"
            :error="formError.username"
            @input="handleInput('username', $event)"
            @blur="validateKey('username')"
          />
          <AppInputText
            :value="formInput.password"
            :label="'Mật khẩu'"
            :required="true"
            :error="formError.password"
            :is-secured="true"
            @input="handleInput('password', $event)"
            @blur="validateKey('password')"
          />
          <AppButton
            class="login-button"
            :is-loading="isLoading.loginButton"
            :text="'Đăng nhập'"
            :is-disabled="!isFormValid || isLoading.loginWithGoogle"
            @click="handleLoginClick"
          />
        </div>
        <div class="form-footer">
          <NuxtLink to="/account/request-recovery" class="forgot-password"
            >Quên mật khẩu?</NuxtLink
          >
          <div class="divider">
            <div class="line"></div>
            <div class="text">Hoặc</div>
          </div>
          <AppButton
            class="login-with-google-button"
            :is-loading="isLoading.loginWithGoogle"
            :text="'Đăng nhập với Google'"
            :is-disabled="isLoading.loginButton"
            @click="handleLoginWithGoogleClick"
          >
            <template #icon>
              <Icon class="icon" name="flowbite:google-solid" />
            </template>
          </AppButton>
          <div class="create-account">
            Bạn chưa có tài khoản?
            <NuxtLink to="/auth/register" class="link">Đăng ký ngay</NuxtLink>
          </div>
          <div class="create-account">
            <NuxtLink to="/auth/org-register" class="link">Đăng ký</NuxtLink>
            với tư cách nhà tuyển dụng
          </div>
        </div>
      </div>
      <NuxtLink
        to="/account/request-verify-email?redirect=/auth/login"
        class="re-send-email"
        >Tôi chưa nhận được email xác thực</NuxtLink
      >
    </div>
    <div class="image">
      <img
        class="wall-image"
        src="https://res.cloudinary.com/daygzzzwz/image/upload/v1756545359/cv-connect/background-login-small_tm858w.png"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
definePageMeta({ layout: "auth" });
useHead({
  title: "Đăng nhập",
});

const { handleSetRole, getInitialRoute } = usePermission();

const { login, verifyToken, getMenus } = useAuth();
const authStore = useAuthStore();
const { setRoles } = authStore;
const { currentRole } = storeToRefs(authStore);
const { getMyRoles } = useRoleApi();
const router = useRouter();
const route = useRoute();
const { setLoading } = useLoadingStore();
const { setMenus } = useSidebarStore();

onBeforeMount(async () => {
  setLoading(true);
  const res = await verifyToken();
  if (res?.data?.isValid) {
    const rolesRes = await getMyRoles();
    setLoading(false);
    if (rolesRes) {
      setRoles(rolesRes.data);
      await handleRouting();
    }
  }
  setLoading(false);
  const username = route.query.username as string;
  if (username) {
    formInput.value.username = username;
  }
});

const formInput = ref({
  username: "",
  password: "",
});

const formError = ref({
  username: "",
  password: "",
});

const formRules = {
  username: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.username = "Mời nhập tên đăng nhập";
        return false;
      }
      return true;
    },
  ],
  password: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.password = "Mời nhập mật khẩu";
        return false;
      }
      return true;
    },
  ],
};

const isFormValid = computed(() => {
  for (const key of Object.keys(
    formError.value,
  ) as (keyof typeof formError.value)[]) {
    if (formError.value[key]) {
      return false;
    }
  }
  return true;
});

const validateForm = () => {
  for (const key of Object.keys(
    formInput.value,
  ) as (keyof typeof formInput.value)[]) {
    validateKey(key);
  }
};

const validateKey = (key: keyof typeof formInput.value) => {
  const input = formInput.value[key];
  const rules = formRules[key as keyof typeof formRules];
  for (const rule of rules) {
    const ok = rule(input);
    if (!ok) {
      break;
    }
  }
};

const handleLoginWithGoogleClick = () => {
  console.log("login with google");
};
const handleLoginClick = async () => {
  // if able, validate before calling api
  validateForm();
  if (isFormValid.value) {
    const loginCredentials: TLoginCredentials = {
      username: formInput.value.username,
      password: formInput.value.password,
    };
    isLoading.value.loginButton = true;
    const isSuccess = await login(loginCredentials);
    isLoading.value.loginButton = false;
    if (isSuccess) {
      const redirectTo = route.query.redirect;
      if (redirectTo) {
        router.push({ path: redirectTo as string });
      } else {
        handleRouting();
      }
    }
  }
};

const handleInput = (key: string, value: string) => {
  formInput.value[key as keyof typeof formInput.value] = value;
  formError.value[key as keyof typeof formError.value] = "";
};

async function handleRouting() {
  handleSetRole();
  setLoading(true);
  const menusRes = await getMenus(currentRole.value!);
  console.log(menusRes);
  setLoading(false);
  if (menusRes) {
    setMenus(menusRes);
    const route = await getInitialRoute();
    router.push({ path: route });
    return;
  }
}

const isLoading = ref({
  loginButton: false,
  loginWithGoogle: false,
});
</script>
<style lang="scss" scoped>
.login-page {
  display: flex;
  flex-direction: row;
  justify-content: center;
  height: 100vh;
  .form-wrapper {
    width: 40vw;
    min-width: 450px;
    display: flex;
    flex-direction: column;
    justify-content: center;

    .login-form {
      justify-content: center;
      display: flex;
      flex-direction: column;
      min-width: 450px;
      padding: 32px 60px 0px 60px;
      flex: 1;
      width: 360px;
      margin: auto;
      border-radius: 16px;

      .form-header {
        display: flex;
        flex-direction: column;
        gap: 16px;
        .welcome-message {
          text-align: center;
          font-weight: 900;
          font-size: 24px;
          color: $color-primary-500;
          line-height: 24px;
        }
        .welcome-desc {
          font-size: 13px;
          text-align: center;
          color: $text-light;
          margin-top: -8px;
          margin-bottom: 24px;
        }
        .logo {
          display: flex;
          justify-content: center;
          margin-bottom: 12px;
          img {
            height: 72px;
          }
        }
      }

      .form-content {
        margin-top: 12px;
        display: flex;
        flex-direction: column;
        gap: 8px;
        width: 100%;

        .login-button {
          margin-top: 12px;
          background-color: $color-primary-500;
          border-radius: 8px;
          color: $text-dark;

          &.disabled {
            background-color: $color-gray-400;
          }
        }
      }

      .form-footer {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        width: 100%;
        gap: 4px;
        align-items: flex-end;

        .forgot-password {
          color: $color-primary-400;
          font-size: 13px;
          margin-top: 4px;
          cursor: pointer;
        }

        .create-account {
          color: $text-light;
          font-size: 13px;
          margin-top: 4px;
          align-self: center;
          .link {
            cursor: pointer;
            color: $color-primary-400;
          }
        }

        .login-with-google-button {
          border-radius: 8px;
          margin-top: 8px;
          width: 100%;
          background-color: $color-google-green;
          :deep(.icon) {
            display: inline-block;
            color: $text-dark;
          }

          :deep(.button-text) {
            color: $text-dark;
          }

          &.disabled {
            background-color: $color-gray-400;
          }
        }

        .divider {
          position: relative;
          height: 20px;
          width: 100%;
          display: flex;
          justify-content: center;
          .text {
            font-size: 14px;
            line-height: 20px;
            color: $color-gray-400;
            width: fit-content;
            z-index: 2;
            background-color: $color-gray-100;
            position: relative;
            padding: 0px 4px;
          }
          .line {
            position: absolute;
            width: 100%;
            height: 1px;
            display: block;
            top: 10px;
            z-index: 1;
            background-color: $color-gray-200;
          }
        }
      }
    }

    .re-send-email {
      font-size: 13px;
      margin-top: 4px;
      align-self: center;
      cursor: pointer;
      text-decoration: underline;
      color: $text-light;
      margin-bottom: 8px;
    }
  }

  .image {
    max-width: 60vw;
    @media (max-width: 850px) {
      display: none;
    }
    img.wall-image {
      height: 100%;
      width: 100%;
      object-fit: cover;
    }
  }
}
</style>
