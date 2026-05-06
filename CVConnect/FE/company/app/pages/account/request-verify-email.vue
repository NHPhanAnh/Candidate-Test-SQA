<template>
  <div class="request-email-page">
    <div class="form-wrapper">
      <div class="request-email-form">
        <div class="form-header">
          <div class="logo">
            <img src="/logo-horizontal.svg" />
          </div>
          <div class="welcome-message">Gửi lại email xác thực</div>
          <div class="welcome-desc">Yêu cầu gửi lại email xác thực</div>
        </div>
        <div
          v-if="noticeMessage"
          class="notice"
          :class="{ error: isError }"
          v-html="noticeMessage"
        ></div>
        <div class="form-content">
          <AppInputText
            :value="formInput.identifier"
            :label="'Tên đăng nhập (Hoặc email)'"
            :required="true"
            :error="formError.identifier"
            @input="handleInput('identifier', $event)"
            @blur="validateKey('identifier')"
          />
          <AppButton
            class="request-email-button"
            :is-loading="isLoading"
            :text="buttonText"
            :is-disabled="isButtonDisabled"
            @click="handleRequestEmail"
          />
          <div class="link" @click="handleGoBack">Đưa tôi trở về</div>
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
definePageMeta({ layout: "auth" });
useHead({
  title: "Xác nhận email",
});
const { requestResendVerifyEmail } = useAuth();
const formInput = ref({
  identifier: "",
});

const formError = ref({
  identifier: "",
});

const buttonText = computed(() => {
  if (countdown.value === 0) {
    return "Đồng ý";
  }
  return `Gửi lại sau ${countdown.value} giây`;
});
const countdown = ref(0);
const countdownRef = ref<number | null>(null);

const isError = ref<boolean>(false);
const noticeMessage = ref<string>("");

const handleRequestEmail = async () => {
  validateForm();
  if (!isFormValid.value) {
    return
  }
  isLoading.value = true;
  const res = await requestResendVerifyEmail(formInput.value.identifier);
  isLoading.value = false;
  if (res) {
    noticeMessage.value = `Hệ thống đã gửi thông báo xác nhận vào địa chỉ <strong>${res.data.email}</strong>.
          Vui lòng kiểm tra và làm theo hướng dẫn. Nếu chưa thấy, hãy tìm trong
          hòm thư rác. Thông báo xác nhận có hiệu lực trong vòng
          <strong>${res.data.duration / 60 / 60} giờ</strong>`;

    isError.value = false;
  } else {
    noticeMessage.value = `Có lỗi xảy ra, vui lòng kiểm tra lại tên đăng nhập/email vừa nhập`;
    isError.value = true;
  }

  countdown.value = 60;
  countdownRef.value = window.setInterval(() => {
    if (countdown.value === 0 && countdownRef.value) {
      window.clearInterval(countdownRef.value);
      countdownRef.value = null;
      return;
    }
    countdown.value -= 1;
  }, 1000);
};

onBeforeUnmount(() => {
  if (countdownRef.value) {
    window.clearInterval(countdownRef.value);
  }
});

const formRules = {
  identifier: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.identifier = "Mời nhập tên đăng nhập hoặc mật khẩu";
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

const router = useRouter();
const route = useRoute();

const handleGoBack = () => {
  const redirect = (route.query.redirect as string) || "/auth/login";
  router.push({ path: redirect });
};

const isButtonDisabled = computed(() => {
  return countdown.value > 0 || !isFormValid.value;
});

const handleInput = (key: string, value: string) => {
  formInput.value[key as keyof typeof formInput.value] = value;
  formError.value[key as keyof typeof formError.value] = "";
};

const isLoading = ref(false);
</script>
<style lang="scss" scoped>
.request-email-page {
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

    .request-email-form {
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

        .request-email-button {
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
      }

      .notice {
        border: 2px dashed $color-success;
        padding: 28px;
        border-radius: 8px;
        text-align: left;
        color: $color-success;
        background-color: rgba($color-success, 0.1);

        &.error {
          border: 2px dashed $color-danger;
          color: $color-danger;
          background-color: rgba($color-danger, 0.1);
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
