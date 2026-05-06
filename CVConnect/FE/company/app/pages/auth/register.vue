<template>
  <div class="register-page">
    <div class="form-wrapper">
      <div class="register-form">
        <div class="form-header">
          <div class="logo">
            <img src="/logo-horizontal.svg" />
          </div>
          <div class="welcome-message">Đăng ký tài khoản ứng viên</div>
          <div class="welcome-desc">
            Đăng ký ngay để kết nối nhiều cơ hội hơn
          </div>
        </div>
        <div
          v-if="mode === 'confirming'"
          class="notice"
          v-html="
            `Hệ thống đã gửi thông báo xác nhận vào hòm thư điện tử của bạn.
          Vui lòng kiểm tra và làm theo hướng dẫn. Nếu chưa thấy, hãy tìm trong
          hòm thư rác. Thông báo xác nhận có hiệu lực trong vòng
          <strong>${duration} giờ</strong>`
          "
        ></div>
        <div v-if="mode === 'registering'" class="form-content">
          <div class="form-content__column">
            <div class="column">
              <AppInputText
                :value="formInput.fullName"
                :label="'Tên đầy đủ'"
                :required="true"
                :error="formError.fullName"
                @input="handleInput('fullName', $event)"
                @blur="validateKey('fullName')"
              />
              <AppInputText
                :value="formInput.username"
                :label="'Tên đăng nhập'"
                :required="true"
                :error="formError.username"
                @input="handleInput('username', $event)"
                @blur="validateKey('username')"
              />
            </div>
            <div class="column">
              <AppInputText
                :value="formInput.email"
                :label="'Email'"
                :required="true"
                :error="formError.email"
                :tooltip="'Email này được dùng để xác thực tài khoản của bạn'"
                @input="handleInput('email', $event)"
                @blur="validateKey('email')"
              />
              <AppInputText
                :value="formInput.password"
                :label="'Mật khẩu'"
                :required="true"
                :error="formError.password"
                :is-secured="true"
                :show-error="false"
                @input="handleInput('password', $event)"
                @blur="validateKey('password')"
              />
              <AppInputText
                :value="formInput.passwordConfirm"
                :label="'Xác nhận mật khẩu'"
                :required="true"
                :error="formError.passwordConfirm"
                :is-secured="true"
                @input="handleInput('passwordConfirm', $event)"
                @blur="validateKey('passwordConfirm')"
              />
              <div class="password-checklist">
                <div
                  v-for="check of passwordChecklist"
                  :key="check.key"
                  class="checklist__item"
                  :class="{ done: check.isDone }"
                >
                  <Icon
                    :name="check.isDone ? 'mdi:check' : 'mdi:close'"
                    class="icon"
                  />
                  <div class="text">{{ check.text }}</div>
                </div>
              </div>
            </div>
          </div>
          <AppButton
            class="register-button"
            :is-loading="isLoading"
            :text="'Đăng ký'"
            :is-disabled="!isFormValid"
            @click="handleRegisterClick"
          />
        </div>
        <div class="form-footer">
          <div v-if="mode === 'registering'" class="forgot-password">
            Bạn đã có tài khoản?<NuxtLink class="link" :to="loginPageLink">
              Đăng nhập ngay
            </NuxtLink>
          </div>
          <div
            v-if="mode === 'confirming'"
            class="link continue-register"
            @click="handleSwitchToRegister"
          >
            Tiếp tục tạo tài khoản
          </div>
        </div>
      </div>
      <NuxtLink
        to="/account/request-verify-email?redirect=/auth/register"
        class="re-send-email"
        >Tôi chưa nhận được email xác thực</NuxtLink
      >
    </div>
    <div class="image">
      <img
        src="https://res.cloudinary.com/daygzzzwz/image/upload/v1756545359/cv-connect/background-login-small_tm858w.png"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
import { EMAIL_REGEX, PASSWORD_REGEX } from "~/const/auth";

definePageMeta({ layout: "auth" });
useHead({
  title: "Đăng kí",
});
const router = useRouter();
const duration = ref<number>(0);
const formInput = ref({
  fullName: "",
  email: "",
  username: "",
  password: "",
  passwordConfirm: "",
});

const formError = ref({
  fullName: "",
  email: "",
  username: "",
  password: "",
  passwordConfirm: "",
});

const { setLoading } = useLoadingStore();
const { getMyRoles } = useRoleApi();
const authStore = useAuthStore();
const { setRoles } = authStore;
const { currentRole } = storeToRefs(authStore);
const route = useRoute();
const { setMenus } = useSidebarStore();
const { verifyToken, register, getMenus } = useAuth();
const { handleSetRole, getInitialRoute } = usePermission();

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

const passwordChecklist = ref([
  {
    key: "lowercase",
    text: "Ít nhất 1 chữ thường",
    regex: /\p{Ll}/u,
    isDone: false,
  },
  {
    key: "uppercase",
    text: "Ít nhất 1 chữ hoa",
    regex: /\p{Lu}/u,
    isDone: false,
  },
  {
    key: "digit",
    text: "Ít nhất 1 chữ số",
    regex: /\d/,
    isDone: false,
  },
  {
    key: "length",
    text: "Độ dài từ 8 đến 20 ký tự",
    regex: /^.{8,20}$/,
    isDone: false,
  },
  {
    key: "nospace",
    text: "Không chứa khoảng trắng",
    regex: /^\S*$/,
    isDone: false,
  },
]);

