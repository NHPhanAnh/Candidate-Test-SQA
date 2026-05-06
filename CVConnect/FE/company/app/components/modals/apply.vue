<template>
  <UModal
    v-model:open="isOpen"
    :title="modalTitle"
    :ui="{ content: 'max-w-[640px]' }"
  >
    <template #body>
      <div class="body">
        <div v-if="userInfo == null" class="login-alert">
          <div class="message">
            Vui lòng đăng nhập để sử dụng chức năng này.
            <NuxtLink :to="loginRedirectLink" class="link">Đăng nhập</NuxtLink>
          </div>
        </div>
        <div v-else class="apply-form">
          <div class="label">Chọn hồ sơ đã gửi trước đó</div>
          <div v-if="jobAdCandidateIdList.length" class="cv-list">
            <div
              v-for="jobAdCan of jobAdCandidateIdList.slice(0, 3)"
              :key="jobAdCan.id"
              class="cv-block"
              @click="handleSelectExistingProfile(jobAdCan)"
            >
              <div class="radio-input">
                <input
                  type="radio"
                  name="levels"
                  class="radio"
                  :value="formInput.cv == jobAdCan.id"
                  :checked="formInput.cv == jobAdCan.id"
                />
                <span>{{ `${jobAdCan.attachFile.originalFilename}` }}</span>
              </div>
              <Icon
                name="icon-park-outline:preview-open"
                @click.stop="handlePreview(jobAdCan.attachFile.url)"
              />
            </div>
          </div>
          <div class="cv-select">
            <div class="radio-input ml-[7px]" @click="handleInput('cv', -1)">
              <input
                type="radio"
                name="levels"
                class="radio"
                :value="formInput.cv == -1"
                :checked="formInput.cv == -1"
              />
              <span>{{ `Tạo đơn ứng tuyển mới` }}</span>
            </div>
            <UFileUpload
              v-if="formInput.cv == -1"
              v-model="uploadFile"
              accept="application/pdf"
              class="file-upload"
              :disabled="formInput.cv != -1"
            />
          </div>
          <div class="form">
            <AppInputText
              :label="'Tên đầy đủ'"
              :required="true"
              :error="''"
              :placeholder="'Tên đầy đủ'"
              :value="formInput.fullName"
              :is-disabled="isFormDisabled"
              :slim-error="true"
              :title="''"
              class="text-input"
              @input="handleInput('fullName', $event)"
            />

            <AppInputText
              :label="'Email'"
              :required="true"
              :error="''"
              :placeholder="'Email'"
              :value="formInput.email"
              :is-disabled="isFormDisabled"
              :slim-error="true"
              :title="''"
              class="text-input"
              @input="handleInput('email', $event)"
            />

            <AppInputText
              :label="'SĐT'"
              :required="true"
              :error="''"
              :placeholder="'SĐT'"
              :value="formInput.phone"
              :is-disabled="isFormDisabled"
              :slim-error="true"
              :title="''"
              class="text-input"
              @input="handleInput('phone', $event)"
            />

            <AppInputTextarea
              v-model="formInput.coverLetter"
              :label="'Thư giới thiệu'"
              :required="false"
              :placeholder="'Mời nhập thư giới thiệu'"
              :is-disabled="isFormDisabled"
              :error="''"
              :show-error="false"
              :slim-error="true"
            />
          </div>
        </div>
      </div>
    </template>
    <template #footer>
      <div class="modal-footer">
        <AppButton
          class="cancel-btn btn"
          :text="'Đóng'"
          @click="handleCancel"
        />
        <AppButton
          v-if="userInfo != null"
          class="submit-btn btn"
          :text="'Xác nhận'"
          :is-disabled="isSubmitDisabled"
          :is-loading="isLoading"
          @click="handleSubmit"
        />
      </div>
    </template>
  </UModal>
</template>
<script setup lang="ts">
type TProps = {
  modelValue: boolean;
  jobAd: any;
};

const props = defineProps<TProps>();

const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);
const { getCandidateInfoApply, applyJob } = useApplyApi();
const route = useRoute();
const router = useRouter();

const uploadFile = ref<any>(null);
const jobAdCandidateIdList = ref<any>([]);

const formInput = ref<any>({
  cv: undefined,
  fullName: "",
  phone: "",
  email: "",
  coverLetter: "",
});

const modalTitle = computed(() => {
  return `Ứng tuyển vào ${props.jobAd.title}`;
});

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const isLoading = ref<boolean>(false);

function handleInput(key: string, value: any) {
  formInput.value[key] = value;
}

function handleCancel() {
  emits("update:modelValue", false);
}

const isFormDisabled = computed(() => {
  return formInput.value.cv != -1;
});

const loginRedirectLink = computed(() => {
  const redirectLink = `/auth/login?redirect=${route.fullPath}`;
  return redirectLink;
});

const isSubmitDisabled = computed(() => {
  const form = formInput.value;

  if (!form.fullName.trim() || !form.email.trim() || !form.phone.trim()) {
    return true;
  }

  if (form.cv == -1 && !uploadFile.value) {
    return true;
  }

  if (form.cv != -1 && form.cv == undefined) {
    return true;
  }

  return false;
});

