<template>
  <div class="salary-info">
    <div class="title">Mức lương</div>
    <div v-if="isLoading" class="loading">
      <AppSpinnerHalfCircle />
    </div>
    <div v-else class="content">
      <div class="row">
        <AppInputSearchSelect
          :label="'Hình thức'"
          :required="true"
          :options="salaryTypeList"
          :value="formInput.salaryType"
          :error="formError.salaryType"
          :placeholder="'Mời chọn hình thức'"
          :remote-filter="false"
          :multiple="false"
          :is-paginated="false"
          :fetch-fn="fetchSalaryType"
          @open-update="handleSalaryTypeOpenUpdate"
          @input="handleInput('salaryType', $event)"
          @clear-value="handleInput('salaryType', null)"
          @search-filter="
            () => {
              salaryTypeList = [];
            }
          "
        />
        <AppInputNumber
          :label="'Từ'"
          :required="isRangeSalary"
          :error="formError.quant"
          :placeholder="'Mời nhập'"
          :value="formInput.quant"
          :is-disabled="!isRangeSalary"
          @input="handleInput('salaryFrom', $event)"
          @blur="validateKey('salaryFrom')"
        />
        <AppInputNumber
          :label="'Đến'"
          :required="isRangeSalary"
          :error="formError.quant"
          :placeholder="'Mời nhập'"
          :value="formInput.quant"
          :is-disabled="!isRangeSalary"
          @input="handleInput('salaryTo', $event)"
          @blur="validateKey('salaryTo')"
        />
        <AppInputSearchSelect
          :label="'Loại tiền'"
          :required="true"
          :options="currencyList"
          :value="formInput.currency"
          :error="formError.currency"
          :placeholder="'Mời chọn loại tiền'"
          :remote-filter="false"
          :multiple="false"
          :is-paginated="false"
          :fetch-fn="fetchCurrency"
          @open-update="handleCurrencyOpenUpdate"
          @input="handleInput('currency', $event)"
          @clear-value="handleInput('currency', null)"
          @search-filter="
            () => {
              currencyList = [];
            }
          "
        />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { SALARY_TYPE } from "~/const/common";

const { getSalaryType, getCurrency } = useEnumApi();

export type TSalaryInfoForm = {
  salaryType: Record<string, any> | null;
  salaryFrom: number | null;
  salaryTo: number | null;
  currency: Record<string, any> | null;
};

type TProps = {
  data?: TSalaryInfoForm;
};

const props = withDefaults(defineProps<TProps>(), {
  data: () => ({
    salaryType: null,
    salaryFrom: null,
    salaryTo: null,
    currency: null,
  }),
});
const emits = defineEmits<{
  (e: "dataChange", payload: TSalaryInfoForm): void;
}>();

const isLoading = ref<boolean>(false);
const salaryTypeList = ref<Record<string, any>[]>([]);
const currencyList = ref<Record<string, any>[]>([]);

const formInput = ref<Record<string, any>>({});

const formError = ref<Record<string, any>>({
  salaryType: "",
  salaryFrom: "",
  salaryTo: "",
  currency: "",
});

onBeforeMount(() => {
  formInput.value = props.data;
});

const formRule: Record<string, any> = {
  salaryType: [
    {
      error: "Mời chọn hình thức",
      validator: (input: string) => !!input,
    },
  ],
  salaryFrom: [
    {
      error: "Mời nhập",
      validator: (input: number | null) => {
        if (input == null || input == undefined) {
          return false;
        }
        return true;
      },
    },
    {
      error: "Giá trị phải lớn hơn 0",
      validator: (input: number | null) => {
        if (input == null || input == undefined) {
          return false;
        }
        if (input <= 0) return true;
      },
    },
    {
      error: "Giá trị phải nhỏ hơn mức lương tối đa",
      validator: (input: number | null) => {
        if (input == null || input == undefined) {
          return false;
        }
        if (formInput.value.salaryTo && input > formInput.value.salaryTo)
          return true;
      },
    },
  ],
  salaryTo: [
    {
      error: "Mời nhập",
      validator: (input: number | null) => {
        if (input == null || input == undefined) {
          return false;
        }
        return true;
      },
    },
    {
      error: "Giá trị phải lớn hơn 0",
      validator: (input: number | null) => {
        if (input == null || input == undefined) {
          return false;
        }
        if (input <= 0) return true;
      },
    },
    {
      error: "Giá trị phải lớn hơn mức lương tối thiểu",
      validator: (input: number | null) => {
        if (input == null || input == undefined) {
          return false;
        }
        if (formInput.value.salaryFrom && input < formInput.value.salaryFrom)
          return true;
      },
    },
  ],
  currency: [
    {
      error: "Mời chọn loại tiền",
      validator: (input: string) => !!input,
    },
  ],
};

