<template>
  <div class="mail-info">
    <div class="title">Nội dung email</div>
    <div class="content">
      <div class="wrapper">
        <div class="header">
          <div class="label">Mẫu email</div>
          <AppInputSearchSelect
            :label="''"
            :required="false"
            :options="mailTemplateOption"
            :value="formInput.mailTemplate"
            :error="''"
            :placeholder="'Mời chọn mẫu email'"
            :remote-filter="true"
            :multiple="false"
            :allow-clear="true"
            :is-paginated="true"
            :slim-error="true"
            :fetch-fn="fetchMailTemplate"
            @input="handleInput('mailTemplate', $event)"
            @clear-value="handleClear"
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
              formInput.mailTemplate ? (isPreviewModalOpen = true) : () => {}
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
          <div class="mail-body">
            <div class="content" v-html="mappedBody"></div>
          </div>
        </div>
      </div>
    </div>
    <OrgAdJobCreateMailPreviewModal
      v-model="isPreviewModalOpen"
      :form-data="props.formData"
    />
  </div>
</template>
<script setup lang="ts">
const { getMailTemplates, getMailTemplateDetail } = useMailTemplateApi();
const { setLoading } = useLoadingStore();

export type TMailInfoForm = {
  mailTemplate: Record<string, any> | null;
};

type TProps = {
  data?: TMailInfoForm;
  formData: Record<string, any> | undefined;
};

const props = withDefaults(defineProps<TProps>(), {
  data: () => ({
    mailTemplate: null,
  }),
});
const emits = defineEmits<{
  (e: "dataChange", payload: TMailInfoForm): void;
}>();

const mailTemplateList = ref<Record<string, any>[]>([]);
const isPreviewModalOpen = ref<boolean>(false);
const formInput = ref<Record<string, any>>({});
const mailTemplateDetail = ref<Record<string, any> | null>(null);

onBeforeMount(() => {
  formInput.value = props.data;
});

function handleClear() {
  handleInput("mailTemplate", null);
}

async function fetchMailTemplate(params: any, controller?: AbortController) {
  const res = await getMailTemplates(params, controller);
  if (!res) {
    return null;
  }

  const nextPage = res.data.data.filter((mail: any) => mail.isActive);
  mailTemplateList.value = [...mailTemplateList.value, ...nextPage];

  return res.data.data;
}

const mappedBody = computed(() => {
  if (!selectedTemplate.value?.body) {
    return "Nội dung email";
  }

  return wrapTemplateVariables(
    selectedTemplate.value.body,
    mailTemplateDetail.value?.placeholders ?? ([] as TTemplatePlaceholder[]),
  );
});

const mailTemplateOption = computed(() => {
  return mailTemplateList.value.map((mail) => ({
    label: mail.name,
    value: mail.id,
  }));
});

const selectedTemplate = computed(() => {
  return mailTemplateList.value.find(
    (template) => template.id === formInput.value?.mailTemplate?.value,
  );
});

function handleInput(key: string, value: any) {
  console.log(key, value);
  formInput.value[key] = value;
}

watch(
  formInput,
  (newVal) => {
    emits("dataChange", newVal as TMailInfoForm);
  },
  { deep: true },
);

watch(
  () => formInput.value.mailTemplate,
  async (newVal) => {
    if (!newVal) {
      mailTemplateDetail.value = null;
      return;
    }
    setLoading(true);
    const res = await getMailTemplateDetail(newVal.value);
    mailTemplateDetail.value = res.data;
    setLoading(false);
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.mail-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 20px;

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

  .title {
    color: $color-primary-400;
    font-size: 16px;
    line-height: 20px;
    font-weight: 600;
  }

  .loading {
    height: 160px;
    display: flex;
    align-items: center;
    justify-content: center;

    .iconify {
      display: block;
    }
  }
}
</style>
