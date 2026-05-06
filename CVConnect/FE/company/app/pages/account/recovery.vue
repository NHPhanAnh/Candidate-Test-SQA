<template>
  <div class="recovery-page">
    <div class="form-wrapper">
      <div class="recovery-form">
        <div class="form-header">
          <div class="logo">
            <img src="/logo-horizontal.svg" />
          </div>
          <div class="welcome-message">Đặt lại mật khẩu</div>
          <div class="welcome-desc"></div>
        </div>
        <div v-if="!countdown" class="form-content">
          <AppInputText
            :value="formInput.password"
            :label="'Mật khẩu mới'"
            :required="true"
            :error="formError.password"
            :show-error="false"
            :is-secured="true"
            @input="handleInput('password', $event)"
            @blur="validateKey('password')"
          />
          <AppInputText
            :value="formInput.passwordConfirm"
            :label="'Xác nhận mật khẩu'"
            :required="true"
            :is-secured="true"
            :error="formError.passwordConfirm"
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
          <AppButton
            class="recovery-button"
            :is-loading="isLoading"
            :text="'Đồng ý'"
            :is-disabled="isButtonDisabled"
            @click="handleResetPassword"
          />
          <NuxtLink to="/auth/login" class="link">Trở về đăng nhập</NuxtLink>
        </div>
        <div v-else class="notice">
          <span
            >Đặt lại mật khẩu thành công. Bạn sẽ được chuyển hướng về trang đăng
            nhập trong <strong>{{ `${countdown} giây` }}</strong
            >.
            <NuxtLink to="/auth/login" class="link"
              >Đưa tôi về ngay</NuxtLink
            ></span
          >
        </div>
      </div>
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
import { PASSWORD_REGEX } from "~/const/auth";

definePageMeta({ layout: "auth" });
useHead({
  title: "Đặt lại mật khẩu",
});
const route = useRoute();
const router = useRouter();
const { resetPassword } = useAuth();
const formInput = ref({
  password: "",
  passwordConfirm: "",
});

const formError = ref({
  password: "",
  passwordConfirm: "",
});

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

const countdown = ref<number>(0);
const countdownRef = ref<number | null>(null);
const username = ref<string>("");

const handleResetPassword = async () => {
  validateForm();
  if (!isFormValid.value) {
    return;
  }

  const token = (route.query.token as string) || "";
  isLoading.value = true
  const res = await resetPassword(token, formInput.value.password);
  isLoading.value = false
  if (res) {
    username.value = res.data.username;
    countdown.value = 6;
    countdownRef.value = window.setInterval(() => {
      countdown.value -= 1;
    }, 1000);
  }
};

const isButtonDisabled = computed(() => {
  return countdown.value > 0 || !isFormValid.value;
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

const handleInput = (key: string, value: string) => {
  formInput.value[key as keyof typeof formInput.value] = value;
  formError.value[key as keyof typeof formError.value] = "";
};

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

watch(countdown, (val) => {
  if (val === 0) {
    if (countdownRef.value) {
      window.clearInterval(countdownRef.value);
    }
    router.push({ path: "/auth/login", query: { username: username.value } });
  }
});

onBeforeUnmount(() => {
  if (countdownRef.value) {
    window.clearInterval(countdownRef.value);
  }
});

const isLoading = ref(false);
</script>
<style lang="scss" scoped>
.recovery-page {
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

    .recovery-form {
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

        .recovery-button {
          margin-top: 12px;
          background-color: $color-primary-500;
          border-radius: 8px;
          color: $text-dark;

          &.disabled {
            background-color: $color-gray-400;
          }
        }

        .link {
          color: $color-primary-400;
          font-size: 13px;
          margin-top: -4px;
          cursor: pointer;
          align-self: flex-end;
        }

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
      }

      .notice {
        border: 2px dashed $color-success;
        padding: 28px;
        border-radius: 8px;
        text-align: left;
        color: $color-success;
        background-color: rgba($color-success, 0.1);

        .link {
          color: $color-success;
          margin-top: -4px;
          font-weight: 700;
          cursor: pointer;
          align-self: flex-end;
        }
      }
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
