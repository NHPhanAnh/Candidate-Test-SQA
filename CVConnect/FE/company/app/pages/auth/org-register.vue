<template>
  <div class="org-register">
    <div class="content">
      <div class="header">
        <div class="logo">
          <img src="/logo-horizontal.svg" />
        </div>
        <div class="title">Đăng ký tài khoản doanh nghiệp</div>
      </div>
      <template v-if="mode == 'registering'">
        <div class="top">
          <UStepper
            ref="stepper"
            v-model="activeTab"
            :items="items"
            class="w-full stepper"
          />
        </div>
        <div class="description">
          {{ description[activeTab] }}
        </div>
        <div class="step-content">
          <OrgRegisterStep1
            v-show="activeTab == 0"
            :data="formData as Record<string, unknown>"
            @input="handleInputForm($event)"
          />
          <OrgRegisterStep2
            v-show="activeTab == 1"
            :data="formData as Record<string, unknown>"
            @input="handleInputForm($event)"
          />
          <OrgRegisterStep3
            v-show="activeTab == 2"
            :data="formData as Record<string, unknown>"
            @input="handleInputForm($event)"
          />
        </div>
        <div class="buttons">
          <AppButton
            class="back-button btn"
            :text="prevButtonText"
            @click="handleGoBack"
          />
          <AppButton
            class="next-button btn"
            :text="nextButtonText"
            :is-disabled="isNextButtonDisabled"
            :is-loading="isNextButtonLoading"
            @click="handleGoNext"
          />
        </div>
      </template>
      <template v-else>
        <div
          class="confirming-message"
          v-html="
            `Hệ thống đã gửi thông báo xác nhận vào hòm thư điện tử của bạn.
          Vui lòng kiểm tra và làm theo hướng dẫn. Nếu chưa thấy, hãy tìm trong
          hòm thư rác. Thông báo xác nhận có hiệu lực trong vòng
          <strong>${duration} giờ</strong>`
          "
        ></div>
        <NuxtLink class="link" to="/auth/login">Đưa tôi trở về</NuxtLink>
      </template>
    </div>
    <div class="footer-wrapper">
      <AppFooter />
    </div>
  </div>
</template>
<script setup lang="ts">
import type { StepperItem } from "@nuxt/ui";
import { EMAIL_REGEX, PASSWORD_REGEX } from "~/const/auth";

definePageMeta({
  layout: "auth",
});

const router = useRouter();
const stepperRef = useTemplateRef("stepper");
const { registerOrgAdmin } = useAuth();

const items = ref<StepperItem[]>([
  {
    title: "Thông tin doanh nghiệp",
    icon: "ic:round-location-city",
  },
  {
    title: "Địa chỉ & Logo",
    icon: "ic:round-edit-location-alt",
  },
  {
    title: "Thông tin tài khoản",
    icon: "ic:round-person",
  },
]);

const isNextButtonLoading = ref<boolean>(false);
const activeTab = ref<number>(0);
const duration = ref<number>(0);

type TRegisteringMode = "confirming" | "registering";
const mode = ref<TRegisteringMode>("registering");

const formData = ref<Record<string, any>>({
  name: "",
  website: "",
  companySize: "",
  companyType: [],
  description: "",
  addresses: [],
  coverPhoto: null,
  logo: null,
  fullName: "",
  email: "",
  username: "",
  password: "",
  passwordConfirm: "",
});

const prevButtonText = computed(() => {
  return "Trở lại";
});

const nextButtonText = computed(() => {
  if (activeTab.value == 2) {
    return "Tạo tài khoản";
  }
  return "Tiếp tục";
});

const isFormValid = computed(() => {
  if (
    !formData.value.username.trim() ||
    !formData.value.password ||
    !formData.value.fullName.trim() ||
    !formData.value.email.trim() ||
    !EMAIL_REGEX.test(formData.value.email) ||
    !PASSWORD_REGEX.test(formData.value.password) ||
    !formData.value.name ||
    formData.value.password != formData.value.passwordConfirm ||
    formData.value.logo == null
  ) {
    return false;
  }

  for (const address of formData.value.addresses) {
    if (!address.province || !address.detailAddress) {
      return false;
    }
  }

  return true;
});

const isNextButtonDisabled = computed(() => {
  if (activeTab.value != 2) {
    return false;
  }

  return !isFormValid.value;
});

const handleInputForm = (e: Record<string, any>) => {
  formData.value[e.key] = e.value;
};

const handleGoBack = () => {
  if (activeTab.value == 0) {
    router.push({ path: "/auth/login" });
  } else {
    stepperRef.value?.prev();
  }
};

