<template>
  <div class="wrapper">
    <OrgAdminOrgMemberInviteMemberModal
      v-model="isCreateModalOpen"
      @submit="handleCreated"
    />
    <OrgAdminOrgMemberEditViewModal
      v-model="isEditViewOpen"
      :initial-mode="editViewInitialMode"
      :target-id="editViewId || -1"
      :allow-edit="canEdit"
      @submit="handleUpdated"
      @mode-change="handleSwitchEditViewMode($event)"
    />
    <div class="job-ad-candidate-content">
      <div class="title">Danh sách ứng viên</div>
      <div class="table-top">
        <div :title="'Mở rộng'" class="expand-btn" @click="expandAll">
          <Icon name="material-symbols:expand-all" />
        </div>
        <div :title="'Thu gọn'" class="collapse-btn" @click="collapseAll">
          <Icon name="material-symbols:collapse-all" />
        </div>
        <div :title="'Trò chuyện'" class="collapse-btn" @click="collapseAll">
          <Icon name="material-symbols-light:chat-rounded" />
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
      <div class="content-wrapper">
        <div class="card-list">
          <OrgCandidateCard
            v-for="data of tableData"
            :key="data.candidateInfo.id"
            :ref="setChildRef"
            :candidate-data="data as TJobAdCandidate"
          />
          <AppNoData v-if="isNoData" />
        </div>
        <div v-show="isFilterShow" class="filter-col">
          <OrgCandidateFilter
            :filter-data="filter"
            @filter-change="handleFilter"
            @sort-change="handleSort"
          />
        </div>
      </div>
      <div class="top-section">
        <div class="record-count">{{ `${totalItems} bản ghi` }}</div>
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
  </div>
</template>
<script setup lang="ts">
import type { TTableAction } from "~/components/app/table/data-table.vue";
import type { TSort } from "~/types/common";
import { cloneDeep, debounce } from "lodash";
import { CELL_TYPE, CHIP_TYPE } from "~/const/common";
import {
  orgMemberTableHeaders,
  pageSizeOptions,
} from "~/const/views/org-admin/org-member";
import { candidateTableHeaders } from "~/const/views/org/candidates";
import type { TCandidateFilter, TJobAdCandidate } from "~/types/candidate";
import { POSITIVE_INT_REGEX } from "~/const/validation";

definePageMeta({
  layout: "org",
});
useHead({
  title: "Danh sách ứng viên",
});

const route = useRoute();
const router = useRouter();
const isFilterShow = ref<boolean>(true);
const isCreateModalOpen = ref<boolean>(false);
const isDeleteModalOpen = ref<boolean>(false);
const isEditViewOpen = ref<boolean>(false);
const editViewId = ref<number | null>(null);
const editViewInitialMode = ref<any>(null);
const editViewMode = ref<any>(null);
const isFetchingData = ref<boolean>(false);
const fetchJobAdCandidateController = ref<AbortController | null>();
const filter = ref<TCandidateFilter>({});
const totalItems = ref<number>(0);
const isNoData = ref<boolean>(false);
const isDeleting = ref<boolean>(false);
const deleteList = ref<any[]>([]);
const rolesFilterOptions = ref<any[]>([]);
const allowActions = computed(() => {
  const url = route.path;
  const menuItem = getMenuItem(url);
  const permissions = Array.from(menuItem?.permissions || []);
  return permissions;
});

const canEdit = computed(() => {
  if (allowActions.value.includes("UPDATE")) {
    return true;
  } else {
    return false;
  }
});

const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);
const { logout } = useAuth();

const { getMenuItem } = useSidebarStore();
const { setLoading } = useLoadingStore();
// TODO: REPLACE THIS APIS
const { getDepartments, deleteDepartment, changeDepartmentStatus } =
  useDepartmentApi();
const { getOrgMembers, getRoleFilterOption, changeOrgMemberStatus } =
  useOrgMemberApi();
const { getJobAdCandidates } = useCandidateApi();

const childRefs = ref<any[]>([]);

