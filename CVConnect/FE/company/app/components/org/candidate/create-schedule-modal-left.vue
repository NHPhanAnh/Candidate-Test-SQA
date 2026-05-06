<template>
  <OrgCandidatePreviewEmailModal
    v-model="isPreviewModalOpen"
    :data="previewData"
    :template-id="
      formInput.useBlankTemplate ? null : formInput.emailTemplate?.value
    "
  />
  <div class="left">
    <div class="content">
      <div class="row">
        <AppInputSearchSelect
          :label="'Tin tuyển dụng'"
          :required="true"
          :options="[]"
          :value="currentJobAd"
          :error="''"
          :is-disabled="true"
          :placeholder="''"
          :remote-filter="false"
          :multiple="false"
          :slim-error="true"
          :is-paginated="false"
          :fetch-fn="null"
        />
      </div>
      <div class="row">
        <AppInputSearchSelect
          :label="'Vòng hiện tại'"
          :required="true"
          :options="[]"
          :value="currentProcess"
          :error="''"
          :is-disabled="true"
          :placeholder="''"
          :remote-filter="false"
          :multiple="false"
          :slim-error="true"
          :is-paginated="false"
          :fetch-fn="null"
        />
      </div>
      <div class="row">
        <AppInputDatepicker
          :label="'Thời gian tiếp nhận'"
          :required="true"
          :value="formInput.startTime"
          :hide-navigations="['seconds']"
          :enable-time-picker="true"
          :error="''"
          :slim-error="true"
          :is-teleport="'html'"
          :placeholder="'Chọn ngày giờ'"
          :is-range="false"
          class="start-time-datepicker input-unit"
          @input="handleInput('startTime', $event)"
        />
        <div class="duration-input input-unit">
          <div class="label">
            <span>Thời lượng (phút)</span>
            <span class="required">Bắt buộc</span>
          </div>
          <UInputNumber
            v-model="formInput.duration"
            variant="none"
            :min="0"
            :max="120"
            :step="10"
            orientation="vertical"
            class="num-input"
          />
        </div>
      </div>
      <div class="row">
        <AppInputSearchSelect
          :label="'Loại lịch'"
          :required="true"
          :options="scheduleTypeOptions"
          :value="formInput.scheduleType"
          :error="''"
          :placeholder="'Mời chọn loại lịch'"
          :remote-filter="false"
          :multiple="false"
          :slim-error="true"
          :is-paginated="false"
          :fetch-fn="fetchScheduleType"
          @input="handleInput('scheduleType', $event)"
          @clear-value="handleInput('scheduleType', undefined)"
          @search-filter="
            () => {
              scheduleTypeList = [];
            }
          "
        />
      </div>
      <div v-if="currentScheduleType === 'OFFLINE'" class="row">
        <AppInputSearchSelect
          :label="'Địa điểm'"
          :required="true"
          :options="locationOptions"
          :value="formInput.location"
          :error="''"
          :placeholder="'Mời chọn địa điểm làm việc'"
          :remote-filter="false"
          :multiple="false"
          :slim-error="true"
          :is-paginated="false"
          :fetch-fn="fetchLocation"
          @input="handleInput('location', $event)"
          @clear-value="handleInput('location', undefined)"
          @search-filter="
            () => {
              locationList = [];
            }
          "
        />
      </div>
      <div v-if="currentScheduleType === 'ONLINE'" class="row">
        <AppInputText
          :label="'Link phòng họp'"
          :required="true"
          :slim-error="true"
          :error="''"
          :placeholder="'Mời nhập link tham gia phòng họp'"
          :value="formInput.meetingLink"
          class="text-input"
          @input="handleInput('meetingLink', $event)"
        />
      </div>
      <div class="row">
        <AppInputTextarea
          v-model="formInput.note"
          :label="'Ghi chú cho ứng viên'"
          :required="false"
          :placeholder="'Mời nhập ghi chú'"
          :is-disabled="false"
          :error="''"
          :slim-error="true"
          :show-error="false"
        />
      </div>
      <div class="row">
        <UCheckbox
          class="checkbox"
          :model-value="formInput.sendEmail"
          :label="'Gửi email thông báo cho ứng viên'"
          @update:model-value="
            ($event) => (formInput.sendEmail = $event as boolean)
          "
        />
      </div>
      <div v-if="formInput.sendEmail" class="row">
        <UCheckbox
          class="checkbox"
          :model-value="formInput.useBlankTemplate"
          :label="'Sử dụng mẫu email trống'"
          @update:model-value="
            ($event) => (formInput.useBlankTemplate = $event as boolean)
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
      <div
        v-if="formInput.sendEmail && !formInput.useBlankTemplate"
        class="row"
      >
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
      </div>
      <template v-if="formInput.emailTemplate && !formInput.useBlankTemplate">
        <div class="row">
          <AppInputText
            :label="'Tiêu đề'"
            :required="false"
            :error="''"
            :placeholder="'Mời nhập tiêu đề'"
            :is-disabled="true"
            :slim-error="true"
            :value="templateDetail?.subject || 'Tiêu đề'"
          />
        </div>
        <div class="row">
          <div class="editor">
            <div class="label">Nội dung email</div>
            <div class="template-body" v-html="mappedBody"></div>
          </div>
        </div>
      </template>
      <template v-if="formInput.sendEmail && formInput.useBlankTemplate">
        <div class="row">
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
        <div class="row">
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
        <div class="row">
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
    </div>
  </div>