const isRangeSalary = computed(() => {
  if (!formInput.value.salaryType) {
    return false;
  }
  return formInput.value.salaryType.value == SALARY_TYPE.RANGE;
});

function handleSalaryTypeOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("salaryType");
  }
}

function handleCurrencyOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("currency");
  }
}

async function fetchSalaryType(params: any, controller?: AbortController) {
  const res = await getSalaryType();
  if (!res) {
    return null;
  }
  salaryTypeList.value = res.data.map((salaryType: any) => ({
    label: salaryType.description,
    value: salaryType.name,
  }));
  return res.data;
}

async function fetchCurrency(params: any, controller?: AbortController) {
  const res = await getCurrency();
  if (!res) {
    return null;
  }
  currencyList.value = res.data.map((currency: any) => ({
    label: currency.description,
    value: currency.name,
  }));
  return res.data;
}

function handleInput(key: string, value: any) {
  console.log(key, value);
  formError.value[key] = "";
  formInput.value[key] = value;
}

function validateKey(key: string) {
  const rules = formRule[key];
  for (const rule of rules) {
    const isValid = rule.validator(formInput.value[key]);
    if (!isValid) {
      formError.value[key] = rule.error;
      break;
    }
  }
}

watch(
  formInput,
  (newVal) => {
    emits("dataChange", newVal as TSalaryInfoForm);
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.salary-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 20px;

  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    @include respond-max(1064px) {
      flex-wrap: wrap;

      :deep(.search-select-input),
      :deep(.number-input),
      :deep(.datepicker-input) {
        max-width: calc((100% - 8px) * 0.5);
        min-width: calc((100% - 8px) * 0.5);
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

  :deep(.number-input) {
    .input-wrapper {
      .input {
        padding: 6px 8px;
        input {
          font-size: 14px;
        }
      }
    }
  }

  :deep(.text-input.title-input) {
    max-width: calc(50% - 4px);
    .input {
      padding: 6px 8px;
      input {
        font-size: 14px;
      }
    }

    @include respond-max(1064px) {
      max-width: 100%;
    }
  }

  :deep(.search-select-input),
  :deep(.number-input),
  :deep(.datepicker-input) {
    max-width: calc((100% - 24px) * 0.25);
    min-width: calc((100% - 24px) * 0.25);
  }

  .select-input {
    display: flex;
    flex-direction: column;
    gap: 4px;
    flex: 1;

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

    .error-message {
      min-height: 16px;
      display: inline-block;
      color: $color-danger;
      font-size: 12px;
      line-height: 16px;
    }

    :deep(button.selector) {
      margin: 2px 0px;
      cursor: pointer;
      border: 1px solid rgba($color-primary-800, 0.1);

      &:disabled {
        border: 1px solid rgba($color-gray-300, 1);
        cursor: default;
        opacity: 100%;
      }

      &.error {
        border: 1px solid $color-danger;
      }

      border-radius: 10px !important;
      padding: 6px 48px 6px 8px !important;
      font-weight: 500 !important;
      color: $text-light !important;
      height: 36px;
      background-color: white !important;
      width: 100%;
      max-width: 100%;

      &:hover:not(:disabled) {
        border: 1px solid rgba($color-primary-400, 1);
      }

      span {
        font-size: 14px;
        line-height: 21px;
        color: $text-light;
        font-weight: 400 !important;
      }
      .text-dimmed {
        font-size: 14px;
        line-height: 21px;
        color: $color-gray-300;
        font-weight: 400 !important;
      }
    }
  }
}
</style>
