<template>
  <div class="edit-view-modal">
    <UModal
      v-model:open="isOpen"
      :title="title"
      :ui="{ content: 'w-[840px] max-w-[840px]' }"
    >
      <template #body>
        <div class="edit-view-industry">
          <div v-if="isLoading" class="loading-overlay">
            <AppSpinnerHalfCircle class="spinner" />
          </div>
          <form v-if="careerDetail" class="form-block">
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
            <!-- <div class="line"> -->
            <!--   <div class="text-area"> -->
            <!--     <AppInputTextarea -->
            <!--       v-model="formInput.description" -->
            <!--       :label="'Mô tả'" -->
            <!--       :required="false" -->
            <!--       :placeholder="'Mời nhập mô tả'" -->
            <!--       :is-disabled="currentMode == 'view'" -->
            <!--       :error="''" -->
            <!--       :show-error="false" -->
            <!--     /> -->
            <!--   </div> -->
            <!-- </div> -->
            <!-- <div class="line"> -->
            <!--   <div class="sub-list"> -->
            <!--     <div class="label">Phân ngành</div> -->
            <!--     <AppNoData -->
            <!--       v-if="currentMode == 'view' && !formInput.sub?.length" -->
            <!--     ></AppNoData> -->
            <!--     <IndustrySubIndustry -->
            <!--       v-for="(item, index) of formInput.sub" -->
            <!--       :key="index" -->
            <!--       :data="item" -->
            <!--       :is-disabled="currentMode == 'view'" -->
            <!--       @input="handleSubInput(index, $event)" -->
            <!--       @delete="handleSubDelete(index)" -->
            <!--     /> -->
            <!--     <div -->
            <!--       v-if="currentMode == 'edit'" -->
            <!--       class="add-button" -->
            <!--       @click="handleAddSub" -->
            <!--     > -->
            <!--       Thêm mới -->
            <!--     </div> -->
            <!--   </div> -->
            <!-- </div> -->
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
  // description?: string;
  // sub?: TSubIndustry[];
};

const currentMode = ref<string>("view");
const careerDetail = ref<any>(null);
const careerDetailSnapshot = ref<any>(null);
const isLoading = ref<boolean>(false);
const formInput = ref<TCreateForm>({
  code: "",
  name: "",
  // description: "",
  // sub: [],
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

const { updateIndustry, getIndustryDetail } = useIndustryApi();
const { updateCareer, getCareerDetail } = useCareerApi();

const isSubmiting = ref<boolean>(false);

// computed getter/setter to bind v-model
const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const title = computed(() => {
  return currentMode.value == "view"
    ? "Thông tin ngành nghề"
    : "Cập nhật thông tin ngành nghề";
});

const isFormValid = computed(() => {
  for (const key of Object.keys(
    formError.value,
  ) as (keyof typeof formError.value)[]) {
    if (formError.value[key]) {
      return false;
    }
  }

  // if (formInput.value.sub) {
  //   for (const sub of formInput.value.sub) {
  //     if (!sub.code || !sub.name) {
  //       return false;
  //     }
  //   }
  // }

  return true;
});

const fetchDetail = async (id: number) => {
  isLoading.value = true;
  const res = await getCareerDetail(id);
  careerDetail.value = res.data;
  formInput.value = {
    name: res.data.name,
    code: res.data.code,
    // sub: res.data.industrySubs?.map((sub: any) => {
    //   const mapped = {
    //     id: sub.id,
    //     name: sub.name,
    //     code: sub.code,
    //     isEdit: false,
    //   };
    //
    //   return mapped;
    // }),
  };
  careerDetailSnapshot.value = cloneDeep(formInput.value);
  isLoading.value = false;
};

const handleSwitchMode = (mode: string) => {
  currentMode.value = mode;
};

// const handleAddSub = () => {
//   formInput.value.sub!.push({
//     name: "",
//     code: "",
//     isEdit: true,
//   });
// };

const handleInput = <K extends keyof TCreateForm>(
  key: K,
  value: TCreateForm[K],
) => {
  formInput.value[key] = value;
  formError.value[key] = "" as TCreateForm[K];
};

// const handleSubInput = (index: number, value: TSubIndustry) => {
//   if (!formInput.value.sub) {
//     return;
//   }
//   formInput.value.sub[index] = value;
// };
//
// const handleSubDelete = (index: number) => {
//   formInput.value.sub?.splice(index, 1);
// };

const handleCancelClick = (event: any) => {
  event.preventDefault();
  emits("update:modelValue", false);
};

const handleSubmit = async () => {
  validateForm();
  if (!isFormValid.value) {
    return;
  }

  const payload = {
    code: formInput.value.code,
    name: formInput.value.name,
    // description: formInput.value.description,
    // industrySubs: formInput.value.sub?.map((subIndustry: TSubIndustry) => {
    //   const { isEdit, ...rest } = subIndustry;
    //   return rest;
    // }),
  };

  isSubmiting.value = true;
  const res = await updateCareer(careerDetail.value.id, payload);
  if (res) {
    if (props.initialMode == "edit") {
      emits("submit");
    } else {
      currentMode.value = "view";
      await fetchDetail(careerDetail.value.id);
    }
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
    if (careerDetailSnapshot.value) {
      formInput.value = careerDetailSnapshot.value;
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
      careerDetailSnapshot.value = null;
      careerDetail.value = null;
      formInput.value = {
        code: "",
        name: "",
        // description: "",
        // sub: [],
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
.edit-view-industry {
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
  }
}
</style>
