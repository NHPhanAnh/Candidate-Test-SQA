<template>
  <UModal
    v-model:open="isOpen"
    title="Chỉnh sửa tin đăng"
    :ui="{ content: 'max-w-[980px]' }"
  >
    <template #body>
      <div class="body">
        <div class="form">
          <AppInputText
            :label="'Tiêu đề tin đăng'"
            :required="true"
            :error="''"
            :placeholder="'Mời nhập tiêu đề'"
            :value="formInput.title"
            :slim-error="true"
            class="title-input"
            @input="handleInput('title', $event)"
          />
          <div class="row">
            <AppInputDatepicker
              :label="'Hạn nộp hồ sơ'"
              :required="true"
              :value="formInput.dueDate"
              :is-teleport="'html'"
              :slim-error="true"
              :error="''"
              :placeholder="'Mời chọn ngày nộp hồ sơ'"
              @input="handleInput('dueDate', $event)"
            />
            <div class="number-input">
              <div class="label">
                <span>Số lượng</span>
                <span class="required">Bắt buộc</span>
              </div>
              <UInputNumber
                v-model="formInput.quantity"
                variant="none"
                :min="0"
                :max="120"
                :step="1"
                orientation="vertical"
                class="num-input"
              />
            </div>
          </div>
          <div class="row">
            <div class="textarea-block">
              <div class="label">
                <span class="text">Mô tả công việc</span>
                <!-- ><span class="required">Bắt buộc</span> -->
              </div>
              <AppInputBasicTextEditor
                :value="formInput.description"
                @input="handleInput('description', $event)"
              />
            </div>
          </div>
          <div class="row">
            <div class="textarea-block">
              <div class="label">
                <span class="text">Yêu cầu công việc</span>
                <!-- ><span class="required">Bắt buộc</span> -->
              </div>
              <AppInputBasicTextEditor
                :value="formInput.requirement"
                @input="handleInput('requirement', $event)"
              />
            </div>
            <div class="textarea-block">
              <div class="label">
                <span class="text">Quyền lợi</span>
                <!-- ><span class="required">Bắt buộc</span> -->
              </div>
              <AppInputBasicTextEditor
                :value="formInput.benefit"
                @input="handleInput('benefit', $event)"
              />
            </div>
          </div>
          <div class="row">
            <div class="textarea-block">
              <div class="label">
                <span class="text">Từ khóa</span>
                <!-- ><span class="required">Bắt buộc</span> -->
              </div>
              <AppInputBasicTextEditor
                :value="formInput.keyword"
                @input="handleInput('keyword', $event)"
              />
            </div>
          </div>
          <UCheckbox
            :model-value="formInput.isAutoSendEmail"
            :label="'Tự động gửi mail khi có ứng viên ứng tuyển'"
            class="checkbox"
            @update:model-value="formInput.isAutoSendEmail = $event as boolean"
          />
          <div v-if="formInput.isAutoSendEmail" class="wrapper">
            <div class="header">
              <div class="label">Mẫu email</div>
              <AppInputSearchSelect
                :label="''"
                :required="false"
                :options="mailTemplateOption"
                :value="formInput.mailTemplate"
                :error="''"
                :placeholder="'Mời chọn mẫu email'"
                :remote-filter="false"
                :multiple="false"
                :allow-clear="true"
                :is-paginated="false"
                :slim-error="true"
                :fetch-fn="null"
                @input="handleInput('mailTemplate', $event)"
                @clear-value="handleInput(`mailTemplate`, null)"
                @search-filter="
                  () => {
                    mailTemplateList = [];
                  }
                "
              />
              <div
                class="preview-button"
                :class="{ disabled: !formInput.mailTemplate }"
                @click="
                  formInput.mailTemplate
                    ? (isPreviewModalOpen = true)
                    : () => {}
                "
              >
                <Icon name="icon-park-outline:preview-open" />
                <span>Xem trước</span>
              </div>
            </div>
            <div class="body">
              <div class="mail-subject">
                {{ `Tiêu đề: ${selectedTemplate?.subject || ""}` }}
              </div>
              <div class="mail-body w-full">
                <div
                  v-if="isFetchingMailDetail"
                  class="spinner h-[104px] items-center justify-center w-full flex"
                >
                  <AppSpinnerHalfCircle class="" />
                </div>
                <div v-else class="content" v-html="mappedBody"></div>
              </div>
            </div>
            <OrgAdJobEditModalMailPreview
              v-model="isPreviewModalOpen"
              :data="props.data"
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
          class="submit-btn btn"
          :text="'Cập nhật'"
          :is-disabled="isSubmitDisabled"
          :is-loading="isLoading"
          @click="handleSubmit"
        />
      </div>
    </template>
  </UModal>
