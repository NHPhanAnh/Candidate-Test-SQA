<template>
  <div class="hr-info">
    <div class="title">HR phụ trách</div>
    <div class="content">
      <div class="row">
        <AppInputSearchSelect
          :label="'Tên'"
          :required="true"
          :options="hrOptions"
          :value="formInput.hrInfo"
          :error="''"
          :placeholder="'Mời chọn HR phụ trách'"
          :remote-filter="false"
          :multiple="false"
          :is-paginated="false"
          :fetch-fn="fetchHr"
          @input="handleInput('hrInfo', $event)"
          @clear-value="handleClearDepartment"
          @search-filter="
            () => {
              hrList = [];
            }
          "
        />
        <template v-if="selectedHr">
          <AppInputText
            :label="'SĐT'"
            :required="true"
            :error="''"
            :tooltip="
              selectedHr.phoneNumber
                ? ''
                : 'HR phụ trách cần cập nhật SDT để có thể được chọn'
            "
            :placeholder="''"
            :value="selectedHr.phoneNumber ?? ''"
            :is-disabled="true"
          />
          <AppInputText
            :label="'Email'"
            :required="true"
            :error="''"
            :placeholder="''"
            :value="selectedHr.email"
            :is-disabled="true"
          />
        </template>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
const { getByRoleCode } = useUserApi();

export type THrInfoForm = {
  hrInfo: Record<string, any> | null;
};

type TProps = {
  data?: THrInfoForm;
};

const props = withDefaults(defineProps<TProps>(), {
  data: () => ({
    hrInfo: null,
  }),
});
const emits = defineEmits<{
  (e: "dataChange", payload: THrInfoForm): void;
}>();

const hrList = ref<Record<string, any>[]>([]);

const formInput = ref<Record<string, any>>({});

onBeforeMount(() => {
  formInput.value = props.data;
});

function handleClearDepartment() {
  handleInput("hrInfo", null);
}

async function fetchHr(params: any, controller?: AbortController) {
  const res = await getByRoleCode("HR");
  if (!res) {
    return null;
  }

  hrList.value = res.data;

  return res.data;
}

const selectedHr = computed(() => {
  return hrList.value.find((hr) => hr.id === formInput.value.hrInfo?.value);
});

const hrOptions = computed(() => {
  return hrList.value.map((hr) => ({
    label: hr.fullName,
    value: hr.id,
  }));
});

function handleInput(key: string, value: any) {
  console.log(key, value);
  formInput.value[key] = value;
}

watch(
  formInput,
  (newVal) => {
    emits("dataChange", newVal as THrInfoForm);
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.hr-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 20px;

  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    @include respond-max(958px) {
      flex-wrap: wrap;
      flex-direction: column;

      :deep(.search-select-input),
      :deep(.text-input),
      :deep(.datepicker-input) {
        max-width: calc((100%) * 1);
        min-width: calc((100%) * 1);
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

  :deep(.text-input) {
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
  :deep(.text-input),
  :deep(.datepicker-input) {
    max-width: calc((100% - 16px) * 0.333333);
    min-width: calc((100% - 16px) * 0.333333);
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
      margin: 0px 0px;
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
