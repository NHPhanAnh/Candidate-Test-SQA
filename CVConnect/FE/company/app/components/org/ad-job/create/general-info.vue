<template>
  <div class="general-info">
    <div class="title">Thông tin chung</div>
    <div v-if="isLoading" class="loading">
      <AppSpinnerHalfCircle />
    </div>
    <div v-else class="content">
      <AppInputText
        :label="'Tiêu đề tin đăng'"
        :required="true"
        :error="formError.title"
        :placeholder="'Mời nhập tiêu đề'"
        :value="formInput.title"
        class="title-input"
        @input="handleInput('title', $event)"
        @blur="validateKey('title')"
      />
      <div class="row">
        <AppInputSearchSelect
          :label="'Phòng ban'"
          :required="true"
          :options="departmentList"
          :value="formInput.department"
          :error="formError.department"
          :placeholder="'Mời chọn phòng ban'"
          :remote-filter="true"
          :multiple="false"
          :fetch-fn="fetchDepartments"
          @open-update="handleDepartmentOpenUpdate"
          @input="handleInput('department', $event)"
          @clear-value="handleClearDepartment"
          @search-filter="
            () => {
              departmentList = [];
            }
          "
        />
        <AppInputSearchSelect
          :label="'Vị trí'"
          :required="true"
          :options="positionOptions"
          :value="formInput.position"
          :error="formError.position"
          :placeholder="'Mời chọn vị trí'"
          :remote-filter="true"
          :multiple="false"
          :is-disabled="formInput.department.length == 0"
          :fetch-fn="fetchPosition"
          @open-update="handlePositionOpenUpdate"
          @input="handleInput('position', $event)"
          @clear-value="handleClearPosition"
          @search-filter="
            () => {
              positionList = [];
            }
          "
        />
        <AppInputSearchSelect
          :label="'Cấp bậc'"
          :required="true"
          :options="levelOptions"
          :value="formInput.level"
          :error="formError.level"
          :placeholder="'Mời chọn cấp bậc'"
          :remote-filter="true"
          :multiple="true"
          :is-disabled="false"
          :fetch-fn="fetchLevel"
          @open-update="handlePositionOpenUpdate"
          @input="handleInput('level', $event)"
          @clear-value="handleInput('level', null)"
          @search-filter="
            () => {
              levelList = [];
            }
          "
        />
        <AppInputSearchSelect
          :label="'Ngành nghề'"
          :required="false"
          :options="career"
          :value="formInput.career"
          :error="formError.career"
          :placeholder="'Mời chọn ngành nghề'"
          :remote-filter="true"
          :multiple="true"
          :fetch-fn="fetchCareer"
          @open-update="handleCareerOpenUpdate"
          @input="handleInput('career', $event)"
          @clear-value="handleInput('career', [])"
          @search-filter="
            () => {
              career = [];
            }
          "
        />
      </div>
      <div class="row">
        <AppInputSearchSelect
          :label="'Địa điểm làm việc'"
          :required="true"
          :options="locationOptions"
          :value="formInput.location"
          :error="formError.location"
          :placeholder="'Mời chọn địa điểm làm việc'"
          :remote-filter="false"
          :multiple="true"
          :is-paginated="false"
          :fetch-fn="fetchLocation"
          @open-update="handleLocationOpenUpdate"
          @input="handleInput('location', $event)"
          @clear-value="handleInput('location', [])"
          @search-filter="
            () => {
              locationList = [];
            }
          "
        />
        <AppInputSearchSelect
          :label="'Loại hình công việc'"
          :required="true"
          :options="jobTypeList"
          :value="formInput.jobType"
          :error="formError.jobType"
          :placeholder="'Mời chọn loại hình công việc'"
          :remote-filter="false"
          :multiple="false"
          :is-paginated="false"
          :fetch-fn="fetchJobType"
          @open-update="handleJobTypeOpenUpdate"
          @input="handleInput('jobType', $event)"
          @clear-value="handleInput('jobType', null)"
          @search-filter="
            () => {
              locationList = [];
            }
          "
        />
        <AppInputDatepicker
          :label="'Hạn nộp hồ sơ'"
          :required="true"
          :value="formInput.dueDate"
          :error="formError.dueDate"
          :placeholder="'Mời chọn ngày nộp hồ sơ'"
          @input="handleInput('dueDate', $event)"
          @clear="validateKey('dueDate')"
          @close="validateKey('dueDate')"
        />
        <AppInputNumber
          :label="'Số lượng'"
          :required="true"
          :error="formError.quant"
          :placeholder="'Mời nhập số lượng'"
          :value="formInput.quant"
          @input="handleInput('quant', $event)"
          @blur="validateKey('quant')"
        />
      </div>
      <div class="row">
        <UCheckbox
          class="checkbox"
          :model-value="formInput.hasRemote"
          :label="'Cho phép làm từ xa'"
          @update:model-value="handleInput('hasRemote', $event)"
        />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