const handleGoNext = async () => {
  if (activeTab.value == 2) {
    const payload: Record<string, any> = {
      username: formData.value.username.trim()
        ? formData.value.username.trim()
        : undefined,
      password: formData.value.password ? formData.value.password : undefined,
      fullName: formData.value.username.trim()
        ? formData.value.fullName.trim()
        : undefined,
      email: formData.value.username.trim()
        ? formData.value.email.trim()
        : undefined,
      logo: formData.value.logo ? formData.value.logo : undefined,
      coverPhoto: formData.value.coverPhoto
        ? formData.value.coverPhoto
        : undefined,
      organization: {
        name: formData.value.name.trim()
          ? formData.value.name.trim()
          : undefined,
        description: formData.value.description
          ? formData.value.description
          : undefined,
        website: formData.value.website.trim()
          ? formData.value.website.trim()
          : undefined,
      },
    };

    const staffCount = formData.value.companySize?.split("-");
    if (staffCount) {
      const from = staffCount[0];
      const to = staffCount[1];

      if (from) {
        payload.organization.staffCountFrom = from;
      }
      if (to) {
        payload.organization.staffCountTo = to;
      }
    }

    const addresses = formData.value.addresses.map((address: any) => {
      return {
        province: address.province,
        ward: address.ward ? address.ward : undefined,
        detailAddress: address.detailAddress
          ? address.detailAddress
          : undefined,
        headquarter: address.headquarter ? address.headquarter : false,
      };
    });

    if (addresses && addresses.length) {
      payload.addresses = addresses;
    }

    const industryIds = formData.value.companyType.map(
      (type: any) => type.value,
    );
    if (industryIds && industryIds.length) {
      payload.industryIds = industryIds;
    }

    const formDataReq = new FormData();

    const { logo, coverPhoto, ...rest } = payload;

    const cleanedPayload = removeUndefined(rest);
    console.log("clean payload", cleanedPayload);

    formDataReq.append(
      "request",
      new Blob([JSON.stringify(cleanedPayload)], { type: "application/json" }),
    );

    if (logo instanceof File) {
      formDataReq.append("logo", logo);
    }
    if (coverPhoto instanceof File) {
      formDataReq.append("coverPhoto", coverPhoto);
    }

    isNextButtonLoading.value = true;
    const res = await registerOrgAdmin(formDataReq);
    if (res && res.data.needVerifyEmail) {
      duration.value = res.data.duration / 60 / 60;
      mode.value = "confirming";
    } else {
      const username = res.data.username || "";
      isNextButtonLoading.value = false;
      router.push({ path: "/auth/login", query: { username } });
    }
    isNextButtonLoading.value = false;
  }
  stepperRef.value?.next();
};

const description = [
  "Nhập các thông tin cơ bản của doanh nghiệp như tên công ty, số lượng nhân sự, lĩnh vực hoạt động, v.v",
  "Cung cấp địa chỉ và tải lên logo hoặc hình ảnh nhận diện của doanh nghiệp.",
  "Tạo tài khoản với tên đăng nhập, email và mật khẩu để quản lí doanh nghiệp của bạn.",
];
//
// watch(formData.value, (value) => {
//   console.log("form data change: ", value);
// });
</script>
<style lang="scss" scoped>
.org-register {
  padding-top: 36px;

  .footer-wrapper {
    margin-top: 96px;
  }

  @include respond-max($breakpoint-sm) {
    padding-top: 12px;
  }

  .content {
    padding-left: 14%;
    padding-right: 14%;
    min-height: calc(100vh - 318px);

    @include respond-max($breakpoint-md) {
      padding-left: 9%;
      padding-right: 9%;
    }

    @include respond-max($breakpoint-sm) {
      padding-left: 5%;
      padding-right: 5%;
    }

    display: flex;
    flex-direction: column;
    align-items: center;

    .confirming-message {
      border: 2px dashed $color-success;
      padding: 28px;
      border-radius: 8px;
      text-align: left;
      color: $color-success;
      background-color: rgba($color-success, 0.1);
      width: 70%;
    }

    .buttons {
      margin-top: 24px;
      display: flex;
      flex-direction: row;
      gap: 8px;
      align-items: center;
      justify-content: flex-end;
      width: 100%;

      .btn {
        font-size: 14px;
        padding: 6px 12px;
        min-width: 102px;
        border-radius: 4px;
      }

      .back-button {
        border: 1px solid $color-primary-400;
        color: $color-primary-400;
      }

      .next-button {
        background-color: $color-primary-400;
        border: 1px solid $color-primary-400;
        color: $text-dark;

        &.disabled {
          background-color: $color-gray-400;
          border: 1px solid $color-gray-400;
          color: $text-dark;
        }
      }
    }

    .header {
      display: flex;
      flex-direction: column;
      align-items: center;
      width: 100%;
      margin-bottom: 12px;
      .logo {
        display: flex;
        justify-content: center;
        margin-bottom: 12px;
        img {
          height: 58px;
        }
      }

      .title {
        text-align: center;
        font-weight: 900;
        font-size: 24px;
        color: $color-primary-500;
        line-height: 24px;
        margin-bottom: 24px;
      }
    }

    .top {
      width: 100%;
      margin-bottom: 24px;
      .stepper {
        :deep(button) {
          cursor: pointer;
        }
      }
    }

    .title {
      font-size: 16px;
      list-style: 20px;
      font-weight: 700;
      margin-bottom: 8px;
      color: $text-light;
    }
    .description {
      font-size: 14px;
      line-height: 20px;
      color: $color-gray-500;
      width: min(500px, 80%);
      text-align: center;
      font-style: italic;
    }

    .step-content {
      margin-top: 24px;
      width: min(750px, 100%);
      // overflow-y: auto;
      min-height: 0;

      :deep(.text-input) {
        .input {
          padding: 4px 6px;
          input {
            font-size: 14px;
          }
        }
      }
    }

    .link {
      color: $color-primary-500;
      text-decoration: underline;
      font-style: italic;
      margin-top: 12px;
    }
  }
}
</style>
