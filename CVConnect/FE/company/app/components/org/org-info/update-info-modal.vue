<template>
  <div class="change-logo-modal">
    <UModal
      v-model:open="isOpen"
      :ui="{ content: 'max-w-[800px]' }"
      :title="'Cập nhật thông tin doanh nghiệp'"
    >
      <template #body>
        <div class="modal-body">
          <div class="row">
            <AppInputText
              :label="'Tên công ty'"
              :required="true"
              :error="''"
              :placeholder="'Mời nhập tên'"
              :value="formInput.name"
              class="title-input"
              @input="handleInput('name', $event)"
            />
            <AppInputText
              :label="'Website'"
              :required="false"
              :error="''"
              :placeholder="'Mời nhập website'"
              :value="formInput.website"
              class="title-input"
              @input="handleInput('website', $event)"
            />
          </div>

          <div class="row">
            <AppInputSearchSelect
              :label="'Số lượng nhận sự'"
              :required="false"
              :options="companySizeOptions"
              :value="formInput.companySize"
              :placeholder="'Mời chọn số lượng nhân sự'"
              :remote-filter="false"
              :multiple="false"
              :fetch-fn="null"
              @input="handleInput('companySize', $event)"
              @clear-value="handleClearCompanySize"
            />
            <AppInputSearchSelect
              :label="'Ngành nghề'"
              :required="false"
              :options="industryList"
              :value="formInput.industryList"
              :placeholder="'Mời chọn lĩnh vực'"
              :remote-filter="true"
              :multiple="true"
              :fetch-fn="fetchIndustries"
              @input="handleInput('industryList', $event)"
              @clear-value="handleInput('industryList', [])"
              @search-filter="
                () => {
                  industryList = [];
                }
              "
            />
          </div>
          <div class="row">
            <div class="textarea-block">
              <div class="label">
                <span class="text">Thông tin chung</span>
                <!-- <span class="required">Bắt buộc</span> -->
              </div>
              <AppInputBasicTextEditor
                :value="formInput.description"
                @input="handleInput('description', $event)"
              />
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
              @click.prevent="emits('update:modelValue', false)"
            />
            <AppButton
              :is-disabled="!isFormValid"
              :text="'Lưu'"
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
import { cloneDeep, isEqual } from "lodash";

type TProps = {
  modelValue: boolean;
  companyInfo: any;
};
const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

const { getIndustriesPublic } = useIndustryApi();
const { updateInfo } = useOrgApi();

const isSubmiting = ref<boolean>(false);
const formInput = ref<any>({});
const formInputSnapshot = ref<any>({});
const industryList = ref<any>([]);

const companySizeOptions = [
  { label: "Từ 1 đến 50", value: "1-50" },
  { label: "Từ 50 đến 100", value: "50-100" },
  { label: "Từ 100 đến 200", value: "100-200" },
  { label: "Từ 200 đến 500", value: "200-500" },
  { label: "Trên 500", value: "500-" },
];

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const isFormValid = computed(() => {
  if (!formInput.value) {
    return false;
  }

  if (isEqual(formInput.value, formInputSnapshot.value)) {
    console.log("equal, returning false");
    return false;
  }

  if (
    !formInput.value.name.trim()
  ) {
    console.log("failed here");
    return false;
  }

  console.log("somehow it got here?");
  return true;
});

async function handleSubmit() {
  //call api here
  const payload: Record<string, any> = {
    name: formInput.value.name.trim(),
    website: formInput.value.website.trim(),
    description: formInput.value.description.trim(),
    industryIds: formInput.value.industryList.map((indus: any) => indus.value),
  };

  const staffCount = formInput.value.companySize?.value?.split("-");
  if (staffCount) {
    const from = staffCount[0];
    const to = staffCount[1];

    if (from) {
      payload.staffCountFrom = from;
    }
    if (to) {
      payload.staffCountTo = to;
    }
  }
  isSubmiting.value = true;
  const res = await updateInfo(payload);
  if (res) {
    emits("submit");
  }
  isSubmiting.value = false;
}

function handleInput(key: string, value: any) {
  if (key == "industryList") {
    console.log(value.length);
    if (value.length > 5) {
      return;
    }
  }
  formInput.value[key] = value;
}

function handleClearCompanySize() {
  handleInput("companySize", null);
}

async function fetchIndustries(params: any, controller?: AbortController) {
  const res = await getIndustriesPublic(params, controller);
  if (!res) {
    return null;
  }
  const nextPage = res.data.data.map((industry: any) => ({
    label: industry.name,
    value: industry.id,
  }));
  industryList.value = [...industryList.value, ...nextPage];
  return res.data.data;
}

watch(
  () => props.modelValue,
  (newVal) => {
    if (newVal) {
      formInput.value = {
        name: props.companyInfo.name,
        description: props.companyInfo.description,
        website: props.companyInfo.website,
        industryList: props.companyInfo.industryList.map((indus: any) => ({
          label: indus.name,
          value: indus.id,
        })),
      };
      const from = props.companyInfo.staffCountFrom;
      const to = props.companyInfo.staffCountTo;
      if (from == 1) {
        formInput.value.companySize = companySizeOptions[0];
      }

      if (from == 50) {
        formInput.value.companySize = companySizeOptions[1];
      }

      if (from == 100) {
        formInput.value.companySize = companySizeOptions[2];
      }

      if (from == 200) {
        formInput.value.companySize = companySizeOptions[3];
      } else {
        formInput.value.companySize = companySizeOptions[4];
      }
      formInputSnapshot.value = cloneDeep(formInput.value);
    }
  },
);
</script>
<style lang="scss" scoped>
.modal-body {
  display: flex;
  justify-content: center;
  flex-direction: column;
  gap: 4px;
  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;

    :deep(.search-select-input),
    :deep(.text-input),
    :deep(.datepicker-input) {
      max-width: calc((100% - 8px) * 0.5);
      min-width: calc((100% - 8px) * 0.5);
    }
    @include respond-max(1064px) {
      flex-wrap: wrap;

      :deep(.search-select-input),
      :deep(.text-input),
      :deep(.datepicker-input) {
        max-width: calc((100% - 8px) * 0.5);
        min-width: calc((100% - 8px) * 0.5);
      }
    }
  }
  :deep(.text-input) {
    .input-wrapper {
      .input {
        padding: 6px 8px;
        input {
          font-size: 14px;
        }
      }
    }
  }

  .textarea-block {
    display: flex;
    flex-direction: column;
    gap: 4px;
    flex: 1;
    max-width: 100%;
    .label {
      display: flex;
      flex-direction: row;
      gap: 8px;
      align-items: center;
      width: fit-content;

      .text {
        font-size: 14px;
        line-height: 21px;
      }

      .required {
        font-size: 12px;
        font-style: italic;
        color: $color-danger;
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
