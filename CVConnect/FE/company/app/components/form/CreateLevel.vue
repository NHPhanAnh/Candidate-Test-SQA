<template>
  <div class="create-level">
    <form class="form-block">
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
      </div>
      <div class="line">
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
    </form>
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
  </div>
</template>
<script setup lang="ts">
type TCreateForm = {
  code: string;
  name: string;
};
const formInput = ref<TCreateForm>({
  code: "",
  name: "",
});
const formError = ref<TCreateForm>({
  code: "",
  name: "",
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
};

const isSubmiting = ref<boolean>(false);

const emit = defineEmits<{
  (e: "closeModal" | "submit"): void;
}>();

const { createLevel } = useLevelApi();

const handleCancelClick = (event: any) => {
  event.preventDefault();
  emit("closeModal");
};

const handleSubmit = async () => {
  validateForm();
  if (!isFormValid.value) {
    return;
  }

  const payload = {
    code: formInput.value.code,
    name: formInput.value.name,
  };
  console.log(payload);

  isSubmiting.value = true;
  const res = await createLevel(payload);
  if (res) {
    emit("submit");
  }
  isSubmiting.value = false;
};

const handleInput = (key: string, value: string) => {
  formInput.value[key as keyof typeof formInput.value] = value;
  formError.value[key as keyof typeof formError.value] = "";
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
</script>
<style lang="scss" scoped>
.create-level {
  @include custom-scrollbar;
  max-height: 100%;
  .form-block {
    display: flex;
    flex-direction: column;
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
  }

  .footer {
    width: 100%;
    :deep(.buttons) {
      margin-top: 24px;
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
}
</style>
