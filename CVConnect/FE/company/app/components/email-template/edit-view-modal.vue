<template>
  <div class="edit-view-modal">
    <UModal v-model:open="isOpen" :ui="{ content: 'w-[80vw] max-w-[80vw]' }">
      <template #header>
        <div class="flex items-center justify-between w-full">
          <div class="flex items-center gap-2">
            <span class="text-highlighted font-semibold">
              {{ templateDetail ? templateDetail.name : title }}
            </span>
            <AppChip
              v-if="templateDetail"
              :type="templateDetail.isActive ? 'success' : 'error'"
              :text="
                templateDetail.isActive ? 'Đang hoạt động' : 'Ngừng hoạt động'
              "
            />
          </div>
          <UButton
            icon="i-heroicons-x-mark"
            variant="ghost"
            class="rounded-md font-medium inline-flex items-center disabled:cursor-not-allowed aria-disabled:cursor-not-allowed disabled:opacity-75 aria-disabled:opacity-75 transition-colors text-sm gap-1.5 text-default hover:bg-elevated active:bg-elevated focus:outline-none focus-visible:bg-elevated hover:disabled:bg-transparent dark:hover:disabled:bg-transparent hover:aria-disabled:bg-transparent dark:hover:aria-disabled:bg-transparent p-1.5 absolute top-4 end-4"
            @click="isOpen = false"
          />
        </div>
      </template>
      <template #body>
        <div class="edit-view-template">
          <div v-if="isLoading" class="loading-overlay">
            <AppSpinnerHalfCircle class="spinner" />
          </div>
          <div class="form-block">
            <div class="line">
              <AppInputText
                :label="'Tên'"
                :required="true"
                :error="formError.name"
                :placeholder="'Mời nhập tên'"
                :value="formInput.name"
                :is-disabled="currentMode == 'view'"
                class="text-input"
                @input="handleInput('name', $event)"
                @blur="validateKey('name')"
              />
              <AppInputText
                :label="'Mã'"
                :required="true"
                :error="formError.code"
                :placeholder="'Mời nhập mã'"
                :value="formInput.code"
                :is-disabled="currentMode == 'view'"
                class="text-input"
                @input="handleInput('code', $event)"
                @blur="validateKey('code')"
              />
            </div>
            <div class="line">
              <AppInputText
                :label="'Tiêu đề'"
                :required="true"
                :error="formError.subject"
                :placeholder="'Mời nhập tiêu đề'"
                :value="formInput.subject"
                :is-disabled="currentMode == 'view'"
                class="text-input"
                @input="handleInput('subject', $event)"
                @blur="validateKey('subject')"
              />
            </div>
            <div class="line">
              <div class="editor">
                <div class="label">Nội dung email</div>
                <div v-if="currentMode == 'view'" class="mail-body">
                  <div class="content" v-html="mappedBody"></div>
                </div>
                <AppInputBasicTextEditor
                  v-if="currentMode == 'edit' && formInput.body"
                  ref="editorRef"
                  :value="formInput.body"
                  @input="handleInput('body', $event)"
                />
              </div>
              <div v-if="currentMode == 'edit'" class="placeholders">
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
          </div>
        </div>
      </template>
      <template #footer>
        <div class="footer">
          <div class="buttons">
            <template v-if="currentMode == 'view'">
              <AppButton
                :text="'Đóng'"
                class="cancel-button"
                @click.prevent="handleCancelClick($event)"
              />
              <AppButton
                v-if="props.allowEdit"
                :text="'Chỉnh sửa'"
                class="submit-button"
                @click="handleSwitchMode('edit')"
              />
            </template>
            <template v-else>
              <AppButton
                :text="'Hủy bỏ'"
                class="cancel-button"
                @click.prevent="
                  props.initialMode == 'view'
                    ? handleSwitchMode('view')
                    : handleCancelClick($event)
                "
              />
              <AppButton
                v-if="templateDetail && templateDetail.isActive"
                :text="'Ngừng hoạt động'"
                :is-loading="isChangingStatus"
                class="active-btn deactive"
                @click="handleChangeStatus(false)"
              />
              <AppButton
                v-if="templateDetail && !templateDetail.isActive"
                :text="'Hoạt động'"
                :is-loading="isChangingStatus"
                class="active-btn active"
                @click="handleChangeStatus(true)"
              />
              <AppButton
                :is-disabled="!isFormValid"
                :text="'Lưu'"
                :is-loading="isSubmiting"
                class="submit-button"
                @click="handleSubmit"
              />
            </template>
          </div>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { cloneDeep } from "lodash";
import type { TPlaceholderItem } from "~/types/mailTemplate";

