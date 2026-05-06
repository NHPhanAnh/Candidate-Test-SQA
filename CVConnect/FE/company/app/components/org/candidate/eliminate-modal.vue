<template>
  <UModal
    v-model:open="isOpen"
    title="Loại ứng viên khỏi tin tuyển dụng"
    :ui="{ content: 'max-w-[840px]' }"
  >
    <template #body>
      <OrgCandidatePreviewEmailModal
        v-model="isPreviewModalOpen"
        :data="previewData"
        :template-id="
          isUseBlankTemplate ? null : formInput.emailTemplate?.value
        "
      />
      <div class="body">
        <AppInputSearchSelect
          :label="'Lí do loại ứng viên'"
          :required="true"
          :options="reasons"
          :value="formInput.reason"
          :error="''"
          :placeholder="'Mời chọn lí do'"
          :remote-filter="false"
          :multiple="false"
          :is-disabled="false"
          :slim-error="true"
          :fetch-fn="fetchReason"
          @input="handleInput('reason', $event)"
          @clear-value="handleInput('reason', null)"
          @search-filter="
            () => {
              reasons = [];
            }
          "
        />
        <AppInputTextarea
          v-model="formInput.reasonDetail"
          :label="'Lí do chi tiết'"
          :required="false"
          :placeholder="'Mời nhập lí do chi tiết'"
          :is-disabled="false"
          :error="''"
          :slim-error="true"
          :show-error="false"
        />
        <UCheckbox
          class="checkbox"
          :model-value="formInput.sendEmail"
          :label="'Gửi email'"
          @update:model-value="handleInput('sendEmail', $event)"
        />
        <template v-if="formInput.sendEmail">
          <div class="line">
            <UCheckbox
              class="checkbox"
              :model-value="isUseBlankTemplate"
              :label="'Sử dụng mẫu email trống'"
              @update:model-value="
                ($event) => (isUseBlankTemplate = $event as boolean)
              "
            />
            <div
              class="preview-button"
              :title="
                !isPreviewable
                  ? 'Vui lòng chọn mẫu hoặc nhập đầy đủ tiêu đề và nội dung cho email'
                  : ''
              "
              :class="{ 'no-preview': !isPreviewable }"
              @click="handlePreviewClick"
            >
              <Icon name="icon-park-outline:preview-open" />
              <span>Xem trước</span>
            </div>
          </div>
          <template v-if="!isUseBlankTemplate">
            <AppInputSearchSelect
              :label="'Mẫu email'"
              :required="true"
              :options="templateListOpts"
              :value="formInput.emailTemplate"
              :error="''"
              :placeholder="'Mời chọn mẫu'"
              :remote-filter="true"
              :multiple="false"
              :is-disabled="false"
              :slim-error="true"
              :fetch-fn="fetchTemplate"
              @input="handleInput('emailTemplate', $event)"
              @clear-value="handleInput('emailTemplate', null)"
              @search-filter="
                () => {
                  templateList = [];
                }
              "
            />
            <template v-if="formInput.emailTemplate">
              <AppInputText
                :label="'Tiêu đề'"
                :required="false"
                :error="''"
                :placeholder="'Mời nhập tiêu đề'"
                :is-disabled="true"
                :slim-error="true"
                :value="templateDetail?.subject || 'Tiêu đề'"
              />
              <div class="editor">
                <div class="label">Nội dung email</div>
                <div class="template-body" v-html="mappedBody"></div>
              </div>
            </template>
          </template>
          <template v-else>
            <div class="line">
              <AppInputText
                :label="'Tên mẫu'"
                :required="false"
                :error="''"
                :slim-error="true"
                :placeholder="'Mời nhập tên'"
                :value="formInput.templateName"
                class="text-input"
                @input="handleInput('templateName', $event)"
              />
              <AppInputText
                :label="'Mã mẫu'"
                :required="false"
                :error="''"
                :slim-error="true"
                :placeholder="'Mời nhập mã'"
                :value="formInput.templateCode"
                class="text-input"
                @input="handleInput('templateCode', $event)"
              />
            </div>
            <div class="line">
              <AppInputText
                :label="'Tiêu đề'"
                :required="true"
                :error="''"
                :slim-error="true"
                :placeholder="'Mời nhập tiêu đề'"
                :value="formInput.subject"
                class="text-input"
                @input="handleInput('subject', $event)"
              />
            </div>
            <div class="line">
              <div class="editor">
                <div class="label">
                  <span> Nội dung email </span
                  ><span class="required">Bắt buộc</span>
                </div>
                <AppInputBasicTextEditor
                  ref="editorRef"
                  :value="formInput.template"
                  @input="handleInput('template', $event)"
                />
              </div>
              <div class="placeholders">
                <div class="label">Trường thông tin</div>
                <AppSpinnerHalfCircle v-if="isFetchingPlaceholder" />
                <div class="placeholder-list">
                  <div
                    v-for="placeholder in placeholderList"
                    :key="placeholder.id"
                    draggable="true"
                    class="placeholder"
                    :title="placeholder.label"
                    @dragstart="onDragStart($event, placeholder)"
                  >
                    {{ placeholder.label }}
                  </div>
                </div>
              </div>
            </div>
          </template>
        </template>
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
          :text="'Xác nhận'"
          :is-disabled="isSubmitDisabled"
          :is-loading="isLoading"
          @click="handleSubmit"
        />
        <AppButton
          v-if="isUseBlankTemplate"
          class="submit-btn btn"
          :text="'Xác nhận và lưu mẫu email'"
          :is-disabled="isSubmitAndCreateDisabled"
          :is-loading="isLoading"
          @click="handleSubmitAndCreate"
        />
      </div>
    </template>
  </UModal>
