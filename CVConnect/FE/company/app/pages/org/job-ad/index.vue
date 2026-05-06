<template>
  <div class="wrapper">
    <div class="job-ad-content">
      <div class="top">
        <div class="left">
          <div class="title">
            Tin tuyển dụng
            <span class="count">{{ `Tổng số: ${totalElements} tin` }}</span>
          </div>
        </div>
        <div class="right">
          <AppButton
            v-if="allowActions.includes('ADD')"
            :text="'Tạo mới'"
            class="submit-btn"
            @click="handleCreate"
          />
        </div>
      </div>
      <div class="filter">
        <AppInputText
          :label="''"
          :required="false"
          :error="''"
          :placeholder="'Tìm kiếm'"
          :value="filter.keyword ?? ''"
          :slim-error="true"
          class="search-bar"
          @input="handleInputDebounce('keyword', $event)"
        >
          <template #input-icon>
            <Icon name="material-symbols:search-rounded" class="mag-icon" />
          </template>
        </AppInputText>
        <AppInputSearchSelect
          class="job-ad-status-select"
          :label="''"
          :required="true"
          :options="jobAdStatusOpts"
          :value="filter.jobAdStatus"
          :error="''"
          :slim-error="true"
          :placeholder="'Trạng thái tin'"
          :remote-filter="false"
          :allow-clear="true"
          :multiple="false"
          :fetch-fn="null"
          @input="handleInput('jobAdStatus', $event)"
          @clear-value="filter.jobAdStatus = undefined"
        />
        <AppInputSearchSelect
          class="job-ad-status-select"
          :label="''"
          :required="true"
          :options="sortOpts"
          :value="currentSort"
          :error="''"
          :slim-error="true"
          :placeholder="'Sắp xếp theo'"
          :remote-filter="false"
          :allow-clear="true"
          :multiple="false"
          :fetch-fn="fetchJobAdStatus"
          @input="handleSort($event)"
          @clear-value="handleSort(undefined)"
        />
        <div class="sort-btn" @click="handleSortDirection">
          <Icon :name="sortIcon" />
        </div>
        <div
          :title="'Lọc ứng viên'"
          class="filter-btn"
          @click="isFilterShow = !isFilterShow"
        >
          <Icon
            :name="
              isFilterShow
                ? 'material-symbols:filter-alt'
                : 'material-symbols:filter-alt-outline'
            "
          />
        </div>
      </div>
      <div class="body">
        <div class="content">
          <AppNoData v-if="isNoData" />
          <OrgAdJobCard
            v-for="jobAd of jobAdList"
            :key="jobAd.id"
            :data="jobAd"
            :job-ad-status="jobAdStatusOpts"
          />
          <div
            v-if="!isLoading && hasMore && jobAdList.length"
            class="show-more"
            @click="handleShowMore"
          >
            Hiển thị thêm
          </div>
          <div v-if="isLoading" class="spinner">
            <AppSpinnerHalfCircle />
          </div>
        </div>
        <div v-show="isFilterShow" class="filter-tab">
          <OrgAdJobFilter
            :filter-data="filter"
            :departments-opts="departmentsOpts"
            :is-public-opts="isPublicOpts"
            :hr-options="hrOptions"
            @filter-change="handleFilterChange"
          />
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { debounce } from "lodash";

definePageMeta({
  layout: "org",
});
useHead({
  title: "Tin tuyển dụng",
});

const router = useRouter();
const route = useRoute();
const { getMenuItem } = useSidebarStore();
const { getJobAdStatus } = useEnumApi();
const { getJobAdOrg } = useJobAdApi();
const { getByRoleCode } = useUserApi();
const { getDepartments } = useDepartmentApi();