type TProps = {
  modelValue: boolean;
  initialMode?: string;
  allowEdit?: boolean;
  targetId: number;
};

const props = withDefaults(defineProps<TProps>(), {
  initialMode: "view",
  allowEdit: false,
});
const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "modeChange", value: string): void;
  (e: "submit"): void;
}>();

type TCreateForm = {
  code: string;
  name: string;
  subject: string;
  body: string;
};

const currentMode = ref<string>("view");
const templateDetail = ref<any>({});
const templateDetailSnapshot = ref<any>({});
const isLoading = ref<boolean>(false);
const isFetchingPlaceholder = ref<boolean>(false);
const placeholderList = ref<TPlaceholderItem[]>([]);
const editorRef = ref<any>(null);
const formInput = ref<TCreateForm>({
  code: "",
  name: "",
  subject: "",
  body: "",
});
const formError = ref<Record<string, any>>({
  code: "",
  name: "",
  subject: "",
});

const formRules = {
  code: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.code = "Mời nhập mã";
        return false;
      }
      return true;
    },
  ],
  name: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.name = "Mời nhập tên";
        return false;
      }
      return true;
    },
  ],
  subject: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.subject = "Mời nhập tiêu đề";
        return false;
      }
      return true;
    },
  ],
};

const { getMailTemplateDetail, changeMailTemplateStatus, getPlaceholders, updateMailTemplate } =
  useMailTemplateApi();

const isSubmiting = ref<boolean>(false);
const isChangingStatus = ref<boolean>(false);