function setChildRef(el: any) {
  if (el) childRefs.value.push(el);
  else childRefs.value = [];
}

function expandAll() {
  childRefs.value.forEach((child) => {
    child.expand();
  });
}

function collapseAll() {
  childRefs.value.forEach((child) => {
    child.close();
  });
}

// NOTE: From query string to filter
const convertQuery = () => {
  const _query = route.query;
  let restoredFilter: Record<string, any> = {};

  const { mode, targetId, ...query } = _query;

  restoredFilter = {
    ...restoredFilter,
    ...query,
  };

  const levelIds = (query.levelIds as string)?.split(",") || [];
  if (levelIds && levelIds.length) {
    restoredFilter.levels = levelIds.map((id) => ({
      value: +id,
    }));
  }

  const candidateStatuses =
    (query.candidateStatuses as string)?.split(",") || [];
  if (candidateStatuses && candidateStatuses.length) {
    restoredFilter.candidateStatusesOpt = candidateStatuses.map((status) => ({
      value: status,
    }));
  }

  const processTypes = (query.processTypes as string)?.split(",") || [];
  if (processTypes && processTypes.length) {
    restoredFilter.processTypesOpt = processTypes.map((process) => ({
      value: +process,
    }));
  }

  const hrContactId = query.hrContactId as string;
  if (hrContactId) {
    restoredFilter.hrContact = {
      value: hrContactId,
    };
  }

  const applyDates: (Date | null)[] = [];
  if (query.applyDateStart) {
    const start = new Date(query.applyDateStart as string);
    if (!isNaN(start.getTime())) {
      applyDates.push(start);
    } else {
      applyDates.push(null);
    }
  }
  if (query.applyDateEnd) {
    const end = new Date(query.applyDateEnd as string);
    if (!isNaN(end.getTime())) {
      applyDates.push(end);
    } else {
      applyDates.push(null);
    }
  }
  if (applyDates.length) {
    restoredFilter.applyDateStart = applyDates[0];
    restoredFilter.applyDateEnd = applyDates[1];
  }

  return restoredFilter;
};

onBeforeMount(async () => {
  const rolesRes = await getRoleFilterOption();
  rolesFilterOptions.value = rolesRes.data;

  filter.value = convertQuery();

  console.log(rolesRes.data);
});

const handleCreated = () => {
  isCreateModalOpen.value = false;
  fetchData();
};

const handleUpdated = () => {
  isEditViewOpen.value = false;
  fetchData();
};

const handleSwitchEditViewMode = (mode: any) => {
  editViewMode.value = mode;
};

const handleDeleteClick = (items: any[]) => {
  deleteList.value = items;
  isDeleteModalOpen.value = true;
};

const clearDeleteList = () => {
  deleteList.value = [];
};

const clearViewEditId = () => {
  editViewId.value = null;
  editViewInitialMode.value = null;
  editViewMode.value = null;
};

const handleDeleteModalOpenUpdate = (event: boolean) => {
  if (!event) {
    isDeleteModalOpen.value = false;
  }
};

const handleDelete = async () => {
  isDeleting.value = true;
  // TODO: REPLACE THIS API
  const isSuccess = await deleteDepartment({ ids: deleteList.value });
  selectedRows.value = selectedRows.value.filter(
    (selected) => !deleteList.value.includes(selected),
  );
  isDeleting.value = false;
  if (isSuccess) {
    selectedRows.value = [];
    handleDeleteModalOpenUpdate(false);
    fetchData();
  }
};

const handleAddNew = () => {
  isCreateModalOpen.value = true;
};

const deleteListNames = computed(() => {
  return tableData.value
    .filter((data: any) => deleteList.value.includes(data.id))
    .map((data: any) => data.name);
});

const isDeleteAllDisabled = computed(() => {
  const selectedRowsId = selectedRows.value;
  if (selectedRowsId.length == 0) {
    return true;
  }
  const rowData: any[] = [];
  for (const row of tableData.value) {
    if (selectedRowsId.includes((row as any).id)) {
      rowData.push(row);
    }
  }
  return rowData.some((row) => !row.canDelete);
});
// const sort = computed(() => {
//   return {
//     key: filter.value.sortBy,
//     type: filter.value.sortDirection ? filter.value.sortDirection : undefined,
//   };
// });