async function handleSubmit() {
  const formDataReq = new FormData();
  let payload: any = {
    jobAdId: props.jobAd.id,
    fullName: formInput.value.fullName.trim(),
    email: formInput.value.email.trim(),
    phone: formInput.value.phone.trim(),
    coverLetter: formInput.value.coverLetter.trim(),
  };

  if (formInput.value.cv == -1 && uploadFile.value instanceof File) {
    formDataReq.append("cvFile", uploadFile.value);
  }

  if (formInput.value.cv != -1 && formInput.value.cv != undefined) {
    payload = {
      candidateInfoApplyId: formInput.value.cv,
      jobAdId: props.jobAd.id,
    };
  }

  formDataReq.append(
    "request",
    new Blob([JSON.stringify(payload)], { type: "application/json" }),
  );

  isLoading.value = true;
  const success = await applyJob(formDataReq);
  isLoading.value = false;

  if (success) {
    formInput.value = {
      cv: undefined,
      fullName: "",
      phone: "",
      email: "",
      coverLetter: "",
    };
    emits("submit");
  }
}

function handlePreview(url: string) {
  window.open(url, "_blank");
}

function handleSelectExistingProfile(jobAdCan: any) {
  formInput.value = {
    fullName: jobAdCan.fullName,
    phone: jobAdCan.phone,
    cv: jobAdCan.id,
    email: jobAdCan.email,
    coverLetter: jobAdCan.coverLetter,
  };
}

watch(isOpen, async (val) => {
  if (val) {
    const res = await getCandidateInfoApply();
    jobAdCandidateIdList.value = res.data.data;
    console.log({ res });
  }
});
</script>
<style lang="scss" scoped>
.body {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .radio-input {
    display: flex;
    flex-direction: row;
    width: fit-content;
    gap: 6px;
    align-items: center;
    font-size: 14px;
    cursor: pointer;
    color: $text-light;
    input[type="radio"] {
      appearance: none;
      width: 16px;
      height: 16px;
      border-radius: 50%;
      border: 1px solid $color-gray-400;
      background-color: #fff;
      cursor: pointer;

      &:checked {
        appearance: auto;
        accent-color: $color-primary-500;
      }

      &:hover {
        border-color: $color-primary-500;
      }

      &:focus {
        outline: none;
      }
    }
  }

  .divider {
    width: 100%;
    display: block;
    height: 1px;
    background-color: $color-gray-200;
  }

  .login-alert {
    display: flex;
    flex-direction: column;
    gap: 12px;

    font-size: 14px;

    .link {
      text-decoration: underline;
      cursor: pointer;
      color: $color-primary-500;
    }
  }

  .apply-form {
    :deep(div[role="button"]),
    :deep(.iconify) {
      cursor: pointer;
    }

    .label {
      font-size: 14px;
      color: $text-light;
      margin-bottom: 4px;
    }

    .cv-list {
      display: flex;
      flex-direction: column;
      gap: 4px;
      margin-bottom: 8px;

      .cv-block {
        padding: 12px 12px 12px 6px;
        border: 1px solid $color-gray-300;
        border-radius: 6px;
        cursor: pointer;

        display: flex;
        justify-content: space-between;
        align-items: center;

        .iconify {
          display: block;
          font-size: 20px;
          height: 20px;
          width: 20px;
          min-width: 20px;
        }
      }
    }

    .cv-select {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }

    .form {
      display: flex;
      flex-direction: column;
      gap: 8px;
      margin: 8px 0px;
    }
  }

  :deep(textarea) {
    max-height: 90px;
  }

  .required {
    font-size: 12px;
    font-style: italic;
    color: $color-danger;
    margin-left: 8px;
  }

  :deep(.text-input) {
    flex: 1;
    .input {
      padding: 4px 6px;
      input {
        font-size: 14px;
      }
    }
  }

  :deep(.template-body) {
    padding: 8px;
    border-radius: 6px;
    border: 1px solid $color-gray-300;
    font-size: 14px;
    min-height: 120px;
    .chip {
      border: 1px solid $color-gray-300;
      background-color: #ffffff;
      padding: 1px 3px;
      border-radius: 4px;
      font-size: 13px;
    }
  }

  .line {
    display: flex;
    flex-direction: row;
    gap: 8px;
    justify-content: space-between;
    flex: 1;
  }
}

.modal-footer {
  width: 100%;
  display: flex;
  flex-direction: row;
  gap: 8px;
  justify-content: flex-end;
}

.btn {
  font-size: 14px;
  padding: 6px 12px;

  &.cancel-btn {
    border: 1px solid $color-primary-500;
    color: $color-primary-500;
  }

  &.submit-btn {
    background-color: $color-primary-500;
    border: 1px solid $color-primary-500;
    color: $text-dark;

    &.disabled {
      background-color: $color-gray-400;
      border: 1px solid $color-gray-400;
    }
  }
}
</style>
