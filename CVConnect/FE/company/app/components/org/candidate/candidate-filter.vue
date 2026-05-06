<template>
  <div class="candidate-filter">
    <div class="content">
      <AppInputText
        :label="'Tên'"
        :required="false"
        :error="''"
        :placeholder="'Mời nhập tên'"
        :value="filter.fullName || ''"
        :is-disabled="false"
        :slim-error="true"
        class="text-input"
        @input="handleInput('fullName' as keyof TCandidateFilter, $event)"
      >
        <template #icon>
          <Icon
            @click="handleSortClick('fullName')"
            :name="sortIcon('fullName')"
          ></Icon>
        </template>
      </AppInputText>
      <AppInputText
        :label="'Email'"
        :required="false"
        :error="''"
        :placeholder="'Mời nhập email'"
        :value="filter.email || ''"
        :is-disabled="false"
        :slim-error="true"
        class="text-input"
        @input="handleInput('email' as keyof TCandidateFilter, $event)"
      >
        <template #icon>
          <Icon
            @click="handleSortClick('email')"
            :name="sortIcon('email')"
          ></Icon>
        </template>
      </AppInputText>
      <AppInputText
        :label="'SĐT'"
        :required="false"
        :error="''"
        :placeholder="'Mời nhập sđt'"
        :value="filter.phone || ''"
        :is-disabled="false"
        :slim-error="true"
        class="text-input"
        @input="handleInput('phone' as keyof TCandidateFilter, $event)"
      >
        <template #icon>
          <Icon
            @click="handleSortClick('phone')"
            :name="sortIcon('phone')"
          ></Icon>
        </template>
      </AppInputText>
      <AppInputSearchSelect
        :label="'Cấp bậc'"
        :required="false"
        :options="levelOptions"
        :value="filter.levels"
        :error="''"
        :placeholder="'Mời chọn cấp bậc'"
        :remote-filter="true"
        :multiple="true"
        :is-disabled="false"
        :slim-error="true"
        :fetch-fn="null"
        @input="handleInput('levels', $event)"
        @clear-value="handleInput('levels', null)"
        @search-filter="
          () => {
            levelList = [];
          }
        "
      >
        <template #icon>
          <Icon
            @click="handleSortClick('levelName')"
            :name="sortIcon('levelName')"
          ></Icon>
        </template>
      </AppInputSearchSelect>
      <div class="label">
        <span>Số tin tuyển dụng</span>
        <Icon
          @click="handleSortClick('numOfApply')"
          :name="sortIcon('numOfApply')"
        ></Icon>
      </div>
      <div class="row">
        <UInputNumber
          v-model="filter.numOfApplyStart"
          variant="none"
          class="num-input"
        />
        <UInputNumber
          v-model="filter.numOfApplyEnd"
          variant="none"
          class="num-input"
        />
      </div>
      <AppInputText
        :label="'Tin tuyển dụng'"
        :required="false"
        :error="''"
        :placeholder="'Mời nhập tin tuyển dụng'"
        :value="filter.jobAdTitle || ''"
        :is-disabled="false"
        :slim-error="true"
        class="text-input"
        @input="handleInput('jobAdTitle' as keyof TCandidateFilter, $event)"
      />
      <AppInputSearchSelect
        :label="'Trạng thái'"
        :required="false"
        :options="CANDIDATE_STATUS_OPTIONS"
        :value="filter.candidateStatusesOpt"
        :error="''"
        :placeholder="'Mời chọn'"
        :remote-filter="false"
        :multiple="true"
        :is-disabled="false"
        :slim-error="true"
        :fetch-fn="null"
        @input="handleInput('candidateStatusesOpt', $event)"
        @clear-value="handleInput('candidateStatusesOpt', null)"
      />
      <AppInputSearchSelect
        :label="'Loại vòng hiện tại'"
        :required="false"
        :options="processTypeOptions"
        :value="filter.processTypesOpt"
        :error="''"
        :placeholder="'Mời chọn'"
        :remote-filter="false"
        :multiple="true"
        :is-disabled="false"
        :slim-error="true"
        :fetch-fn="null"
        @input="handleInput('processTypesOpt', $event)"
        @clear-value="handleInput('processTypesOpt', null)"
        @search-filter="
          () => {
            processTypeList = [];
          }
        "
      />
      <div class="label">Ngày ứng tuyển</div>
      <AppInputDatepicker
        :label="''"
        :required="false"
        :value="dateRangeValue"
        :error="''"
        :slim-error="true"
        :placeholder="''"
        :is-range="true"
        @input="handleDateRangeInput($event)"
      />
      <AppInputSearchSelect
        :label="'HR phụ trách'"
        :required="false"
        :options="hrOptions"
        :value="filter.hrContact"
        :error="''"
        :placeholder="'Mời chọn'"
        :remote-filter="false"
        :multiple="false"
        :is-disabled="false"
        :slim-error="true"
        :fetch-fn="null"
        @input="handleInput('hrContact', $event)"
        @clear-value="handleInput('hrContact', null)"
        @search-filter="
          () => {
            hrList = [];
          }
        "
      />
    </div>
    <div class="footer">
      <AppButton
        class="reset-button"
        :text="'Đặt lại'"
        @click="handleResetFilter"
      />
      <AppButton class="submit-button" :text="'Lọc'" @click="handleSetFilter" />
    </div>
  </div>