const filter = ref<any>({
  keyword: "",
  jobAdStatus: undefined,
  isPublic: undefined,
  departmentIds: [],
  hrContactId: undefined,
  createdBy: "",
  createdAtStart: undefined,
  createdAtEnd: undefined,
  dueDateStart: undefined,
  dueDateEnd: undefined,
  sortBy: undefined,
  sortDirection: undefined,
  pageIndex: 0,
  pageSize: 10,
});
const isFilterShow = ref<boolean>(false);
const jobAdStatusList = ref<any[]>([]);
const currentSort = ref<any>(undefined);
const abortController = ref<AbortController | null>(null);
const isLoading = ref<boolean>(false);
const hrList = ref<Record<string, any>[]>([]);
const departmentList = ref<any[]>([]);
const totalElements = ref<any>(0);
const jobAdList = ref<any>([]);
const isNoData = ref<boolean>(false);
const hasMore = ref<boolean>(true);

onBeforeMount(async () => {
  const q = route.query;

  await Promise.all([
    fetchJobAdStatus(),
    fetchHr({ pageSize: 100 }),
    fetchDepartments({ pageSize: 100 }),
  ]);

  const newFilter = convertQueryToFilter(q);
  if (newFilter) {
    filter.value = newFilter;
  }
});

const isPublicOpts = computed(() => {
  return [
    {
      label: "Công khai",
      value: true,
    },
    {
      label: "Nội bộ",
      value: false,
    },
  ];
});

const hrOptions = computed(() => {
  return hrList.value.map((hr) => ({
    label: hr.fullName,
    value: hr.id,
  }));
});

const departmentsOpts = computed(() => {
  return departmentList.value.map((dept) => ({
    label: dept.name,
    value: dept.id,
  }));
});

const allowActions = computed(() => {
  const url = route.path;
  const menuItem = getMenuItem(url);
  const permissions = Array.from(menuItem?.permissions || []);
  return permissions;
});

const jobAdStatusOpts = computed(() => {
  return jobAdStatusList.value.map((status) => ({
    label: status.description,
    value: status.name,
  }));
});

const sortOpts = computed(() => {
  return [
    {
      label: "Ngày tạo",
      value: "createdBy",
    },
    {
      label: "Hạn nộp hồ sơ",
      value: "dueDate",
    },
    {
      label: "Tiêu đề",
      value: "title",
    },
  ];
});

const sortIcon = computed(() => {
  if (filter.value.sortDirection === "ASC") {
    return "mdi:sort-ascending";
  } else if (filter.value.sortDirection === "DESC") {
    return "mdi:sort-descending";
  } else {
    return "mdi:sort";
  }
});

async function fetchHr(params: any, controller?: AbortController) {
  const res = await getByRoleCode("HR");
  if (!res) {
    return null;
  }

  hrList.value = res.data;

  return res.data;
}

async function fetchDepartments(params: any, controller?: AbortController) {
  const res = await getDepartments(params, controller);
  if (!res) {
    return null;
  }
  const nextPage = res.data.data;
  departmentList.value = [...departmentList.value, ...nextPage];
  return res.data.data;
}

async function fetchJobAdStatus() {
  const res = await getJobAdStatus();
  jobAdStatusList.value = res.data;

  return res.data;
}

function handleFilterChange(_filter: any) {
  filter.value = _filter;
}

function handleSort(sort: any) {
  currentSort.value = sort;
  if (!currentSort.value) {
    filter.value.sortBy = undefined;
    filter.value.sortDirection = undefined;
    return;
  }
  filter.value.sortBy = currentSort.value.value;
}

function handleInput(key: string, value: any) {
  filter.value[key] = value;
}

const debounced = debounce((key: string, value: any) => {
  filter.value[key] = value;
}, 300);

function handleInputDebounce(key: string, value: any) {
  debounced(key, value);
}

const handleCreate = () => {
  router.push({ path: "/org/job-ad/create" });
};

