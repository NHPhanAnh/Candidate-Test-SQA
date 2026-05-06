<template>
  <div class="wrapper">
    <DepartmentCreateModal
      v-model="isCreateModalOpen"
      @submit="handleCreated"
    />
    <DepartmentEditViewModal
      v-model="isEditViewOpen"
      :initial-mode="editViewInitialMode"
      :target-id="editViewId || -1"
      :allow-edit="canEdit"
      @submit="handleUpdated"
      @mode-change="handleSwitchEditViewMode($event)"
    />
    <div class="department-content">
      <div class="title">Danh mục phòng ban</div>
      <div class="table-top">
        <AppButton
          :text="'Hoạt động'"
          :is-disabled="selectedRows.length == 0"
          class="active-btn active"
          @click="handleActiveToggle(selectedRows, true)"
        >
        </AppButton>
        <AppButton
          :text="'Ngừng hoạt động'"
          :is-disabled="selectedRows.length == 0"
          class="active-btn deactive"
          @click="handleActiveToggle(selectedRows, false)"
        >
        </AppButton>
        <AppButton
          :text="'Xóa bỏ'"
          :is-disabled="isDeleteAllDisabled"
          class="delete-button"
          @click="handleDeleteClick(selectedRows)"
        >
          <template #icon>
            <Icon name="material-symbols:delete-outline-rounded" />
          </template>
        </AppButton>

        <UModal
          :open="isDeleteModalOpen"
          title="Xóa phòng ban"
          :ui="{ content: 'w-[600px] max-w-[600px]' }"
          @update:open="handleDeleteModalOpenUpdate"
          @after:leave="clearDeleteList"
        >
          <template #body>
            <ModalsDeleteConfirm :delete-list="deleteListNames">
              <template #footer>
                <AppButton
                  :text="'Đồng ý'"
                  class="modal-delete-submit"
                  :is-loading="isDeleting"
                  @click="handleDelete"
                />
              </template>
            </ModalsDeleteConfirm>
          </template>
        </UModal>

        <AppButton :text="'Thêm mới'" class="add-button" @click="handleAddNew">
          <template #icon>
            <Icon name="material-symbols:add-2-rounded" />
          </template>
        </AppButton>
      </div>
      <AppTableDataTable
        :table-data="tableData"
        :columns="tableColumns"
        :allow-actions="allowActions"
        :show-checkbox="true"
        :show-actions="true"
        :is-loading="isFetchingData"
        :selection-list="selectedRows"
        :select-options="filterSelectOption"
        :sort="sort"
        :filter="filter"
        :is-table-empty="isNoData"
        @selection-update="handleSelectionsUpdate"
        @delete="handleTableActionClick($event, 'delete')"
        @edit="handleTableActionClick($event, 'edit')"
        @view="handleTableActionClick($event, 'view')"
        @sort="handleSort"
        @filter="handleFilter"
      />
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
import {
  industryTableHeaders,
  pageSizeOptions,
} from "~/const/views/system-admin/industry";
import { departmentTableHeaders } from "~/const/views/org-admin/department";
import { CELL_TYPE, CHIP_TYPE } from "~/const/common";

definePageMeta({
  layout: "org-admin",
});
useHead({
  title: "Danh mục phòng ban",
});

const route = useRoute();
const router = useRouter();
const isCreateModalOpen = ref<boolean>(false);
const isDeleteModalOpen = ref<boolean>(false);
const isEditViewOpen = ref<boolean>(false);
const editViewId = ref<number | null>(null);
const editViewInitialMode = ref<any>(null);
const editViewMode = ref<any>(null);
const isFetchingData = ref<boolean>(false);
const fetchDepartmentController = ref<AbortController | null>();
const filter = ref<Record<string, any>>({});
const totalItems = ref<number>(0);
const isNoData = ref<boolean>(false);
const isDeleting = ref<boolean>(false);
const deleteList = ref<any[]>([]);
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

const { getMenuItem } = useSidebarStore();
const { setLoading } = useLoadingStore();
// TODO: REPLACE THIS APIS
const { getDepartments, deleteDepartment, changeDepartmentStatus } =
  useDepartmentApi();

