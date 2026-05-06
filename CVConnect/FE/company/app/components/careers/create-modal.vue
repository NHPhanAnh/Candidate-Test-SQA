<template>
  <div class="create-modal">
    <UModal
      v-model:open="isOpen"
      title="Thêm mới ngành nghề"
      :ui="{ content: 'w-[840px] max-w-[840px]' }"
    >
      <template #body>
        <div class="create-industry">
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
            <!-- <div class="line"> -->
            <!--   <div class="text-area"> -->
            <!--     <AppInputTextarea -->
            <!--       v-model="formInput.description" -->
            <!--       :label="'Mô tả'" -->
            <!--       :required="false" -->
            <!--       :placeholder="'Mời nhập mô tả'" -->
            <!--       :error="''" -->
            <!--       :show-error="false" -->
            <!--     /> -->
            <!--   </div> -->
            <!-- </div> -->
            <!-- <div class="line"> -->
            <!--   <div class="sub-list"> -->
            <!--     <div class="label">Phân ngành</div> -->
            <!--     <IndustrySubIndustry -->
            <!--       v-for="(item, index) of formInput.sub" -->
            <!--       :key="index" -->
            <!--       :data="item" -->
            <!--       @input="handleSubInput(index, $event)" -->
            <!--       @delete="handleSubDelete(index)" -->
            <!--     /> -->
            <!--     <div class="add-button" @click="handleAddSub">Thêm mới</div> -->
            <!--   </div> -->
            <!-- </div> -->
          </form>
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
import type { TSubIndustry } from "~/types/subIndustry";
// import SubIndustry from "./sub-industry.vue";

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
  // description?: string;
  // sub?: TSubIndustry[];
};

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

const { createIndustry } = useIndustryApi();
const {createCareer} = useCareerApi();

const isSubmiting = ref<boolean>(false);

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

  // if (formInput.value.sub) {
  //   for (const sub of formInput.value.sub) {
  //     if (!sub.code || !sub.name) {
  //       return false;
  //     }
  //   }
  // }

  return true;
});

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
  const res = await createCareer(payload);
  if (res) {
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
</script>
<style lang="scss" scoped>
.create-industry {
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