function convertQueryToFilter(q: any) {
  const f: Record<string, any> = {};

  if (q.keyword) {
    f.keyword = String(q.keyword);
  }

  if (q.jobAdStatus) {
    const jobAdStatus = jobAdStatusOpts.value.find(
      (status) => status.value == q.jobAdStatus,
    );
    f.jobAdStatus = jobAdStatus;
  }

  if (q.isPublic !== undefined) {
    const m = isPublicOpts.value.find((opt) => opt.value === q.isPublic);
    f.isPublic = m;
  }

  if (q.departmentIds) {
    const splitted = String(q.departmentIds).split(",");

    if (Array.isArray(splitted)) {
      const mapped = splitted
        .map((item: any) =>
          departmentsOpts.value.find((opt) => opt.value === item.value),
        )
        .filter(Boolean);

      f.departmentIds = mapped;
    }
  }

  if (f.hrContactId?.value !== undefined) {
    const m = hrOptions.value.find((opt) => opt.value === q.hrContactId);
    f.hrContactId = m;
  }

  if (q.createdBy) {
    f.createdBy = String(q.createdBy);
  }

  if (q.createdAtStart) {
    f.createdAtStart = q.createdAtStart;
  }

  if (q.createdAtEnd) {
    f.createdAtEnd = q.createdAtEnd;
  }

  if (q.dueDateStart) {
    f.dueDateStart = q.dueDateStart;
  }

  if (q.dueDateEnd) {
    f.dueDateEnd = q.dueDateEnd;
  }

  if (q.sortBy) {
    f.sortBy = q.sortBy;
    const sort = sortOpts.value.find((s) => s.value == f.sortBy);
    currentSort.value = sort;
  }

  if (q.sortDirection) {
    f.sortDirection = q.sortDirection;
  }

  f.pageIndex = q.pageIndex ? Number(q.pageIndex) : 0;
  f.pageSize = q.pageSize ? Number(q.pageSize) : 10;

  return f;
}

function convertFilterToQuery(f: any) {
  const q: Record<string, any> = {};

  if (f.keyword?.trim()) {
    q.keyword = f.keyword.trim();
  }
  if (f.jobAdStatus) {
    q.jobAdStatus = f.jobAdStatus.value;
  }
  if (f.isPublic != undefined || f.isPublic != null) {
    q.isPublic = f.isPublic.value;
  }
  if (f.departmentIds?.length) {
    q.departmentIds = f.departmentIds.map((dept: any) => dept.value).join(",");
  }
  if (f.hrContactId) {
    q.hrContactId = f.hrContactId.value;
  }
  if (f.createdBy?.trim()) {
    q.createdBy = f.createdBy.trim();
  }
  if (f.createdAtStart) {
    q.createdAtStart = toDateStart(f.createdAtStart);
  }
  if (f.createdAtEnd) {
    q.createdAtEnd = toDateEnd(f.createdAtEnd);
  }
  if (f.dueDateStart) {
    q.dueDateStart = toDateStart(f.dueDateStart);
  }
  if (f.dueDateEnd) {
    q.dueDateEnd = toDateEnd(f.dueDateEnd);
  }
  if (f.sortBy) {
    q.sortBy = f.sortBy;
  }
  if (f.sortDirection) {
    q.sortDirection = f.sortDirection;
  }
  q.pageIndex = f.pageIndex;
  q.pageSize = f.pageSize;

  return q;
}

function syncQueryToRoute(query: any) {
  router.replace({
    query,
  });
}

function handleSortDirection() {
  if (filter.value.sortDirection === "ASC") {
    filter.value.sortDirection = "DESC";
  } else if (filter.value.sortDirection === "DESC") {
    filter.value.sortDirection = undefined;
  } else {
    filter.value.sortDirection = "ASC";
  }
}