const { getDepartments } = useDepartmentApi();
const { getPositions } = usePositionApi();
const { getIndustriesSub } = useIndustryApi();
const { getCareers } = useCareerApi();
const { getAllLocations } = useLocationApi();
const { getJobTypes } = useEnumApi();
const { getLevels } = useLevelApi();

export type TGeneralInfoForm = {
  title: string;
  department: Record<string, any>[];
  position: Record<string, any> | null;
  level: Record<string, any>[] | null;
  career: Record<string, any>[];
  location: Record<string, any>[];
  jobType: Record<string, any> | null;
  dueDate: string | null;
  quant: Record<string, any> | null;
  hasRemote: boolean;
};

type TProps = {
  data?: TGeneralInfoForm;
};

const props = withDefaults(defineProps<TProps>(), {
  data: () => ({
    title: "",
    department: [],
    position: null,
    level: null,
    career: [],
    location: [],
    jobType: null,
    dueDate: null,
    quant: null,
    hasRemote: false,
  }),
});
const emits = defineEmits<{
  (e: "dataChange", payload: TGeneralInfoForm): void;
}>();

const isLoading = ref<boolean>(false);
const departmentList = ref<Record<string, any>[]>([]);
const positionList = ref<Record<string, any>[]>([]);
const levelList = ref<Record<string, any>[]>([]);
const career = ref<Record<string, any>[]>([]);
const locationList = ref<Record<string, any>[]>([]);
const jobTypeList = ref<Record<string, any>[]>([]);

const formInput = ref<Record<string, any>>({});

const formError = ref<Record<string, any>>({
  title: "",
  department: "",
  position: "",
  level: "",
  career: "",
  location: "",
  jobType: "",
  dueDate: "",
  quant: "",
});

onBeforeMount(() => {
  formInput.value = props.data;
});

const formRule: Record<string, any> = {
  title: [
    {
      error: "Mời nhập tiêu đề",
      validator: (input: string) => !!input.trim(),
    },
  ],
  department: [
    {
      error: "Mời chọn phòng ban",
      validator: (input: any[]) => {
        console.log(input);
        return !!input;
      },
    },
  ],
  position: [
    {
      error: "Mời chọn vị trí",
      validator: (input: any | null) => !!input,
    },
  ],
  level: [
    {
      error: "Mời chọn cấp bậc",
      validator: (input: any[]) => !!input.length,
    },
  ],
  location: [
    {
      error: "Mời chọn địa điểm làm việc",
      validator: (input: any[]) => !!input.length,
    },
  ],
  jobType: [
    {
      error: "Mời chọn loại hình công việc",
      validator: (input: any) => !!input,
    },
  ],
  dueDate: [
    {
      error: "Mời chọn hạn nộp hồ sơ",
      validator: (input: any) => {
        return !!input;
      },
    },
  ],
  quant: [
    {
      error: "Mời chọn số lượng",
      validator: (input: any) => {
        return input != null && input != undefined;
      },
    },
  ],
};

function handleClearDepartment() {
  handleInput("department", []);
  handleInput("position", null);
  handleInput("level", null);
}

