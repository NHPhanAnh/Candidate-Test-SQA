<template>
  <div class="edit-level">
    <div v-if="isLoading" class="loading-overlay">
      <AppSpinnerHalfCircle class="spinner" />
    </div>
    <form class="form-block">
      <div class="line">
        <AppInputText
          :label="'Tên'"
          :required="true"
          :error="formError.name"
          :placeholder="'Mời nhập tên'"
          :value="
            currentMode == 'view' ? levelDetail?.name || '' : formInput.name
          "
          :is-disabled="currentMode == 'view'"
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
          :value="
            currentMode == 'view' ? levelDetail?.code || '' : formInput.code
          "
          :is-disabled="currentMode == 'view'"
          class="text-input"
          @input="handleInput('code', $event)"
          @blur="validateKey('code')"
        />
      </div>
    </form>
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
            :is-disabled="!isFormValid"
            :text="'Lưu'"
            :is-loading="isSubmiting"
            class="submit-button"
            @click="handleSubmit"
          />
        </template>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
type TCreateForm = {
  code: string;
  name: string;
};
type TMode = "edit" | "view";
type TProps = {
  initialMode?: TMode;
  id: number;
  allowEdit?: boolean;
};

const props = withDefaults(defineProps<TProps>(), {
  initialMode: "view",
  allowEdit: false,
});

const currentMode = ref<TMode>("view");
const didUpdate = ref<boolean>(false);

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
const levelDetail = ref<any>(null);
const isLoading = ref<boolean>(false);

const { getLevelDetail, updateLevel } = useLevelApi();

const emit = defineEmits<{
  (e: "closeModal" | "submit"): void;
  (e: "modeSwitch", mode: TMode): void;
}>();

const populateData = async () => {
  isLoading.value = true;
  const detailRes = await getLevelDetail(props.id);
  levelDetail.value = detailRes.data;
  isLoading.value = false;
};

onBeforeMount(async () => {
  currentMode.value = props.initialMode;
  await populateData();
  if (props.initialMode == "edit") {
    formInput.value = {
      code: levelDetail.value.code,
      name: levelDetail.value.name,
    };
    formError.value = {
      code: "",
      name: "",
    };
  }
});

const handleCancelClick = (event: any) => {
  event.preventDefault();
  emit("closeModal");
};

const handleSwitchMode = (mode: TMode) => {
  currentMode.value = mode;
  emit("modeSwitch", mode);
  if (mode == "edit") {
    formInput.value = {
      code: levelDetail.value.code,
      name: levelDetail.value.name,
    };
    formError.value = {
      code: "",
      name: "",
    };
  } else {
    if (didUpdate.value) {
      populateData();
      didUpdate.value = false;
    }
    formInput.value = {
      code: "",
      name: "",
    };
    formError.value = {
      code: "",
      name: "",
    };
  }
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
  const res = await updateLevel(props.id, payload);
  if (res) {
    emit("submit");
  }
  isSubmiting.value = false;
  didUpdate.value = true;
  if (props.initialMode == "view") {
    currentMode.value = "view";
  } else {
    emit("closeModal");
  }
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
.edit-level {
  .loading-overlay {
    position: fixed;
    z-index: 999;
    background-color: rgba(black, 0.05);
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    top: 0px;
    left: 0px;

    .spinner {
      display: block;
      font-size: 32px;
    }
  }
  .form-block {
    .line {
      display: flex;
      flex-direction: row;
      gap: 8px;
      justify-content: space-between;
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
