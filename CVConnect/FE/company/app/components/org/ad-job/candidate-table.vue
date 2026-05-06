<template>
  <div class="table-wrapper">
    <div class="table-content">
      <OrgAdJobCandidateBaseTable
        :table-data="tableData"
        :columns="tableColumns"
        :allow-actions="['VIEW']"
        :show-actions="true"
        :is-loading="isLoading"
        :selection-list="[]"
        :select-options="selectOptions"
        :sort="sort"
        :filter="filter"
        :is-table-empty="isNoData"
        @view="handleTableActionClick($event, 'view')"
        @sort="handleSort"
        @filter="handleFilter"
      />
    </div>
    <div class="top-section">
      <UPagination
        :show-edges="true"
        :sibling-count="1"
        :variant="'ghost'"
        active-variant="subtle"
        :items-per-page="pageSize"
        :page="pageIndex"
        :total="totalItems"
        @update:page="handlePageIndexChange($event)"
      />
      <USelect
        variant="subtle"
        :items="pageSizeOpts"
        class="w-fit bg-white text-[#333333]"
        :model-value="pageSize"
        @update:model-value="handlePageSizeChange($event)"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
import { cloneDeep, debounce } from "lodash";
import { CELL_TYPE } from "~/const/common";
import { CANDIDATE_STATUS_OPTIONS } from "~/const/views/org/candidates";
import {
  candidateTableHeaders,
  pageSizeOptions,
} from "~/const/views/org/job-ad";
import type { TSort } from "~/types/common";

type TProps = {
  jobAdProcessId: any;
  isOnboard: boolean;
};

const props = defineProps<TProps>();

const { getJobAdCandidateByProcess } = useJobAdApi();
const { getLevels } = useLevelApi();
const router = useRouter();

const isLoading = ref<boolean>(false);
const tableData = ref<any>([]);
const isNoData = ref<boolean>(false);
const totalItems = ref<number>(0);
const filter = ref<any>({});
const controller = ref<AbortController | null>(null);
const levelList = ref<any>([]);

onBeforeMount(() => {
  fetchLevel({});
});

const selectOptions = computed(() => {
  return {
    candidateStatus: CANDIDATE_STATUS_OPTIONS,
    level: levelList.value.map((level: any) => ({
      label: level.name,
      value: level.id,
    })),
  };
});

const tableColumns = computed(() => {
  if (props.isOnboard) {
    return [
      ...candidateTableHeaders,
      {
        accessorKey: "onboardDate",
        header: "Ngày onboard",
        isSortable: true,
        allowFilter: true,
        filterType: "date",
        meta: {
          class: {
            th: "min-w-[248px] max-w-[248px] truncate",
            td: "max-w-[248px] truncate",
          },
        },
      },
    ];
  }
  return candidateTableHeaders;
});

const pageSizeOpts = computed(() => {
  return pageSizeOptions;
});

const pageSize = computed(() => {
  return filter.value.pageSize ? +filter.value.pageSize : 10;
});

const pageIndex = computed(() => {
  return !isNaN(filter.value.pageIndex) ? +filter.value.pageIndex + 1 : 1;
});

const sort = computed(() => {
  return {
    key: filter.value.sortBy,
    type: filter.value.sortDirection ? filter.value.sortDirection : undefined,
  };
});

const debouncedFetchData = debounce(fetchData, 400);

