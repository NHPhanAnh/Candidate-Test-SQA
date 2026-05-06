<template>
  <div class="wrapper">
    <UModal
      :open="isEditViewOpen"
      :title="editViewModalTitle"
      :ui="{ content: 'w-[840px] max-w-[840px]' }"
      @update:open="handleEditViewOpenUpdate"
      @after:leave="clearViewEditId"
    >
      <template #body>
        <FormEditUserGroup
          :id="editViewId || -1"
          :initial-mode="editViewInitialMode"
          :allow-edit="canEdit"
          @close-modal="closeEditViewModal"
          @submit="handleModalSubmit"
          @mode-switch="handleSwitchEditViewMode"
        />
      </template>
    </UModal>
    <div class="user-group-content">
      <div class="title">Quản lí nhóm người dùng</div>
      <div class="table-top">
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
          title="Xóa nhóm người dùng"
          :ui="{ content: 'w-[840px] max-w-[840px]' }"
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

        <UModal
          v-model:open="isCreateModalOpen"
          title="Thêm mới nhóm người dùng"
          :ui="{ content: 'w-[840px] max-w-[840px] max-h-[100vh]' }"
        >
          <AppButton :text="'Thêm mới'" class="add-button">
            <template #icon>
              <Icon name="material-symbols:add-2-rounded" />
            </template>
          </AppButton>
          <template #body>
            <FormCreateUserGroup
              @close-modal="closeModal"
              @submit="handleModalSubmit"
            />
          </template>
        </UModal>
      </div>
      <AppTableDataTable
        :table-data="tableData"
        :columns="tableColumns"
        :allow-actions="allowActions"
        :show-checkbox="true"
        :show-actions="true"
        :is-loading="isFetchingData"
        :selection-list="selectedRows"
        :sort="sort"
        :select-options="memberTypeSelectOptions"
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
import {
  userGroupTableHeaders,
  pageSizeOptions,
} from "~/const/views/system-admin/user-group";
import type { TSort } from "~/types/common";
import { cloneDeep, debounce } from "lodash";

definePageMeta({
  layout: "system-admin",
});
useHead({
  title: "Cài đặt nhóm người dùng",
});

const toast = useToast();
const route = useRoute();
const router = useRouter();
const isCreateModalOpen = ref<boolean>(false);
const isDeleteModalOpen = ref<boolean>(false);
const isEditViewOpen = ref<boolean>(false);
const editViewId = ref<number | null>(null);
const editViewInitialMode = ref<any>(null);
const editViewMode = ref<any>(null);
const isFetchingData = ref<boolean>(false);
const fetchRoleController = ref<AbortController | null>();
const memberTypes = ref<any>([]);
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

const editViewModalTitle = computed(() => {
  console.log("computed editviewmodal", editViewMode.value);
  if (editViewMode.value == "view") {
    return "Thông tin nhóm người dùng";
  }

  if (editViewMode.value == "edit") {
    return "Chỉnh sửa nhóm người dùng";
  }

  return "";
});

const { getMenuItem } = useSidebarStore();
const { getRoles, getMemberTypes, deleteUserGroup } = useRoleApi();

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

  console.log("query in conver query", query);

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

  if (query.memberType) {
    const values = (query.memberType as string).split(",");
    restoredFilter.memberType = values
      .map((val) => memberTypes.value.find((opt: any) => opt.value === val))
      .filter(Boolean);
  }

  delete restoredFilter.createdAtStart;
  delete restoredFilter.createdAtEnd;
  delete restoredFilter.updatedAtStart;
  delete restoredFilter.updatedAtEnd;

  return restoredFilter;
};

onBeforeMount(async () => {
  const res = await getMemberTypes();
  memberTypes.value = res.data.map((memberType: any) => ({
    label: memberType.name,
    value: memberType.code,
  }));

  filter.value = convertQuery();

  memberTypes.value = res.data.map((memberType: any) => ({
    label: memberType.name,
    value: memberType.code,
  }));
});

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

const handleEditViewOpenUpdate = (event: boolean) => {
  if (!event) {
    isEditViewOpen.value = false;
  }
};

const handleDelete = async () => {
  isDeleting.value = true;
  const isSuccess = await deleteUserGroup({ ids: deleteList.value });
  isDeleting.value = false;
  if (isSuccess) {
    handleDeleteModalOpenUpdate(false);
    fetchData();
  }
};

const handleModalSubmit = () => {
  closeModal();
  fetchData();
};
const closeModal = () => {
  isCreateModalOpen.value = false;
};

const closeEditViewModal = () => {
  isEditViewOpen.value = false;
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
  if (fetchRoleController.value) {
    fetchRoleController.value.abort();
  }

  fetchRoleController.value = new AbortController();
  isFetchingData.value = true;
  const query = route.query;
  const res = await getRoles(query, fetchRoleController.value);
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
    entry.memberType = entry.memberTypeDto.memberType;
  }
  tableData.value = data;
};
const debouncedFetchData = debounce(fetchData, 400);
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
const tableColumns = computed(() => {
  return userGroupTableHeaders;
});
const pageSizeOpts = computed(() => {
  return pageSizeOptions;
});
const memberTypeSelectOptions = computed(() => {
  return {
    memberType: memberTypes.value,
  };
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
  if (normalizedFilter.updatedAt) {
    const startDate = normalizedFilter.updatedAt[0];
    const endDate = normalizedFilter.updatedAt[1];
    delete normalizedFilter.updatedAt;
    if (startDate) normalizedFilter.updatedAtStart = toUtcDate(startDate);
    if (endDate) normalizedFilter.updatedAtEnd = toUtcDate(endDate);
  }
  if (normalizedFilter.memberType && normalizedFilter.memberType.length) {
    normalizedFilter.memberType = normalizedFilter.memberType.map(
      (memberType: any) => memberType.value,
    );
  } else {
    delete normalizedFilter.memberType;
  }

  const queryForUrl: Record<string, any> = {
    ...normalizedFilter,
  };

  if (Array.isArray(queryForUrl.memberType)) {
    queryForUrl.memberType = queryForUrl.memberType.join(",");
  }

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
.user-group-content {
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
    flex-direction: row;
    gap: 8px;
    justify-content: flex-end;

    :deep(button[type="button"][disabled]) {
      color: $color-gray-400;
    }
  }
  .table-section {
    max-width: 100%;
  }
}
</style>
