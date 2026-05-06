<template>
  <div class="create-modal">
    <UModal
      v-model:open="isOpen"
      title="Thêm mới mẫu email"
      :ui="{ content: 'w-[80vw] max-w-[80vw]' }"
    >
      <template #body>
        <div class="create-template">
          <div class="form-block">
            <div class="line">
              <AppInputText
                :label="'Tên'"
                :required="true"
                :error="formError.name"
                :placeholder="'Mời nhập tên'"
                :value="formInput.name"
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
                class="text-input"
                @input="handleInput('subject', $event)"
                @blur="validateKey('subject')"
              />
            </div>
            <div class="line">
              <div class="editor">
                <div class="label">Nội dung email</div>
                <AppInputBasicTextEditor
                  ref="editorRef"
                  :value="formInput.body"
                  @input="handleInput('body', $event)"
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
          </div>
        </div>
      </template>
      <template #footer>
        <div class="footer">
          <div class="buttons">
            <AppButton
              :text="'Hủy bỏ'"
              class="cancel-button"
              @click.prevent="handleCancelClick($event)"
            />
            <AppButton
              :is-disabled="!isFormValid"
              :text="'Tạo mới'"
              :is-loading="isSubmiting"
              class="submit-button"
              @click="handleSubmit"
            />
          </div>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import type { TPlaceholderItem } from "~/types/mailTemplate";

type TProps = {
  modelValue: boolean;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

type TCreateForm = {
  code: string;
  name: string;
  subject: string;
  body: string;
};

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

const { getPlaceholders, createMailTemplate } = useMailTemplateApi();

const isSubmiting = ref<boolean>(false);
const placeholderList = ref<TPlaceholderItem[]>([]);
const editorRef = ref<any>(null);
const isFetchingPlaceholder = ref<boolean>(false);

// computed getter/setter to bind v-model
const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
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

const handleCancelClick = (event: any) => {
  event.preventDefault();
  emits("update:modelValue", false);
};

const handleSubmit = async () => {
  validateForm();
  if (!isFormValid.value) {
    return;
  }

  console.log(formInput.value);
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
  console.log(formInput.value.body);

  isSubmiting.value = true;
  const res = await createMailTemplate(payload);
  if (res) {
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
    emits("submit");
  }
  isSubmiting.value = false;
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

function onDragStart(e: DragEvent, placeholder: any) {
  e.dataTransfer?.setData("application/json", JSON.stringify(placeholder));
}

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
.create-template {
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
  }
}
</style>