const normalizeFilter = (filter: any) => {
  const normalizedFilter = cloneDeep(filter);
  if (normalizedFilter.sortBy == 'level') {
    normalizedFilter.sortBy = 'levelName';
  }
  if (normalizedFilter.applyDate) {
    const startDate = normalizedFilter.applyDate[0];
    const endDate = normalizedFilter.applyDate[1];
    delete normalizedFilter.applyDate;
    if (startDate) {
      normalizedFilter.applyDateStart = toUtcDate(startDate);
    }
    if (endDate) {
      normalizedFilter.applyDateEnd = toUtcDate(endDate);
    }
  }
  if (normalizedFilter.onboardDate) {
    const startDate = normalizedFilter.onboardDate[0];
    const endDate = normalizedFilter.onboardDate[1];
    delete normalizedFilter.onboardDate;
    if (startDate) {
      normalizedFilter.onboardDateStart = toUtcDate(startDate);
    }
    if (endDate) {
      normalizedFilter.onboardDateEnd = toUtcDate(endDate);
    }
  }

  if (
    normalizedFilter.candidateStatus &&
    normalizedFilter.candidateStatus.length
  ) {
    normalizedFilter.candidateStatuses = normalizedFilter.candidateStatus.map(
      (status: any) => status.value,
    );
    delete normalizedFilter.candidateStatus;
  }

  if (normalizedFilter.level && normalizedFilter.level.length) {
    normalizedFilter.levelIds = normalizedFilter.level.map(
      (level: any) => level.value,
    );
    delete normalizedFilter.level;
  }

  const queryForUrl: Record<string, any> = {
    ...normalizedFilter,
  };

  return queryForUrl;
};

async function fetchLevel(params: any, controller?: AbortController) {
  // const ids = formInput.value.department.value;
  const newParams = {
    pageSize: 100,
    // departmentIds: ids,
  };
  const res = await getLevels(newParams, controller);
  if (!res) {
    return null;
  }
  const nextPage = res.data.data;
  levelList.value = [...levelList.value, ...nextPage];
}

async function fetchData() {
  if (controller.value) {
    controller.value.abort();
  }

  controller.value = new AbortController();
  isLoading.value = true;
  const queryForUrl = normalizeFilter(filter.value);

  const query = {
    ...truncateQueryObject(queryForUrl),
  };

  const res = await getJobAdCandidateByProcess(
    props.jobAdProcessId,
    controller.value,
    query,
  );
  if (res.data.data.length == 0) {
    isNoData.value = true;
  } else {
    isNoData.value = false;
  }
  if (res === null) {
    return;
  }
  isLoading.value = false;
  const data = res.data.data;
  totalItems.value = res.data.pageInfo.totalElements;

  for (const [index, entry] of data.entries()) {
    entry.index = index + 1 + (pageIndex.value - 1) * pageSize.value;
    entry.canDelete = false;
    entry.candidateStatus = {
      text: entry.candidateStatus.label,
      key: entry.candidateStatus.name,
      cellType: CELL_TYPE.TAG,
    };
    entry.level = entry.candidateSummaryOrg.level.levelName;
    entry.applyDate = formatDateTime(entry.applyDate, "DD/MM/YYYY HH:mm");
    if (entry.onboardDate) {
      entry.onboardDate = formatDateTime(entry.onboardDate, "DD/MM/YYYY HH:mm");
    }
    entry.canDelete = true;
  }
  tableData.value = data;
}

const handleSort = (e: TSort) => {
  filter.value = {
    ...filter.value,
    sortBy: e.type ? e.key : undefined,
    sortDirection: e.type ? e.type : undefined,
  };
};
const handleFilter = (e: any) => {
  filter.value = e;
};

const handlePageSizeChange = (e: any) => {
  filter.value = {
    ...filter.value,
    pageIndex: 0,
    pageSize: e,
  };
};

const handlePageIndexChange = (e: any) => {
  filter.value = {
    ...filter.value,
    pageIndex: e - 1,
  };
};

const handleTableActionClick = (id: number, action: any) => {
  if (action === "view") {
    const link = router.resolve({path: `/org/candidate/detail/${id}`});
    window.open(link.href, "_blank");
    console.log(id);
    // Route to different page
  }
};

watch(
  () => props.jobAdProcessId,
  async (newId) => {
    if (newId == null) {
      return;
    }
    fetchData();
  },
  {
    immediate: true,
  },
);

watch(filter, (newVal) => {
  debouncedFetchData();
});
</script>
<style lang="scss" scoped>
.table-wrapper {
  .top-section {
    margin-top: 18px;
    display: flex;
    flex-direction: row;
    gap: 8px;
    justify-content: flex-end;

    :deep(button[type="button"][disabled]) {
      color: $color-gray-400;
    }
  }
  .table-content {
    max-width: 100%;
  }
}
</style>