</template>
<script setup lang="ts">
import type { TCandidateFilter } from "~/types/candidate";
import { CANDIDATE_STATUS_OPTIONS } from "~/const/views/org/candidates";
import { cloneDeep } from "lodash";
import type { TSort } from "~/types/common";

type TProps = {
  filterData?: TCandidateFilter;
};

const props = withDefaults(defineProps<TProps>(), {
  filterData: () => ({}),
});
const emits = defineEmits<{
  (e: "filterChange", payload: TCandidateFilter): void;
  (e: "sortChange", payload: TSort): void;
}>();

const { getLevels } = useLevelApi();
const { getAll } = useProcessTypeApi();
const { getByRoleCode } = useUserApi();

const filter = ref<TCandidateFilter>({});
const levelList = ref<Record<string, any>[]>([]);
const processTypeList = ref<Record<string, any>[]>([]);
const hrList = ref<Record<string, any>[]>([]);

onBeforeMount(() => {
  fetchLevel({});
  fetchHr({});
  fetchProcessType({});
  if (filter.value.candidateStatusesOpt?.length) {
    filter.value.candidateStatusesOpt = filter.value.candidateStatusesOpt.map(
      (status) => {
        const statusOpt = CANDIDATE_STATUS_OPTIONS.find(
          (opt) => opt.value == status.value,
        );
        return statusOpt as Record<string, string>;
      },
    );
  }
});

const dateRangeValue = computed(() => {
  const ranges = [];
  const from = filter.value.applyDateStart;
  const to = filter.value.applyDateEnd;
  if (from) {
    ranges.push(from);
  } else {
    ranges.push(null);
  }

  if (to) {
    ranges.push(to);
  } else {
    ranges.push(null);
  }

  if (!ranges[0] && !ranges[1]) {
    return null;
  }

  return ranges;
});

const sortIcon = computed(() => {
  return (key: string) => {
    if (filter.value.sortBy !== key) {
      return "mdi:sort";
    }
    if (filter.value.sortDirection === "ASC") {
      return "mdi:sort-ascending";
    } else if (filter.value.sortDirection === "DESC") {
      return "mdi:sort-descending";
    } else {
      return "mdi:sort";
    }
  };
});

const levelOptions = computed(() => {
  return levelList.value.map((level) => ({
    label: level.name,
    value: level.id,
  }));
});

const processTypeOptions = computed(() => {
  return processTypeList.value.map((process) => ({
    label: process.name,
    value: process.id,
  }));
});

const hrOptions = computed(() => {
  return hrList.value.map((hr) => ({
    label: hr.fullName,
    value: hr.id,
  }));
});

function handleSortClick(key: string) {
  if (filter.value.sortBy === key) {
    const currType = filter.value.sortDirection;
    if (currType === "ASC") {
      emits("sortChange", { key, type: "DESC" });
    } else if (currType === "DESC") {
      emits("sortChange", { key: undefined, type: undefined });
    } else {
      emits("sortChange", { key, type: "ASC" });
    }
  } else {
    emits("sortChange", { key, type: "ASC" });
  }
}