</template>
<script setup lang="ts">
type TProps = {
  modelValue: boolean;
  rejectingTarget: Record<string, any> | null;
  candidateInfo: Record<string, any> | null;
};

const { getEliminateReason } = useEnumApi();
const {
  getMailTemplates,
  getMailTemplateDetail,
  getPlaceholders,
  createMailTemplateWithId,
} = useMailTemplateApi();
const { eliminateCandidate } = useCandidateApi();
const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);

const props = defineProps<TProps>();

const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "rejected"): void;
}>();

onBeforeMount(async () => {
  isFetchingPlaceholder.value = true;
  const res = await getPlaceholders();
  placeholderList.value = res.data.map((placeholder: any) => {
    const sanitizedCode = stripCurlyBraces(placeholder.code);
    const parsed = {
      ...placeholder,
      code: sanitizedCode,
    };
    return parsed;
  });
  isFetchingPlaceholder.value = false;
});

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const reasons = ref<Record<string, any>[]>([]);

const isPreviewModalOpen = ref<boolean>(false);
const editorRef = ref<any>(null);
const isLoading = ref<boolean>(false);
const placeholderList = ref<any[]>([]);
const isFetchingPlaceholder = ref<boolean>(false);
const isUseBlankTemplate = ref<boolean>(false);
const templateList = ref<Record<string, any>[]>([]);
const templateDetail = ref<Record<string, any> | undefined>(undefined);
const templateListOpts = computed(() => {
  return templateList.value.map((template) => ({
    label: template.name,
    value: template.id,
  }));
});

const formInput = ref<Record<string, any>>({
  reason: undefined,
  reasonDetail: "",
  sendEmail: false,
  emailTemplate: undefined,
  subject: "",
  template: "",
  templateName: "",
  templateCode: "",
});