</template>
<script setup lang="ts">
import { cloneDeep } from "lodash";
import moment from "moment";

type TProps = {
  data: any;
  modelValue: boolean;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

const { getMailTemplates, getMailTemplateDetail } = useMailTemplateApi();
const { updateJobAd } = useJobAdApi();

const isDateChange = ref<boolean>(false);
const originalDueDate = ref<any>(null);
const mailTemplateDetail = ref<Record<string, any> | null>(null);
const isFetchingMailDetail = ref<boolean>(false);
const isLoading = ref<boolean>(false);
const defaultForm = {
  title: "",
  dueDate: undefined,
  quantity: 0,
  keyword: "",
  description: "",
  requirement: "",
  benefit: "",
  isAutoSendEmail: false,
  emailTemplateId: -1,
};
const formInput = ref<any>(defaultForm);
const mailTemplateList = ref<Record<string, any>[]>([]);
const isPreviewModalOpen = ref<boolean>(false);

const isSubmitDisabled = computed(() => {
  if (
    !formInput.value.title.trim() ||
    !formInput.value.dueDate ||
    !formInput.value.quantity
  ) {
    return true;
  }

  if (formInput.value.isAutoSendEmail && !formInput.value.mailTemplate) {
    return true;
  }
  return false;
});

const selectedTemplate = computed(() => {
  return mailTemplateList.value.find(
    (template) => template.id === formInput.value?.mailTemplate?.value,
  );
});

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const mailTemplateOption = computed(() => {
  return mailTemplateList.value.map((mail) => ({
    label: mail.name,
    value: mail.id,
  }));
});

const mappedBody = computed(() => {
  if (!selectedTemplate.value?.body) {
    return "Nội dung email";
  }

  return wrapTemplateVariables(
    selectedTemplate.value.body,
    mailTemplateDetail.value?.placeholders ?? ([] as TTemplatePlaceholder[]),
  );
});

async function handleSubmit() {
  const form = cloneDeep(formInput.value);

  const payload: any = {
    title: form.title.trim(),
    quantity: form.quantity,
    keyword: form.keyword,
    description: form.description,
    requirement: form.requirement,
    benefit: form.benefit,
    isAutoSendEmail: form.isAutoSendEmail,
  };

  if (isDateChange.value) {
    payload.dueDate = toUtcDate(form.dueDate);
  } else {
    payload.dueDate = originalDueDate.value;
  }

  if (form.isAutoSendEmail) {
    console.log({ selectedTemplate: selectedTemplate.value });
    payload.emailTemplateId = selectedTemplate.value?.id;
  }

  isLoading.value = true;
  const success = await updateJobAd(props.data.id, payload);
  isLoading.value = false;
  if (success) {
    emits("submit");
  }
}

function handleCancel() {
  emits("update:modelValue", false);
}

function handleInput(key: string, value: any) {
  if (key == "dueDate") {
    isDateChange.value = true;
  }
  formInput.value[key] = value;
}

async function fetchMailTemplate(params: any, controller?: AbortController) {
  const res = await getMailTemplates(params, controller);
  if (!res) {
    return null;
  }

  const nextPage = res.data.data.filter((mail: any) => mail.isActive);
  mailTemplateList.value = [...mailTemplateList.value, ...nextPage];
}

async function syncMailTemplate() {
  await fetchMailTemplate({ pageSize: 999 });
  console.log(mailTemplateOption.value);
  const template = mailTemplateOption.value.find(
    (template: any) => template.value == formInput.value.emailTemplateId,
  );
  console.log({ template });
  formInput.value.mailTemplate = template;
}

watch(
  () => props.modelValue,
  (value) => {
    if (value) {
      formInput.value = cloneDeep(props.data);
      const localDate = moment(props.data.dueDate * 1000).format("L");
      isDateChange.value = false;
      originalDueDate.value = props.data.dueDate;
      formInput.value.dueDate = localDate;
      syncMailTemplate();
    } else {
      formInput.value = defaultForm;
    }
  },
);

watch(
  () => formInput.value.mailTemplate,
  async (newVal) => {
    if (!newVal) {
      mailTemplateDetail.value = null;
      return;
    }
    isFetchingMailDetail.value = true;
    const res = await getMailTemplateDetail(newVal.value);
    isFetchingMailDetail.value = false;
    mailTemplateDetail.value = res.data;
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.wrapper {
  border-radius: 6px;
  border: 1px solid $color-gray-300;
  overflow: hidden;

  .header {
    padding: 8px;
    display: flex;
    flex-direction: row;
    gap: 12px;
    align-items: center;
    background-color: $color-gray-100;

    .label {
      font-size: 14px;
      font-weight: 600;
      color: $text-light;
    }

    .preview-button {
      display: flex;
      flex-direction: row;
      gap: 6px;
      font-size: 14px;
      font-weight: 600;
      line-height: 20px;
      align-items: center;
      color: $text-light;
      cursor: pointer;

      &:hover:not(.disabled) {
        color: $color-primary-500;
      }

      &.disabled {
        $color: $color-gray-300;
        cursor: default;
      }

      .iconify {
        display: block;
        font-size: 20px;
        height: 20px;
      }
    }
  }

  .body {
    padding: 8px;
    display: flex;
    flex-direction: column;
    gap: 8px;

    .mail-subject {
      font-size: 14px;
      font-weight: 600;
      color: $text-light;
    }

    .mail-body {
      padding: 8px;
      border-radius: 6px;
      border: 1px solid $color-gray-300;
      font-size: 14px;
      min-height: 120px;

      :deep(.content) {
        color: $color-gray-400;
        line-height: 24px;
        .chip {
          border: 1px solid $color-gray-300;
          // color: $color-info;
          padding: 1px 3px;
          border-radius: 4px;
        }
      }
    }
  }
}

.checkbox {
  :deep(button) {
    cursor: pointer;

    &:disabled {
      cursor: default;
    }
  }

  :deep(label) {
    font-size: 14px;
    line-height: 21px;
    font-weight: 400;
    color: $text-light;
    cursor: pointer;

    &.cursor-not-allowed {
      cursor: default;
    }
  }
}

:deep(.text-input),
:deep(.number-input) {
  .input {
    padding: 6px 8px;
    input {
      font-size: 14px;
    }
  }
}

.number-input {
  .label {
    font-size: 14px;
    color: $text-light;
    margin-bottom: 4px;
  }
}
.body {
  .textarea-block {
    display: flex;
    flex-direction: column;
    gap: 4px;
    flex: 1;
    .label {
      display: flex;
      flex-direction: row;
      gap: 8px;
      align-items: center;
      width: fit-content;

      .text {
        font-size: 14px;
        line-height: 21px;
      }

      .required {
        font-size: 12px;
        font-style: italic;
        color: $color-danger;
      }
    }
  }
  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    :deep(.search-select-input),
    :deep(.number-input),
    :deep(.datepicker-input) {
      max-width: calc((100% - 8px) * 0.5);
      min-width: calc((100% - 8px) * 0.5);
    }

    @media (max-width: 768px) {
      flex-direction: column;
      :deep(.search-select-input),
      :deep(.number-input),
      :deep(.datepicker-input) {
        max-width: 100%;
        min-width: 100%;
      }
    }
  }
  display: flex;
  flex-direction: column;
  gap: 8px;

  .job-ad-info {
    font-size: 14px;
    border: 1px solid $color-gray-300;
    border-radius: 6px;
    padding: 6px;

    display: flex;
    flex-direction: column;
    gap: 8px;

    .hr-info {
      display: flex;
      flex-direction: row;
      gap: 8px;
      justify-content: space-between;
      flex-wrap: wrap;
      .hr-info-label {
        display: flex;
        flex-direction: row;
        gap: 4px;
        align-items: center;

        .iconify {
          display: block;
          font-size: 20px;
        }
      }
    }

    .info-dept-pos {
      display: flex;
      flex-direction: row;
      gap: 8px;
    }

    .info-top {
      display: flex;
      flex-direction: row;
      justify-content: space-between;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;

      .chip {
        border-radius: 4px;
        padding: 4px;
        border: 1px solid $color-gray-300;
        font-size: 12px;
        font-weight: 500;
      }
    }

    .misc-text {
      font-style: italic;
    }
  }

  .form {
    display: flex;
    flex-direction: column;
    gap: 6px;

    .grade-input {
      display: flex;
      flex-direction: column;
      gap: 4px;

      .label {
        font-size: 14px;
        color: $text-light;
      }
    }

    .num-input {
      width: 100%;
      :deep(input) {
        border: 1px solid rgba($color-primary-800, 0.1);
        border-radius: 12px;

        &:hover,
        &:focus {
          border: 1px solid rgba($color-primary-400, 1);
        }
      }
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

  .line {
    display: flex;
    flex-direction: row;
    gap: 8px;
    justify-content: space-between;
    flex: 1;
  }

  .iconify {
    font-size: 20px;
    display: block;
    width: 20px;
    cursor: pointer;
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
  min-width: 64px;

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