// computed getter/setter to bind v-model
const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const title = computed(() => {
  if (currentMode.value == "view") {
    return "Thông tin mẫu email";
  }

  if (currentMode.value == "edit") {
    return "Cập nhật thông tin mẫu email";
  }

  return "";
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

const isFormValid = computed(() => {
  for (const key of Object.keys(
    formError.value,
  ) as (keyof typeof formError.value)[]) {
    if (formError.value[key]) {
      return false;
    }
  }

  if (!formInput.value.body) {
    return false;
  }

  return true;
});

const handleInput = <K extends keyof TCreateForm>(
  key: K,
  value: TCreateForm[K],
) => {
  formInput.value[key] = value;
  formError.value[key] = "" as TCreateForm[K];
};

const handleSwitchMode = (mode: string) => {
  currentMode.value = mode;
};

function onDragStart(e: DragEvent, placeholder: any) {
  e.dataTransfer?.setData("application/json", JSON.stringify(placeholder));
}

const handleCancelClick = (event: any) => {
  event.preventDefault();
  emits("update:modelValue", false);
};

const handleChangeStatus = async (status: boolean) => {
  const payload = {
    ids: [templateDetail.value.id],
    active: status,
  };
  isChangingStatus.value = true;
  const res = await changeMailTemplateStatus(payload);
  if (res) {
    templateDetail.value.isActive = status;
  }
  isChangingStatus.value = false;
};

const handleSubmit = async () => {
  validateForm();
  if (!isFormValid.value) {
    return;
  }

  const payload: Record<string, any> = {
    code: formInput.value.code,
    name: formInput.value.name,
    subject: formInput.value.subject,
    body: parseHtmlToMergeTags(formInput.value.body),
  };

  const usedPlaceholders = (editorRef.value?.getUsedPlaceholders?.() ||
    []) as TPlaceholderItem[];
  const placeholderSet = new Set();
  for (const placeholder of usedPlaceholders) {
    placeholderSet.add(+placeholder.id);
  }
  payload.placeholderIds = [...placeholderSet];
  console.log(payload);

  isSubmiting.value = true;
  const res = await updateMailTemplate(templateDetail.value.id, payload);
  if (res) {
    if (props.initialMode == "edit") {
      emits("submit");
    } else {
      currentMode.value = "view";
      await fetchDetail(templateDetail.value.id);
    }
  }
  isSubmiting.value = false;
  isSubmiting.value = false;
};

const fetchDetail = async (id: number) => {
  isLoading.value = true;
  const res = await getMailTemplateDetail(id);
  templateDetail.value = res.data;
  const strippedPlaceholders = res.data.placeholders.map(
    (placeholder: TPlaceholderItem) => {
      const sanitizedCode = stripCurlyBraces(placeholder.code);
      const parsed = {
        ...placeholder,
        code: sanitizedCode,
      };
      return parsed;
    },
  );
  const sanitizedBody = res.data.body.replace(/\n/g, "");
  formInput.value = {
    name: res.data.name,
    code: res.data.code,
    subject: res.data.subject,
    body: parseMergeTagsToHtml(sanitizedBody, strippedPlaceholders),
  };
  console.log(formInput.value);
  templateDetailSnapshot.value = cloneDeep(formInput.value);
  isLoading.value = false;
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
  if (rules) {
    for (const rule of rules) {
      const ok = rule(input as string);
      if (!ok) {
        break;
      }
    }
  }
};

watch(
  () => props.initialMode,
  (newVal) => {
    currentMode.value = newVal;
  },
  {
    immediate: true,
  },
);

watch(currentMode, (newVal) => {
  emits("modeChange", newVal);
  if (newVal == "view") {
    if (templateDetailSnapshot.value) {
      formInput.value = templateDetailSnapshot.value;
      formError.value = {
        code: "",
        name: "",
      };
    }
  }
});

watch(
  () => props.targetId,
  async (newVal) => {
    if (newVal == -1) {
      templateDetailSnapshot.value = null;
      templateDetail.value = null;
      formInput.value = {
        code: "",
        name: "",
        subject: "",
        body: "",
      };
      formError.value = {
        code: "",
        name: "",
        subject: "",
      };
      return;
    }
    await fetchDetail(newVal);
  },
  {
    immediate: true,
  },
);

watch(isOpen, async (val) => {
  if (val && !placeholderList.value.length) {
    isFetchingPlaceholder.value = true;
    const res = await getPlaceholders();
    placeholderList.value = res.data.map((placeholder: TPlaceholderItem) => {
      const sanitizedCode = stripCurlyBraces(placeholder.code);
      const parsed = {
        ...placeholder,
        code: sanitizedCode,
      };
      return parsed;
    });
    isFetchingPlaceholder.value = false;
  }
});
</script>
<style lang="scss" scoped>
.edit-view-template {
  position: relative;
  .loading-overlay {
    position: absolute;
    color: $color-primary-400;
    font-size: 20px;
    top: 0px;
    left: 0px;
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1;
  }
  @include custom-scrollbar;
  max-height: 100%;
  .form-block {
    display: flex;
    flex-direction: column;
    gap: 4px;
    .line {
      display: flex;
      flex-direction: row;
      gap: 8px;
      justify-content: space-between;
      flex: 1;
    }
    .text-input {
      width: 100%;
      :deep(.input) {
        padding: 6px 8px;
        input {
          font-size: 13px;
        }
      }
    }
    .text-area {
      width: 100%;

      :deep(textarea) {
        font-size: 13px;
      }
    }
    .sub-list {
      display: flex;
      flex-direction: column;
      gap: 4px;
      width: 100%;

      .label {
        font-size: 14px;
        color: $text-light;
      }

      .add-button {
        border: 1px dashed $color-danger;
        border-radius: 10px;
        padding: 8px;
        text-align: center;
        background-color: rgba($color-danger, 0.05);
        color: $color-danger;
        font-size: 13px;
        cursor: pointer;
        margin-top: 4px;
      }
    }
  }

  .editor {
    flex: 1;

    .mail-body {
      padding: 8px;
      border-radius: 6px;
      border: 1px solid $color-gray-300;
      font-size: 14px;
      min-height: 120px;

      :deep(.content) {
        .chip {
          border: 1px solid $color-gray-300;
          background-color: #ffffff;
          padding: 1px 3px;
          border-radius: 4px;
          font-size: 13px;

          // display: inline-flex;
          // align-items: center;
          // gap: 4px;
          // background-color: #ffffff;
          // border: 1px solid $color-gray-300;
          // border-radius: 9999px;
          // padding: 2px 6px;
        }
      }
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

  .placeholders {
    width: 240px;
    .placeholder-list {
      @include custom-scrollbar;
      display: flex;
      flex-direction: column;
      gap: 4px;
      overflow-y: auto;
      max-height: 40vh;

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
}

.footer {
  width: 100%;
  height: fit-content;
  :deep(.buttons) {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: flex-end;
    gap: 8px;

    .cancel-button,
    .submit-button {
      padding: 4px 14px 4px 14px;

      :deep(.button-text) {
        font-size: 14px;
      }
    }

    .submit-button {
      background-color: $color-primary-400;
      color: $text-dark;

      &.disabled {
        background-color: $color-gray-400;
      }
    }
    .cancel-button {
      padding: 3px 14px 3px 14px;
      background-color: white;
      color: $color-primary-400;
      border: 1px solid $color-primary-400;
    }

    .active-btn {
      background-color: white;
      padding: 3px 14px 3px 14px;

      :deep(.button-text) {
        font-size: 14px;
      }

      &.disabled {
        border: 1px solid $color-gray-400;
        color: $color-gray-400;
      }
    }

    .active {
      color: $color-success;
      border: 1px solid $color-success;
    }

    .deactive {
      color: $color-primary-400;
      border: 1px solid $color-primary-400;
    }
  }
}
</style>