const previewData = computed(() => {
  const data: Record<string, any> = {};

  data.positionName = props.rejectingTarget?.jobAd?.positionName;
  data.jobAdName = props.rejectingTarget?.jobAd.title;
  data.hrContactId = props.rejectingTarget?.jobAd?.hrContactId;
  data.hrContactName = props.rejectingTarget?.jobAd?.hrContactName;
  data.orgName = userInfo.value?.userDetails?.[0]?.detailInfo?.org?.name;
  data.candidateName = props.candidateInfo?.fullName;
  data.candidateInfoApplyId = props.candidateInfo?.id;

  console.log({ data });

  let placeholderCodes: string[] = [];
  if (isUseBlankTemplate.value) {
    const usedPlaceholders = (editorRef.value?.getUsedPlaceholders?.() ||
      []) as any[];
    const placeholderSet: Set<string> = new Set();
    for (const placeholder of usedPlaceholders) {
      placeholderSet.add(`\${${placeholder.code}}`);
    }
    placeholderCodes = [...placeholderSet];

    return {
      subject: formInput.value.subject,
      body: parseHtmlToMergeTags(formInput.value.template),
      dataReplacePlaceholder: data,
      placeholderCodes,
    };
  } else {
    placeholderCodes = templateDetail.value?.placeholders.map(
      (placeholder: any) => placeholder.code,
    );

    return {
      subject: templateDetail.value?.subject,
      body: templateDetail.value?.body,
      dataReplacePlaceholder: data,
      placeholderCodes,
    };
  }
});

const isPreviewable = computed(() => {
  return (
    (formInput.value.sendEmail && formInput.value.emailTemplate) ||
    (isUseBlankTemplate.value &&
      formInput.value.subject.trim() &&
      formInput.value.template.trim())
  );
});

const mappedBody = computed(() => {
  if (!templateDetail.value?.body) {
    return "Nội dung email";
  }

  return wrapTemplateVariables(
    templateDetail.value?.body,
    templateDetail.value?.placeholders ?? ([] as TTemplatePlaceholder[]),
  );
});

async function fetchReason(controller?: AbortController) {
  const res = await getEliminateReason(controller);
  if (!res) {
    return null;
  }

  reasons.value = res.data.map((reason: any) => ({
    label: reason.description,
    value: reason.name,
  }));
  return res.data;
}

async function fetchTemplate(params: any, controller?: AbortController) {
  const res = await getMailTemplates(params, controller);
  if (!res) {
    return null;
  }

  const nextPage = res.data.data;
  templateList.value = [...templateList.value, ...nextPage];

  return res.data.data;
}

function handleInput(key: string, value: any) {
  formInput.value[key] = value;
}

function onDragStart(e: DragEvent, placeholder: any) {
  e.dataTransfer?.setData("application/json", JSON.stringify(placeholder));
}

async function handlePreviewClick() {
  console.log("clicked");
  if (!isPreviewable.value) {
    return;
  }
  isPreviewModalOpen.value = true;
}

function handleCancel() {
  emits("update:modelValue", false);
}

const isSubmitDisabled = computed(() => {
  if (!formInput.value.reason) {
    return true;
  }

  if (
    formInput.value.sendEmail &&
    !isUseBlankTemplate.value &&
    !formInput.value.emailTemplate
  ) {
    return true;
  }

  if (
    formInput.value.sendEmail &&
    isUseBlankTemplate.value &&
    (!formInput.value.subject.trim() || !formInput.value.template.trim())
  ) {
    return true;
  }

  return false;
});

async function handleSubmit() {
  const payload: Record<string, any> = {
    jobAdCandidateId: props.rejectingTarget?.id,
    reason: formInput.value.reason.value,
    reasonDetail: formInput.value.reasonDetail,
    sendEmail: formInput.value.sendEmail,
  };

  if (formInput.value.sendEmail && !isUseBlankTemplate.value) {
    payload.emailTemplateId = formInput.value.emailTemplate.value;
  }

  if (isUseBlankTemplate.value) {
    payload.subject = formInput.value.subject;
    payload.template = parseHtmlToMergeTags(formInput.value.template);
    const usedPlaceholders = (editorRef.value?.getUsedPlaceholders?.() ||
      []) as any[];
    const placeholderSet = new Set();
    for (const placeholder of usedPlaceholders) {
      placeholderSet.add(`\${${placeholder.code}}`);
    }
    payload.placeholders = [...placeholderSet];
  }

  isLoading.value = true;
  const success = await eliminateCandidate(payload);
  isLoading.value = false;

  if (success) {
    emits("rejected");
  }
}