function handleClearPosition() {
  handleInput("position", null);
  handleInput("level", null);
}

function handleDepartmentOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("department");
  }
}

function handlePositionOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("position");
  }
}

function handleCareerOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("career");
  }
}

function handleLocationOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("location");
  }
}

function handleJobTypeOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("jobType");
  }
}

async function fetchPosition(params: any, controller?: AbortController) {
  const ids = formInput.value.department.value;
  const newParams = {
    ...params,
    departmentIds: ids,
  };
  const res = await getPositions(newParams, controller);
  if (!res) {
    return null;
  }
  const nextPage = res.data.data.filter((pos: any) => pos.isActive);
  positionList.value = [...positionList.value, ...nextPage];
  return res.data.data;
}

async function fetchLevel(params: any, controller?: AbortController) {
  // const ids = formInput.value.department.value;
  const newParams = {
    ...params,
    // departmentIds: ids,
  };
  const res = await getLevels(newParams, controller);
  if (!res) {
    return null;
  }
  const nextPage = res.data.data;
  levelList.value = [...levelList.value, ...nextPage];
  if (levelList.value[0]?.id != 0) {
    levelList.value.unshift({
      name: "Tất cả",
      id: 0,
    });
  }
  return res.data.data;
}

async function fetchDepartments(params: any, controller?: AbortController) {
  const res = await getDepartments(params, controller);
  if (!res) {
    return null;
  }
  const nextPage = res.data.data
    .filter((dept: any) => dept.isActive)
    .map((dept: any) => ({
      label: dept.name,
      value: dept.id,
    }));
  departmentList.value = [...departmentList.value, ...nextPage];
  return res.data.data;
}

async function fetchCareer(params: any, controller?: AbortController) {
  const res = await getCareers(params, controller);
  if (!res) {
    return null;
  }
  const nextPage = res.data.data.map((career: any) => ({
    label: career.name,
    value: career.id,
  }));
  career.value = [...career.value, ...nextPage];
  return res.data.data;
}

async function fetchLocation(params: any, controller?: AbortController) {
  const res = await getAllLocations();
  if (!res) {
    return null;
  }
  locationList.value = res.data;
  return res.data;
}

async function fetchJobType(params: any, controller?: AbortController) {
  const res = await getJobTypes();
  if (!res) {
    return null;
  }
  jobTypeList.value = res.data.map((jobType: any) => ({
    label: jobType.description,
    value: jobType.name,
  }));
  return res.data;
}

const locationOptions = computed(() => {
  return locationList.value.map((location) => ({
    label: location.displayAddress,
    value: location.id,
  }));
});

const positionOptions = computed(() => {
  return positionList.value.map((position) => ({
    label: position.name,
    value: position.id,
  }));
});

const levelOptions = computed(() => {
  return levelList.value.map((level) => ({
    label: level.name,
    value: level.id,
  }));
});

function handleInput(key: string, value: any) {
  if (key == "level") {
    console.log("input level ne", value);
    if (value.length && value[value.length - 1].value == 0) {
      formError.value[key] = "";
      formInput.value[key] = [value[value.length - 1]];
    } 
    else if (value.length && value[value.length - 1].value != 0 && value.find((val: any) => val.value == 0) != undefined) {
      const index = value.findIndex((val: any) => val.value == 0);
      const newValue = value;
      newValue.splice(index, 1);
      formError.value[key] = "";
      formInput.value[key] = newValue;
    } else {
      formError.value[key] = "";
      formInput.value[key] = value;
    }
  } else {
    formError.value[key] = "";
    formInput.value[key] = value;
  }
}

function validateKey(key: string) {
  const rules = formRule[key];
  if (!rules) {
    return;
  }
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
    emits("dataChange", newVal as TGeneralInfoForm);
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.general-info {
  display: flex;
  flex-direction: column;
  gap: 8px;

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

  .checkbox {
    :deep(label) {
      color: $text-light;
      font-weight: 400;
      cursor: pointer !important;
    }
    :deep(button) {
      cursor: pointer !important;
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