const formRules = {
  fullName: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.fullName = "Mời nhập tên đầy đủ";
        return false;
      }
      return true;
    },
  ],
  email: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.email = "Mời nhập email";
        return false;
      }
      return true;
    },
    (input: string) => {
      const isValid = EMAIL_REGEX.test(input);
      if (!isValid) {
        formError.value.email = "Email không hợp lệ";
        return false;
      }
      return true;
    },
  ],
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
    (input: string) => {
      const isValid = PASSWORD_REGEX.test(input);
      if (!isValid) {
        formError.value.password =
          "Mật khẩu phải từ 8 đến 20 kí tự, ít nhất 1 kí tự hoa, thường, số và không chứa khoảng trắng";
        return false;
      }
      return true;
    },
  ],
  passwordConfirm: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.passwordConfirm = "Mời xác nhận mật khẩu";
        return false;
      }
      return true;
    },
    (input: string) => {
      if (
        formInput.value.password.trim() &&
        formInput.value.password.trim() !== input.trim()
      ) {
        formError.value.passwordConfirm = "Mật khẩu không trùng khớp";
        return false;
      }
      return true;
    },
  ],
};

type TRegisteringMode = "confirming" | "registering";
const mode = ref<TRegisteringMode>("registering");

const loginPageLink = computed(() => {
  let link = "/auth/login";
  if (route.query.redirect) {
    link += `?redirect=${route.query.redirect}`;
  }

  return link;
});

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

const handleSwitchToRegister = () => {
  mode.value = "registering";
  formInput.value.fullName = "";
  formInput.value.email = "";
  formInput.value.username = "";
  formInput.value.password = "";
  formInput.value.passwordConfirm = "";
  duration.value = 0;
};

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

const handleRegisterClick = async () => {
  // if able, validate before calling api
  validateForm();
  if (isFormValid.value) {
    const registerCredentials: TRegisterCredentials = {
      username: formInput.value.username,
      password: formInput.value.password,
      email: formInput.value.email,
      fullName: formInput.value.fullName,
    };
    isLoading.value = true;
    const res = await register(registerCredentials);
    if (res) {
      if (res.data.needVerifyEmail) {
        duration.value = res.data.duration / 60 / 60;
        mode.value = "confirming";
      } else {
        const username = res.data.username || "";
        isLoading.value = false;
        if (route.query.redirect) {
          router.push({
            path: "/auth/login",
            query: { username, redirect: route.query.redirect },
          });
        } else {
          router.push({ path: "/auth/login", query: { username } });
        }
      }
    }
    isLoading.value = false;
  }
};

const handleInput = (key: string, value: string) => {
  formInput.value[key as keyof typeof formInput.value] = value;
  formError.value[key as keyof typeof formError.value] = "";
};

const isLoading = ref(false);

watch(formInput.value, (val) => {
  passwordChecklist.value = passwordChecklist.value.map((rule) => {
    if (!val.password) {
      return {
        ...rule,
        isDone: false,
      };
    }
    return {
      ...rule,
      isDone: rule.regex.test(val.password),
    };
  });
});
</script>
<style lang="scss" scoped>
.register-page {
  display: flex;
  flex-direction: row;
  height: 100vh;
  .form-wrapper {
    width: 40vw;
    min-width: 650px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    margin: auto;
    height: 100%;

    .register-form {
      align-items: center;
      padding: 32px 60px 0px 60px;
      height: fit-content;
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

        .password-checklist {
          display: flex;
          flex-direction: column;
          gap: 4px;
          font-size: 12px;
          line-height: 14px;
          padding-left: 8px;

          .checklist__item {
            display: flex;
            flex-direction: row;
            align-items: center;
            gap: 4px;
            color: $color-danger;

            &.done {
              color: $color-success;
            }

            .icon {
              display: inline-block;
            }
          }
        }

        &__column {
          display: flex;
          flex-direction: row;
          gap: 8px;
          .column {
            display: flex;
            flex-direction: column;
            gap: 4px;
            flex: 1;
          }
        }

        .register-button {
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
        gap: 4px;
        align-items: flex-end;

        .link {
          color: $color-primary-400;
          cursor: pointer;
          font-style: underline;
        }

        .continue-register {
          margin-top: 16px;
          align-self: center;
        }

        .forgot-password {
          color: $text-light;
          margin-top: 8px;
          font-size: 13px;
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

    .notice {
      border: 2px dashed $color-success;
      padding: 28px;
      border-radius: 8px;
      text-align: left;
      color: $color-success;
      background-color: rgba($color-success, 0.1);
    }
  }
  .image {
    @media (max-width: 900px) {
      display: none;
    }
    object-fit: cover;
    overflow: hidden;
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }
}
</style>