const isSubmitAndCreateDisabled = computed(() => {
  if (!formInput.value.reason) {
    return true;
  }

  if (
    formInput.value.sendEmail &&
    !isUseBlankTemplate.value &&
    !formInput.value.emailTemplate
  ) {
    return true;
  }

  if (
    formInput.value.sendEmail &&
    isUseBlankTemplate.value &&
    (!formInput.value.subject.trim() ||
      !formInput.value.template.trim() ||
      !formInput.value.templateName.trim() ||
      !formInput.value.templateCode.trim())
  ) {
    return true;
  }

  return false;
});

async function handleSubmitAndCreate() {
  const createTemplatePayload: Record<string, any> = {
    code: formInput.value.templateCode,
    name: formInput.value.templateName,
    subject: formInput.value.subject,
    body: parseHtmlToMergeTags(formInput.value.template),
  };

  const usedPlaceholders = (editorRef.value?.getUsedPlaceholders?.() ||
    []) as any[];
  const placeholderSet = new Set();
  for (const placeholder of usedPlaceholders) {
    placeholderSet.add(+placeholder.id);
  }
  createTemplatePayload.placeholderIds = [...placeholderSet];

  isLoading.value = true;
  const createRes = await createMailTemplateWithId(createTemplatePayload);
  if (createRes === false) {
    isLoading.value = false;
    return;
  }

  const payload: Record<string, any> = {
    jobAdCandidateId: props.rejectingTarget?.id,
    reason: formInput.value.reason.value,
    reasonDetail: formInput.value.reasonDetail,
    sendEmail: formInput.value.sendEmail,
    emailTemplateId: createRes.data.id,
  };

  const success = await eliminateCandidate(payload);
  isLoading.value = false;
  if (success) {
    emits("rejected");
  }
}

watch(
  () => props.modelValue,
  (newVal) => {
    if (!newVal) {
      // clear everything
      formInput.value = {
        reason: undefined,
        reasonDetail: "",
        sendEmail: false,
        emailTemplate: undefined,
        subject: "",
        template: "",
        templateName: "",
        templateCode: "",
      };
      isUseBlankTemplate.value = false;
      templateDetail.value = undefined;
    }
  },
);

watch(
  () => props.rejectingTarget,
  (newVal) => {
    console.log("rejecting ", newVal);
  },
);

watch(
  () => formInput.value.emailTemplate,
  async (newValue) => {
    if (newValue && newValue.value != undefined) {
      const res = await getMailTemplateDetail(newValue.value);
      console.log(res);
      templateDetail.value = res.data;
    }
  },
);
</script>
<style lang="scss" scoped>
.body {
  display: flex;
  flex-direction: column;
  gap: 8px;

  :deep(textarea) {
    max-height: 90px;
  }

  .required {
    font-size: 12px;
    font-style: italic;
    color: $color-danger;
    margin-left: 8px;
  }

  .preview-button {
    display: flex;
    flex-direction: row;
    gap: 8px;
    cursor: pointer;
    color: $text-light;
    font-size: 14px;

    &.no-preview {
      color: $color-gray-400;
      cursor: default;
    }

    .iconify {
      display: block;
      font-size: 20px;
      width: 20px;
    }
  }

  .checkbox {
    max-width: fit-content;
    :deep(label) {
      color: $text-light;
      font-weight: 400;
      cursor: pointer !important;
    }
    :deep(button) {
      cursor: pointer !important;
    }
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

  .editor {
    flex: 1;
    .label {
      font-size: 14px;
      color: $text-light;
      margin-bottom: 4px;
    }
  }

  .editor,
  .placeholders {
    display: flex;
    flex-direction: column;
    :deep(.iconify) {
      display: block;
      align-self: center;
    }
    .label {
      font-size: 14px;
      margin-bottom: 4px;
      color: $text-light;
    }
  }

  .ProseMirror {
    max-height: 35vh;
    overflow: auto;
  }

  .placeholders {
    flex: 1;
    max-width: fit-content;
    .placeholder-list {
      display: flex;
      flex-direction: column;
      gap: 4px;
      overflow-y: auto;
      max-height: 35vh;

      .placeholder {
        padding: 4px 6px;
        font-size: 13px;
        font-weight: 500;
        border-radius: 4px;
        border: 1px solid $color-gray-300;
        cursor: grabbing;
        max-width: 240px;
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