</template>
<script setup lang="ts">
const defaultFormInput = {
  startTime: undefined,
  duration: undefined,
  location: undefined,
  scheduleType: undefined,
  meetingLink: undefined,
  note: undefined,
  sendEmail: false,
  emailTemplate: undefined,
  subject: undefined,
  template: undefined,
  useBlankTemplate: false,
  placeholders: [],
  templateName: undefined,
  templateCode: undefined,
};

const { getAllLocations } = useLocationApi();
const { getScheduleType } = useEnumApi();
const {
  getMailTemplates,
  getMailTemplateDetail,
  getPlaceholders,
  createMailTemplateWithId,
} = useMailTemplateApi();
const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);

type TProps = {
  jobAdInfo: any;
  candidateInfo: any;
};

const props = defineProps<TProps>();

const emits = defineEmits<{
  (e: "formInput", value: any): void;
}>();

const editorRef = ref<any>(null);
const formInput = ref<any>(defaultFormInput);
const locationList = ref<Record<string, any>[]>([]);
const scheduleTypeList = ref<any>([]);
const templateList = ref<Record<string, any>[]>([]);
const templateDetail = ref<Record<string, any> | undefined>(undefined);
const isPreviewModalOpen = ref<boolean>(false);
const isFetchingPlaceholder = ref<boolean>(false);
const placeholderList = ref<any[]>([]);

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

const currentJobAd = computed(() => {
  return {
    label: props.jobAdInfo.jobAd.title,
    value: 0,
  };
});

const currentProcess = computed(() => {
  const processName = props.jobAdInfo.jobAdProcessCandidates.find(
    (process: any) => process.isCurrentProcess,
  )?.processName;

  return {
    label: processName,
    value: 0,
  };
});

const locationOptions = computed(() => {
  return locationList.value.map((location) => ({
    label: location.displayAddress,
    value: location.id,
  }));
});

const scheduleTypeOptions = computed(() => {
  return scheduleTypeList.value.map((scheduleType: any) => ({
    label: scheduleType.displayName,
    value: scheduleType.name,
  }));
});

const currentScheduleType = computed(() => {
  const scheduleType = scheduleTypeList.value.find(
    (_s: any) => _s.name == formInput.value.scheduleType?.value,
  );
  return scheduleType?.type;
});