function handleDateRangeInput(range: any) {
  if (!range?.length) {
    filter.value.applyDateStart = undefined;
    filter.value.applyDateEnd = undefined;
    return;
  }
  const from = range[0];
  const to = range[1];
  if (from) {
    filter.value.applyDateStart = from;
  }
  if (to) {
    filter.value.applyDateEnd = to;
  }
}

function handleInput(key: keyof TCandidateFilter, value: any) {
  filter.value[key] = value;
}

function handleSetFilter() {
  console.log("clicked", filter.value);
  emits("filterChange", filter.value);
}

function handleResetFilter() {
  filter.value = {};
  emits("filterChange", filter.value);
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
  if (filter.value.levels?.length) {
    filter.value.levels = filter.value.levels.map((level) => {
      const levelOpt = levelOptions.value.find(
        (opt) => opt.value == level.value,
      );
      return levelOpt as Record<string, number>;
    });
  }
  return res.data.data;
}

async function fetchProcessType(params: any, controller?: AbortController) {
  // const ids = formInput.value.department.value;
  const newParams = {
    ...params,
    // departmentIds: ids,
  };
  const res = await getAll();
  if (!res) {
    return null;
  }
  const nextPage = res.data;
  processTypeList.value = [...processTypeList.value, ...nextPage];
  if (filter.value.processTypesOpt?.length) {
    filter.value.processTypesOpt = filter.value.processTypesOpt.map(
      (process) => {
        const processOpt = processTypeOptions.value.find(
          (opt) => opt.value == process.value,
        );
        return processOpt as Record<string, number>;
      },
    );
  }
  return res.data.data;
}

async function fetchHr(params: any, controller?: AbortController) {
  const res = await getByRoleCode("HR");
  if (!res) {
    return null;
  }

  hrList.value = res.data;
  if (filter.value.hrContact) {
    const hrOpt = hrOptions.value.find(
      (hr) => hr.value == filter.value.hrContact?.value,
    );
    if (hrOpt) {
      filter.value.hrContact = hrOpt;
    }
  }

  return res.data;
}

watch(
  () => props.filterData,
  (newVal) => {
    filter.value = cloneDeep(newVal);
  },
);
</script>
<style lang="scss" scoped>
.candidate-filter {
  display: flex;
  flex-direction: column;
  max-height: 100%;
  overflow-x: hidden;

  .content {
    display: flex;
    flex: 1;
    min-height: 0;
    max-height: 100%;
    @include custom-scrollbar;
    overflow-y: auto;
    overflow-x: hidden;
    flex-direction: column;
    gap: 4px;

    .num-input {
      :deep(input) {
        border: 1px solid rgba($color-primary-800, 0.1);
        border-radius: 12px;

        &:hover,
        &:focus {
          border: 1px solid rgba($color-primary-400, 1);
        }
      }
    }

    :deep(.text-input),
    :deep(.number-input) {
      .input-wrapper {
        .input {
          padding: 6px 8px;
          max-width: 100%;
          min-width: 0;
          input {
            font-size: 14px;
            max-width: 100%;
            min-width: 0;
          }
        }
      }
    }

    .row {
      display: flex;
      flex-direction: row;
      gap: 8px;
    }
  }

  .divider {
    display: block;
    height: 1px;
    min-height: 1px;
    width: 100%;
    background-color: $color-gray-200;
  }

  .label {
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .iconify {
    display: block;
    font-size: 20px;
    color: $color-primary-500;
    cursor: pointer;
    margin-left: 8px;
  }

  .footer {
    padding: 4px;
    display: flex;
    flex-direction: row;
    justify-content: flex-end;
    gap: 12px;
    .submit-button {
      padding: 4px 8px;
      background-color: $color-primary-500;
      border: 1px solid $color-primary-500;
      color: $text-dark;
      font-size: 14px;
      min-width: 84px;
    }

    .reset-button {
      padding: 4px 8px;
      color: $color-primary-500;
      border: 1px solid $color-primary-500;
      font-size: 14px;
      min-width: 84px;
    }
  }
}
</style>