async function fetchData(params: Record<string, any>) {
  if (abortController.value) {
    abortController.value.abort();
  }
  abortController.value = new AbortController();
  isLoading.value = true;

  if (params.createdAtStart) {
    params.createdAtStart = toUtcDateStart(params.createdAtStart);
  }
  if (params.createdAtEnd) {
    params.createdAtEnd = toUtcDateEnd(params.createdAtEnd);
  }

  if (params.dueDateStart) {
    params.dueDateStart = toUtcDateStart(params.dueDateStart);
  }
  if (params.dueDateEnd) {
    params.dueDateEnd = toUtcDateEnd(params.dueDateEnd);
  }

  const res = await getJobAdOrg(params, abortController.value);
  totalElements.value = res.data.pageInfo.totalElements;
  if (res.data.pageInfo.totalElements == 0) {
    isNoData.value = true;
  } else {
    isNoData.value = false;
  }
  jobAdList.value = [...jobAdList.value, ...res.data.data];
  if (jobAdList.value.length >= totalElements.value) {
    hasMore.value = false;
  } else {
    hasMore.value = true;
  }
  if (res != "aborted") {
    isLoading.value = false;
  }
}

function handleShowMore() {
  filter.value = { ...filter.value, pageIndex: filter.value.pageIndex + 1 };
}

watch(
  filter,
  (newVal, oldVal) => {
    if (newVal.pageIndex == oldVal.pageIndex) {
      // other filter changed, not paging

      console.log("filter change");
      if (filter.value.pageIndex != 0) {
        filter.value.pageIndex = 0;
        jobAdList.value = [];
        console.log("cleared", jobAdList.value);
        return;
      } else {
        jobAdList.value = [];
        console.log("cleared", jobAdList.value);
      }
    }

    const query = convertFilterToQuery(newVal);
    syncQueryToRoute(query);
    fetchData(query);
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.wrapper {
  overflow: hidden;
  min-height: 0;
  flex: 1;
  border-radius: 8px;
  margin-top: 8px;
  @include box-shadow;
}
.job-ad-content {
  background-color: white;
  min-height: calc(100% - 48px - 8px);
  @include box-shadow;
  color: $text-light;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  height: 100%;
}

.top {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 16px;
  row-gap: 8px;
  flex-wrap: wrap;

  .left {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;

    .title {
      font-weight: 700;
      font-size: 16px;
      line-height: 20px;

      .count {
        font-weight: 400;
        font-size: 13px;
        line-height: 20px;
        font-style: italic;
        color: $color-gray-400;
        margin-left: 12px;
      }
    }
  }

  .right {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;

    .submit-btn {
      background-color: $color-primary-400;
      border: 1px $color-primary-400;
      color: $text-dark;
      padding: 4px 6px;
      font-size: 14px;
      min-width: 84px;
    }
  }
}

.filter {
  display: flex;
  flex-direction: row;
  gap: 12px;
  align-items: center;
  flex-wrap: wrap;

  .right {
    display: flex;
    flex-direction: row;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;
  }

  .filter-btn,
  .sort-btn {
    background-color: $color-gray-100;
    border-radius: 999px;
    cursor: pointer;
    height: 36px;
    width: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: $color-primary-500;
    .iconify {
      display: block;
      font-size: 20px;
    }
  }

  .search-bar {
    width: 360px;
    :deep(.input) {
      padding: 6px 8px;
      input {
        font-size: 14px;
      }
    }
  }

  .job-ad-status-select {
    max-width: 180px;
    width: 180px;
    min-width: 180px;
  }
}

.body {
  display: flex;
  flex-direction: row;
  gap: 8px;
  flex: 1;
  min-height: 0;

  .content {
    max-height: 100%;
    overflow-y: auto;
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    padding: 8px;
    .spinner {
      height: 120px;
      width: 100%;
      font-size: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .show-more {
      color: $color-primary-500;
      text-decoration: underline;
      cursor: pointer;
      width: fit-content;
      font-size: 14px;
      margin-top: 12px;
    }
  }

  .filter-tab {
    width: min(30%, 280px);
  }
}

.mag-icon {
  display: block;
  font-size: 14px;
  height: 20px;
  width: 20px;
  color: $color-gray-400;
}
</style>