const templateListOpts = computed(() => {
  return templateList.value.map((template) => ({
    label: template.name,
    value: template.id,
  }));
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

const isPreviewable = computed(() => {
  return (
    formInput.value.emailTemplate ||
    (formInput.value.useBlankTemplate &&
      formInput.value.subject?.trim() &&
      formInput.value.template?.trim())
  );
});

const previewData = computed(() => {
  const data: Record<string, any> = {};

  data.positionName = props.jobAdInfo?.jobAd?.positionName;
  data.hrContactId = props.jobAdInfo?.jobAd?.hrContactId;
  data.hrContactName = props.jobAdInfo?.jobAd?.hrContactName;

  data.jobAdName = props.jobAdInfo?.jobAd.title;
  data.orgName = userInfo.value?.userDetails?.[0]?.detailInfo?.org?.name;
  data.candidateName = props.candidateInfo?.fullName;
  data.candidateInfoApplyId = props.candidateInfo?.id;
  data.examStartTime = toUtcDateWithTime(formInput.value.startTime);
  data.jobAdProcessName = props.jobAdInfo.jobAdProcessCandidates.find(
    (process: any) => process.isCurrentProcess,
  ).processName;
  data.interviewLink = formInput.value.meetingLink;
  data.locationName = formInput.value.location?.label;
  data.examDuration = formInput.value.duration;

  console.log("props job ad info", props.jobAdInfo.jobAdProcessCandidates);

  console.log({ data });

  let placeholderCodes: string[] = [];
  if (formInput.value.useBlankTemplate) {
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

function getUsedPlaceholdersCode() {
  let placeholderCodes: string[] = [];
  const usedPlaceholders = (editorRef.value?.getUsedPlaceholders?.() ||
    []) as any[];
  const placeholderSet: Set<string> = new Set();
  for (const placeholder of usedPlaceholders) {
    placeholderSet.add(`\${${placeholder.code}}`);
  }
  placeholderCodes = [...placeholderSet];

  return placeholderCodes;
}
function getUsedPlaceholdersId() {
  let placeholderCodes: number[] = [];
  const usedPlaceholders = (editorRef.value?.getUsedPlaceholders?.() ||
    []) as any[];
  const placeholderSet: Set<number> = new Set();
  for (const placeholder of usedPlaceholders) {
    placeholderSet.add(+placeholder.id);
  }
  placeholderCodes = [...placeholderSet];

  return placeholderCodes;
}
defineExpose({ getUsedPlaceholdersCode, getUsedPlaceholdersId, currentScheduleType });

function handleInput(key: string, value: any) {
  formInput.value[key] = value;
}

async function fetchLocation(params: any, controller?: AbortController) {
  const res = await getAllLocations();
  if (!res) {
    return null;
  }
  locationList.value = res.data;
  return res.data;
}

async function fetchScheduleType(params: any, controller?: AbortController) {
  const res = await getScheduleType();
  if (!res) {
    return null;
  }
  scheduleTypeList.value = res.data;
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

async function handlePreviewClick() {
  console.log("clicked");
  if (!isPreviewable.value) {
    return;
  }
  isPreviewModalOpen.value = true;
}

function onDragStart(e: DragEvent, placeholder: any) {
  e.dataTransfer?.setData("application/json", JSON.stringify(placeholder));
}

watch(
  () => formInput.value.emailTemplate,
  async (newValue) => {
    if (newValue && newValue.value != undefined) {
      const res = await getMailTemplateDetail(newValue.value);
      templateDetail.value = res.data;
    }
  },
);

watch(
  () => formInput.value,
  (newVal) => {
    emits("formInput", newVal);
  },
  { immediate: true, deep: true },
);
</script>
<style lang="scss" scoped>
.left {
  max-height: 100%;
  display: flex;
  flex-direction: column;
  width: 60%;
  gap: 8px;

  .header {
    font-size: 16px;
    font-weight: 500;
  }

  .content {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 8px;
    overflow: auto;
    min-height: 0;

    .row {
      display: flex;
      flex-direction: row;
      justify-content: space-between;
      gap: 8px;
      flex-wrap: wrap;
    }

    .duration-input {
      display: flex;
      flex-direction: column;
      gap: 4px;

      .label {
        font-size: 14px;
        color: $text-light;
      }
    }

    .num-input {
      :deep(input) {
        border: 1px solid rgba($color-primary-800, 0.1);
        border-radius: 12px;

        &:hover,
        &:focus {
          border: 1px solid rgba($color-primary-400, 1);
        }
      }
      :deep(button) {
        cursor: pointer;
      }
    }

    :deep(.text-input) {
      flex: 1;
      .input {
        padding: 6px 8px;
        input {
          font-size: 14px;
        }
      }
    }

    .required {
      font-size: 12px;
      font-style: italic;
      color: $color-danger;
      margin-left: 8px;
    }

    .input-unit {
      flex: 1;
    }

    :deep(.search-select-input) {
      max-width: 100%;
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
  }
}
</style>