const pageIndex = computed(() => {
  if (!filter.value.pageIndex) {
    return 1;
  }
  return !isNaN(filter.value.pageIndex) ? +filter.value.pageIndex + 1 : 1;
});

const pageSize = computed(() => {
  return filter.value.pageSize ? +filter.value.pageSize : 10;
});

const handleSort = (e: TSort) => {
  filter.value = {
    ...filter.value,
    sortBy: e.type ? e.key : undefined,
    sortDirection: e.type ? e.type : undefined,
  };
  console.log("changed sort", filter.value);
};
const handleFilter = (e: any) => {
  console.log("filter change emited");
  filter.value = e;
};

const fetchData = async () => {
  console.log("wtf why does it fetch");
  if (fetchJobAdCandidateController.value) {
    fetchJobAdCandidateController.value.abort();
  }

  fetchJobAdCandidateController.value = new AbortController();
  isFetchingData.value = true;
  const query = route.query;
  setLoading(true);
  const res = await getJobAdCandidates(
    query,
    fetchJobAdCandidateController.value,
  );
  setLoading(false);
  if (res.data.data.length == 0) {
    isNoData.value = true;
  } else {
    isNoData.value = false;
  }
  if (res === null) {
    return;
  }
  isFetchingData.value = false;
  const data = res.data.data;
  totalItems.value = res.data.pageInfo.totalElements;

  tableData.value = data;
};
const debouncedFetchData = debounce(fetchData, 0);
const selectedRows = ref<number[]>([]);
const handleSelectionsUpdate = (selectionList: number[]) => {
  console.log(selectionList);
  selectedRows.value = selectionList;
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

const handleActiveToggle = async (ids: number[], state: boolean) => {
  const payload = {
    ids,
    active: state,
  };

  setLoading(true);
  const res = await changeOrgMemberStatus(payload);
  if (res) {
    selectedRows.value = [];
    if (ids.includes(userInfo.value?.id)) {
      await logout();
    }
    fetchData();
  }
  setLoading(false);
};

const handleTableActionClick = (id: number, action: TTableAction) => {
  if (action === "delete") {
    handleDeleteClick([id]);
  }
  if (action === "view") {
    editViewId.value = id;
    editViewInitialMode.value = "view";
    editViewMode.value = "view";
    isEditViewOpen.value = true;
  }
  if (action === "edit") {
    editViewId.value = id;
    editViewInitialMode.value = "edit";
    editViewMode.value = "edit";
    isEditViewOpen.value = true;
  }
};

const tableData = ref<Record<string, any>[]>([]);
const filterSelectOption = computed(() => {
  return {
    isActive: [
      {
        label: "Ngừng hoạt động",
        value: false,
      },
      {
        label: "Đang hoạt động",
        value: true,
      },
    ],
    isEmailVerified: [
      {
        label: "Đã xác thực",
        value: false,
      },
      {
        label: "Chưa xác thực",
        value: true,
      },
    ],
    roleIds: rolesFilterOptions.value.map((role) => ({
      label: role.name,
      value: role.id,
    })),
  };
});

const tableColumns = computed(() => {
  return candidateTableHeaders;
});
const pageSizeOpts = computed(() => {
  return pageSizeOptions;
});

// NOTE: From filter to query string
const normalizeFilter = (filter: TCandidateFilter) => {
  const normalizedFilter = cloneDeep(filter);

  if (filter.levels?.length) {
    console.log(filter.levels);
    normalizedFilter.levelIds = filter.levels
      .map((id) => id.value as number)
      .join(",");
    console.log(normalizedFilter.levelIds);
    delete normalizedFilter.levels;
  }

  if (filter.candidateStatusesOpt?.length) {
    normalizedFilter.candidateStatuses = filter.candidateStatusesOpt
      .map((id) => id.value as string)
      .join(",");
    delete normalizedFilter.candidateStatusesOpt;
  }

  if (filter.processTypesOpt?.length) {
    normalizedFilter.processTypes = filter.processTypesOpt
      .map((id) => id.value as number)
      .join(",");
    delete normalizedFilter.processTypesOpt;
  }

  if (filter.hrContact) {
    normalizedFilter.hrContactId = filter.hrContact.value;
    delete normalizedFilter.hrContact;
  }

  if (!POSITIVE_INT_REGEX.test(String(filter.numOfApplyStart))) {
    delete normalizedFilter.numOfApplyStart;
  }

  if (!POSITIVE_INT_REGEX.test(String(filter.numOfApplyEnd))) {
    delete normalizedFilter.numOfApplyEnd;
  }

  if (filter.applyDateStart) {
    normalizedFilter.applyDateStart = toUtcDate(filter.applyDateStart);
  }

  if (filter.applyDateEnd) {
    normalizedFilter.applyDateEnd = toUtcDate(filter.applyDateEnd);
  }

  const queryForUrl: Record<string, any> = {
    ...normalizedFilter,
  };

  return queryForUrl;
};

watch(
  filter,
  async (newVal) => {
    console.log("new filter", newVal);

    const queryForUrl = normalizeFilter(newVal);

    await router.replace({
      query: {
        ...truncateQueryObject(queryForUrl),
      },
    });
    console.log("about to fetch with ", queryForUrl);
    debouncedFetchData();
  },
  { deep: true },
);

watch([editViewMode, editViewId], ([newMode, newId]) => {
  const query = { ...route.query };

  if (newMode == null || newMode === "") {
    delete query.mode;
  } else {
    query.mode = String(newMode);
  }

  if (newId == null || newId === -1) {
    delete query.targetId;
  } else {
    query.targetId = String(newId);
  }

  router.replace({ query });
});

watch(isEditViewOpen, (newVal) => {
  if (!newVal) {
    clearViewEditId();
  }
});
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
.job-ad-candidate-content {
  background-color: white;
  min-height: calc(100% - 48px - 8px);
  @include box-shadow;
  color: $text-light;
  padding: 20px;
  display: flex;
  flex-direction: column;
  height: 100%;

  .content-wrapper {
    flex: 1;
    min-height: 0;
    display: flex;
    flex-direction: row;
    gap: 12px;

    .filter-col {
      min-width: 280px;
      max-width: 280px;
    }

    .card-list {
      display: flex;
      flex-direction: column;
      gap: 8px;
      flex: 1;
      overflow-y: auto;
      overflow-x: hidden;
      max-height: 100%;
      @include custom-scrollbar;
    }
  }

  .table-top {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: flex-end;
    gap: 12px;
    margin-bottom: 20px;
    align-items: center;

    .filter-btn,
    .expand-btn,
    .collapse-btn {
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

    .button {
      padding: 4px 12px 4px 12px;

      :deep(.button-text) {
        font-size: 14px;
      }
    }

    .toggle-job-ads {
      background-color: $color-primary-500;
      color: $text-dark;
      border-radius: 6px;
      max-height: fit-content;
    }

    .add-button {
      background-color: $color-primary-400;
      color: $text-dark;
    }

    .active-btn {
      background-color: white;
      padding: 4px 14px 4px 14px;

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

    .delete-button {
      background-color: white;
      color: $color-primary-400;
      border: 1px solid $color-primary-400;

      &.disabled {
        border: 1px solid $color-gray-400;
        color: $color-gray-400;
      }
    }
  }

  .title {
    font-weight: 700;
    font-size: 16px;
    line-height: 20px;
    margin-bottom: 12px;
  }
  .top-section {
    margin-top: 18px;
    display: flex;
    align-items: center;
    flex-direction: row;
    gap: 8px;
    justify-content: flex-end;

    :deep(button[type="button"][disabled]) {
      color: $color-gray-400;
    }

    .record-count {
      color: $color-gray-500;
      font-size: 14px;
      font-style: italic;
    }
  }
  .table-section {
    max-width: 100%;
  }
}
</style>