// NOTE: From query string to filter
const convertQuery = () => {
  const _query = route.query;
  let restoredFilter: Record<string, any> = {};

  const { mode, targetId, ...query } = _query;

  restoredFilter = {
    ...restoredFilter,
    ...query,
  };

  // NOTE: Reopening modal
  if (mode && targetId) {
    restoredFilter = {
      ...restoredFilter,
      mode,
      targetId,
    };
    isEditViewOpen.value = true;
    editViewInitialMode.value = mode;
    editViewMode.value = mode;
    editViewId.value = +targetId;
  }

  const createdAt: (Date | null)[] = [];
  if (query.createdAtStart) {
    const start = new Date(query.createdAtStart as string);
    if (!isNaN(start.getTime())) {
      createdAt.push(start);
    } else {
      createdAt.push(null);
    }
  }
  if (query.createdAtEnd) {
    const end = new Date(query.createdAtEnd as string);
    if (!isNaN(end.getTime())) {
      createdAt.push(end);
    } else {
      createdAt.push(null);
    }
  }
  if (createdAt.length) {
    restoredFilter.createdAt = createdAt;
  }

  if (query.isActive) {
    const values = (query.isActive as string).split(",");
    console.log(values);
    restoredFilter.isActive = values.map((val) =>
      filterSelectOption.value.isActive.find((opt: any) => {
        const booleanValue = val == "true";
        return opt.value == booleanValue;
      }),
    );
    console.log(restoredFilter.isActive);
  }

  const updatedAt: (Date | null)[] = [];
  if (query.updatedAtStart) {
    const start = new Date(query.updatedAtStart as string);
    if (!isNaN(start.getTime())) {
      updatedAt.push(start);
    } else {
      updatedAt.push(null);
    }
  }
  if (query.updatedAtEnd) {
    const end = new Date(query.updatedAtEnd as string);
    if (!isNaN(end.getTime())) {
      updatedAt.push(end);
    } else {
      updatedAt.push(null);
    }
  }
  if (updatedAt.length) {
    restoredFilter.updatedAt = updatedAt;
  }

  delete restoredFilter.createdAtStart;
  delete restoredFilter.createdAtEnd;
  delete restoredFilter.updatedAtStart;
  delete restoredFilter.updatedAtEnd;

  return restoredFilter;
};

onBeforeMount(async () => {
  filter.value = convertQuery();
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
const sort = computed(() => {
  return {
    key: filter.value.sortBy,
    type: filter.value.sortDirection ? filter.value.sortDirection : undefined,
  };
});

const pageIndex = computed(() => {
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
};
const handleFilter = (e: any) => {
  filter.value = e;
};

const fetchData = async () => {
  if (fetchDepartmentController.value) {
    fetchDepartmentController.value.abort();
  }

  fetchDepartmentController.value = new AbortController();
  isFetchingData.value = true;
  const query = route.query;
  const res = await getDepartments(query, fetchDepartmentController.value);
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

  for (const [index, entry] of data.entries()) {
    entry.index = index + 1 + (pageIndex.value - 1) * pageSize.value;
    entry.createdAt = formatDateTime(entry.createdAt, "DD/MM/YYYY - HH:mm");
    entry.updatedAt = formatDateTime(entry.updatedAt, "DD/MM/YYYY - HH:mm");
    entry.isActive = entry.isActive
      ? {
          text: "Đang hoạt động",
          type: CHIP_TYPE.SUCCESS,
          cellType: CELL_TYPE.TAG,
        }
      : {
          text: "Ngừng hoạt động",
          type: CHIP_TYPE.ERROR,
          cellType: CELL_TYPE.TAG,
        };
    entry.canDelete = true;
  }
  tableData.value = data;
};
const debouncedFetchData = debounce(fetchData, 500);
const selectedRows = ref<number[]>([]);
const handleSelectionsUpdate = (selectionList: number[]) => {
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
  const res = await changeDepartmentStatus(payload);
  if (res) {
    selectedRows.value = [];
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

const tableData = ref([]);
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
  };
});

const tableColumns = computed(() => {
  return departmentTableHeaders;
});
const pageSizeOpts = computed(() => {
  return pageSizeOptions;
});

// NOTE: From filter to query string
const normalizeFilter = (filter: any) => {
  const normalizedFilter = cloneDeep(filter);
  if (normalizedFilter.createdAt) {
    const startDate = normalizedFilter.createdAt[0];
    const endDate = normalizedFilter.createdAt[1];
    delete normalizedFilter.createdAt;
    if (startDate) {
      normalizedFilter.createdAtStart = toUtcDate(startDate);
    }
    if (endDate) {
      normalizedFilter.createdAtEnd = toUtcDate(endDate);
    }
  }
  if (
    normalizedFilter.isActive &&
    normalizedFilter.isActive.length &&
    normalizedFilter.isActive.length != 2
  ) {
    normalizedFilter.isActive = normalizedFilter.isActive.map(
      (activity: any) => activity.value,
    );
  } else {
    delete normalizedFilter.isActive;
  }
  if (normalizedFilter.updatedAt) {
    const startDate = normalizedFilter.updatedAt[0];
    const endDate = normalizedFilter.updatedAt[1];
    delete normalizedFilter.updatedAt;
    if (startDate) normalizedFilter.updatedAtStart = toUtcDate(startDate);
    if (endDate) normalizedFilter.updatedAtEnd = toUtcDate(endDate);
  }

  const queryForUrl: Record<string, any> = {
    ...normalizedFilter,
  };

  return queryForUrl;
};

watch(filter, (newVal) => {
  const queryForUrl = normalizeFilter(newVal);

  router.replace({
    query: {
      ...truncateQueryObject(queryForUrl),
    },
  });
  debouncedFetchData();
});

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
.department-content {
  background-color: white;
  min-height: calc(100% - 48px - 8px);
  @include box-shadow;
  color: $text-light;
  padding: 20px;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  overflow-x: hidden;
  @include custom-scrollbar;
  height: 100%;

  .table-top {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: flex-end;
    gap: 12px;
    margin-bottom: 20px;

    .button {
      padding: 4px 14px 4px 10px;

      :deep(.button-text) {
        font-size: 14px;
      }
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
