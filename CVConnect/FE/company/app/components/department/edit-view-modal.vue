<template>
  <div class="edit-view-modal">
    <UModal v-model:open="isOpen" :ui="{ content: 'w-[600px] max-w-[600px]' }">
      <template #header>
        <div class="flex items-center justify-between w-full">
          <div class="flex items-center gap-2">
            <span class="text-highlighted font-semibold">
              {{ departmentDetail ? departmentDetail.name : title }}
            </span>
            <AppChip
              v-if="departmentDetail"
              :type="departmentDetail.isActive ? 'success' : 'error'"
              :text="
                departmentDetail.isActive ? 'Đang hoạt động' : 'Ngừng hoạt động'
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
        <div class="edit-view-department">
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
                :value="formInput.name"
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
                :value="formInput.code"
                :is-disabled="currentMode == 'view'"
                class="text-input"
                @input="handleInput('code', $event)"
                @blur="validateKey('code')"
              />
            </div>
          </form>
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
                v-if="departmentDetail && departmentDetail.isActive"
                :text="'Ngừng hoạt động'"
                :is-loading="isChangingStatus"
                class="active-btn deactive"
                @click="handleChangeStatus(false)"
              />
              <AppButton
                v-if="departmentDetail && !departmentDetail.isActive"
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
import type { TSubIndustry } from "~/types/subIndustry";
import { cloneDeep } from "lodash";

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
  description?: string;
  sub?: TSubIndustry[];
};

const currentMode = ref<string>("view");
const departmentDetail = ref<any>(null);
const departmentDetailSnapshot = ref<any>(null);
const isLoading = ref<boolean>(false);
const formInput = ref<TCreateForm>({
  code: "",
  name: "",
  description: "",
  sub: [],
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

const { getDepartmentDetail, updateDepartment, changeDepartmentStatus } =
  useDepartmentApi();

const isSubmiting = ref<boolean>(false);
const isChangingStatus = ref<boolean>(false);

// computed getter/setter to bind v-model
const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const title = computed(() => {
  if (currentMode.value == "view") {
    return "Thông tin phòng ban";
  }

  if (currentMode.value == "edit") {
    return "Cập nhật thông tin phòng ban";
  }

  return "";
});

const isFormValid = computed(() => {
  for (const key of Object.keys(
    formError.value,
  ) as (keyof typeof formError.value)[]) {
    if (formError.value[key]) {
      return false;
    }
  }

  if (formInput.value.sub) {
    for (const sub of formInput.value.sub) {
      if (!sub.code || !sub.name) {
        return false;
      }
    }
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

const handleCancelClick = (event: any) => {
  event.preventDefault();
  emits("update:modelValue", false);
};

const handleChangeStatus = async (status: boolean) => {
  const payload = {
    ids: [departmentDetail.value.id],
    active: status,
  };
  isChangingStatus.value = true;
  const res = await changeDepartmentStatus(payload);
  if (res) {
    departmentDetail.value.isActive = status;
  }
  isChangingStatus.value = false;
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

  isSubmiting.value = true;
  const res = await updateDepartment(departmentDetail.value.id, payload);
  if (res) {
    if (props.initialMode == "edit") {
      emits("submit");
    } else {
      currentMode.value = "view";
      await fetchDetail(departmentDetail.value.id);
    }
  }
  isSubmiting.value = false;
  isSubmiting.value = false;
};

const fetchDetail = async (id: number) => {
  isLoading.value = true;
  const res = await getDepartmentDetail(id);
  departmentDetail.value = res.data;
  formInput.value = {
    name: res.data.name,
    code: res.data.code,
  };
  departmentDetailSnapshot.value = cloneDeep(formInput.value);
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
    if (departmentDetailSnapshot.value) {
      formInput.value = departmentDetailSnapshot.value;
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
      departmentDetailSnapshot.value = null;
      departmentDetail.value = null;
      formInput.value = {
        code: "",
        name: "",
      };
      formError.value = {
        code: "",
        name: "",
      };
      return;
    }
    await fetchDetail(newVal);
  },
  {
    immediate: true,
  },
);
</script>
<style lang="scss" scoped>
.edit-view-department {
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
