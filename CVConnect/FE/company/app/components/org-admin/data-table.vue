<template>
  <div class="data-table-wrapper" :class="{ hasNodata: props.isTableEmpty }">
    <AppNoData v-if="props.isTableEmpty" class="nodata" />
    <div v-if="props.isLoading" class="spinner">
      <AppSpinnerHalfCircle />
    </div>
    <UTable
      ref="table"
      class="data-table"
      :columns="columns"
      :data="props.tableData"
      :loading="props.isLoading"
    >
      <template v-if="props.showCheckbox" #checkbox-header="{ table }">
        <UCheckbox
          size="lg"
          :model-value="checkAllBoxValue(table)"
          @update:model-value="handleCheckAll($event, table)"
        />
      </template>
      <template v-if="props.showCheckbox" #checkbox-cell="{ row }">
        <UCheckbox
          size="lg"
          :model-value="isRowSelected(row)"
          @update:model-value="handleCheck($event, row)"
        />
      </template>
      <template v-if="props.allowActions" #action-header="">
        Hành động
      </template>
      <template v-if="props.allowActions" #action-cell="{ row }">
        <div class="action-wrapper">
          <Icon
            v-if="havePermission('VIEW')"
            title="Xem"
            class="icon"
            name="mdi:eye-outline"
            @click="handleActionClick(row, 'view')"
          />
          <Icon
            v-if="havePermission('UPDATE')"
            class="icon"
            title="Cấp quyền"
            name="ph:tree-structure"
            @click="handleActionClick(row, 'edit')"
          />
        </div>
      </template>
      <template
        v-for="col in excludedColumns"
        :key="col.accessorKey"
        #[`${col.accessorKey}-header`]="{ column }"
      >
        <div class="header-cell">
          <div class="name">
            {{ col.header }}
            <Icon
              v-if="col.isSortable && !getCurrentSort(column)"
              name="mdi:sort"
              class="icon"
              @click="handleSort(columnKey(column), undefined)"
            />
            <Icon
              v-if="col.isSortable && getCurrentSort(column) === 'ASC'"
              name="mdi:sort-ascending"
              class="icon"
              @click="handleSort(columnKey(column), 'ASC')"
            />
            <Icon
              v-if="col.isSortable && getCurrentSort(column) === 'DESC'"
              name="mdi:sort-descending"
              class="icon"
              @click="handleSort(columnKey(column), 'DESC')"
            />
          </div>
          <div v-if="col.allowFilter" class="filter">
            <UInput
              v-if="col.filterType == 'text'"
              class="text-input"
              variant="none"
              :model-value="filter ? filter[col.accessorKey] : ''"
              placeholder="Nhập giá trị"
              @update:model-value="handleFilterUpdate(col.accessorKey, $event)"
            />
            <VueDatePicker
              v-if="col.filterType == 'date'"
              :hide-navigation="['time', 'minutes', 'hours', 'seconds']"
              :enable-time-picker="false"
              range
              class="date-input"
              :teleport="true"
              :model-value="filter ? filter[col.accessorKey] : ''"
              placeholder="Chọn ngày"
              @update:model-value="handleFilterUpdate(col.accessorKey, $event)"
            />
            <USelectMenu
              v-if="col.filterType == 'select'"
              multiple
              class="select-input"
              variant="none"
              autocomplete="autocomplete"
              placeholder="Chọn giá trị"
              :title="selectTooltip(col.accessorKey)"
              :search-input="{
                placeholder: 'Tìm kiếm',
              }"
              :ui="{
                trailingIcon:
                  'group-data-[state=open]:rotate-180 transition-transform duration-200',
              }"
              :items="
                props.selectOptions && props.selectOptions[col.accessorKey]
                  ? props.selectOptions[col.accessorKey]
                  : []
              "
              :model-value="filter ? filter[col.accessorKey] : ''"
              @update:model-value="handleFilterUpdate(col.accessorKey, $event)"
            />
            <Icon
              v-if="
                col.filterType == 'select' &&
                filter &&
                filter[col.accessorKey] &&
                filter[col.accessorKey].length
              "
              name="ic:outline-clear"
              class="clear-icon"
              @click="handleFilterUpdate(col.accessorKey, [])"
            />
          </div>
        </div>
      </template>
      <template
        v-for="col in excludedColumns"
        :key="col.accessorKey"
        #[`${col.accessorKey}-cell`]="{ row }"
      >
        <span
          v-if="
            row.original[col.accessorKey] &&
            row.original[col.accessorKey].cellType == CELL_TYPE.TAG
          "
          :title="row.original[col.accessorKey].text"
        >
          <AppChip
            :text="row.original[col.accessorKey].text"
            :type="row.original[col.accessorKey].type"
          />
        </span>

        <span
          v-else
          class="username-cell"
          :title="row.original[col.accessorKey]"
        >
          {{ row.original[col.accessorKey] }}
          <span
            v-if="
              col.accessorKey === 'username' &&
              row.original.userId === userInfo?.id
            "
            class="asterisk"
          >
            *
          </span>
        </span>
      </template>
      <template #empty>
        <!-- <AppNoData v-if="props.isTableEmpty" /> -->
        <div class="blank"></div>
      </template>
    </UTable>
  </div>
</template>
<script setup lang="ts">
import { cloneDeep } from "lodash";
import { CELL_TYPE } from "~/const/common";
import type { TSort, TSortType } from "~/types/common";

export type TDataTableProps = {
  tableData: any;
  columns: any[];
  selectionList?: number[];
  isLoading?: boolean;
  showCheckbox?: boolean;
  showActions?: boolean;
  allowActions?: TPermission[];
  sort?: TSort | null;
  filter?: Record<string, any> | null;
  selectOptions?: Record<string, { label: string; value: any }[]> | null;
  isTableEmpty?: boolean;
  deleteConditionKey?: string;
};

export type TFilterType = "date" | "text" | "select";

const props = withDefaults(defineProps<TDataTableProps>(), {
  isLoading: false,
  showCheckbox: false,
  showActions: false,
  allowActions: (): TPermission[] => [],
  selectionList: (): number[] => [],
  sort: null,
  filter: null,
  selectOptions: null,
  isTableEmpty: false,
  deleteConditionKey: "canDelete",
});

const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);

const havePermission = (permission: TPermission) => {
  const perm = props.allowActions.find((action) => action === permission);
  return perm;
};

const columns = ref<any[]>(cloneDeep(props.columns));
const selectTooltip = computed(() => {
  return (accessorKey: string) => {
    if (!props.filter) {
      return "";
    }
    const tooltipString = props.filter[accessorKey]
      ?.map((filter: any) => filter.label)
      ?.join(", ");
    return tooltipString;
  };
});
const columnKey = computed(() => {
  return (column: any) => {
    return column.columnDef.accessorKey;
  };
});
const excludedColumns = computed(() => {
  return columns.value.filter(
    (col) => col.accessorKey != "checkbox" && col.accessorKey != "action",
  );
});

onBeforeMount(() => {
  const actionColumn = {
    id: "action",
    meta: {
      class: {
        th: "header-action",
        td: "body-action",
      },
    },
  };
  const checkboxColumn = {
    accessorKey: "checkbox",
    meta: {
      class: {
        th: "header-select",
        td: "body-select",
      },
    },
    enableSorting: true,
  };

  if (props.showCheckbox) {
    columns.value.unshift(checkboxColumn);
  }
  if (props.showActions) {
    columns.value.splice(2, 0, actionColumn);
  }
});

export type TTableAction = "edit" | "delete" | "view";
const emit = defineEmits<{
  (e: "selectionUpdate", selectionList: number[]): void;
  (e: TTableAction, id: number): void;
  (e: "sort", sort: TSort): void;
  (e: "filter", filter: Record<string, any>): void;
}>();

const getCurrentSort = computed(() => {
  return (column: any) => {
    const key = column.columnDef.accessorKey;
    if (props.sort && props.sort.key === key) {
      return props.sort.type;
    }
    return undefined;
  };
});

const nextSortState = computed(() => {
  return (state: TSortType) => {
    if (state === "ASC") {
      return "DESC";
    }
    if (state === "DESC") {
      return undefined;
    }
    return "ASC";
  };
});

const handleFilterUpdate = (accessorKey: string, value: any) => {
  const trimValue = typeof value == "string" ? value.trim() : value;

  if (props.filter) {
    const newFilter = {
      ...props.filter,
      [accessorKey]: trimValue,
    };
    emit("filter", newFilter);
  } else {
    emit("filter", {
      [accessorKey]: trimValue,
    });
  }
};

const handleSort = (key: string, currentState: TSortType) => {
  if (!props.sort || props.sort.key !== key) {
    emit("sort", { key, type: "ASC" });
    return;
  }

  emit("sort", { key, type: nextSortState.value(currentState) });
};

const checkAllBoxValue = computed(() => {
  return (table: any) => {
    const selectedRows = cloneDeep(props.selectionList);
    const allRows = table.getRowModel().rows;
    if (selectedRows.length && selectedRows.length < allRows.length) {
      return "indeterminate";
    }
    if (selectedRows.length == 0) {
      return false;
    }
    return true;
  };
});

const handleCheckAll = (e: any, table: any) => {
  const selections: number[] = [];

  if (e) {
    // Collect all row IDs
    const allRows = table.getRowModel().rows;
    allRows.forEach((row: any) => {
      selections.push(row.original.userId);
    });
  }

  emit("selectionUpdate", selections);
};

const handleCheck = (e: any, row: any) => {
  const selections = cloneDeep(props.selectionList);
  if (e) {
    const rowId = row.original.userId;
    const currentRow = selections.find((selection) => selection === rowId);
    if (!currentRow) {
      selections.push(rowId);
    }
  } else {
    const rowId = row.original.userId;
    const currentRowIndex = selections.indexOf(rowId);
    if (currentRowIndex !== -1) {
      selections.splice(currentRowIndex, 1);
    }
  }
  emit("selectionUpdate", selections);
};

const isRowSelected = computed(() => {
  return (row: any) => {
    const rowId = row.original.userId;
    const isPresent = props.selectionList.find(
      (selection) => selection == rowId,
    );
    if (isPresent !== undefined) {
      return true;
    }
    return false;
  };
});

const handleActionClick = (row: any, action: TTableAction) => {
  const rowId = row.original.userId;
  emit(action, rowId);
};
</script>
<style lang="scss" scoped>
:deep(.username-cell .asterisk) {
  color: $color-danger;
  font-weight: bold;
  margin-left: 4px;
}
.data-table-wrapper {
  overflow-x: auto;
  box-shadow: rgba(0, 0, 0, 0.24) 0px 3px 8px;
  // border: 1px solid $color-gray-300;
  border-radius: 4px;
  position: relative;
  display: flex;
  flex: 1;
  max-height: fit-content;

  .spinner {
    position: absolute;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    z-index: 3;
    background-color: rgba(black, 0.15);
    top: 0px;
    left: 0px;
    width: 100%;
    height: 100%;

    .icon {
      color: $color-primary-400;
    }
  }

  .data-table {
    flex: 1;
    max-width: 100%;
    min-height: 0;
    overflow: auto;
    @include custom-scrollbar;

    :deep(table) {
      border-radius: 4px;

      .header-cell {
        &.padding-cell:nth-of-type(1) {
          // background-color: red;
        }

        display: flex;
        flex-direction: column;
        gap: 4px;
        .name {
          display: flex;
          flex-direction: row;
          align-items: center;
          gap: 8px;
          .icon {
            display: block;
            font-size: 20px;
            z-index: 0;
            cursor: pointer;
          }
        }
        .filter {
          display: flex;
          flex-direction: row;
          align-items: center;
          width: 100%;
          position: relative;
          gap: 4px;
          .text-input {
            input {
              &::placeholder {
                font-size: 13px;
                color: $color-gray-400;
                font-weight: 400;
              }

              border: 1px solid $color-primary-200 !important;
              border-radius: 10px !important;
              padding: 4px 10px !important;
              font-weight: 500 !important;
              color: $color-gray-600 !important;
              font-size: 13px;
              line-height: 20px;
              background-color: $color-gray-100 !important;
            }
          }

          .clear-icon {
            cursor: pointer;
            position: absolute;
            right: 36px;
          }

          button.select-input {
            border: 1px solid $color-primary-200 !important;
            border-radius: 10px !important;
            padding: 4px 48px 4px 10px !important;
            font-weight: 500 !important;
            color: $color-gray-600 !important;
            height: 29px;
            font-size: 13px;
            line-height: 20px;
            background-color: $color-gray-100 !important;
            width: 100%;

            .text-dimmed {
              font-size: 13px;
              color: $color-gray-400;
              font-weight: 400;
            }
          }

          .date-input {
            .dp__input_wrap {
              width: 218px;
              input::placeholder {
                color: $color-gray-500;
                font-weight: 400;
                font-size: 14px;
              }
              .dp__input {
                width: 218px;
                border: 1px solid $color-primary-200 !important;
                border-radius: 10px !important;
                padding-top: 4px;
                padding-bottom: 4px;
                font-weight: 500 !important;
                color: $color-gray-600 !important;
                font-size: 13px;
                line-height: 20px;
                background-color: $color-gray-100 !important;
              }
            }
          }
        }
      }

      .header-select,
      .body-select {
        width: 50px;
        min-width: 50px;
      }

      .header-action,
      .body-action {
        width: 108px;
        min-width: 108px;
        .action-wrapper {
          display: flex;
          flex-direction: row;
          align-items: center;
          justify-content: center;
          gap: 8px;
          .icon {
            cursor: pointer;
            display: block;
            font-size: 20px;
            transition: color 200ms;

            &.disabled {
              opacity: 0.2;
              cursor: default;
            }

            &:hover:not(.disabled) {
              color: $color-primary-600;
            }
          }
        }
      }

      // Header border
      thead {
        tr:last-child {
          height: 0px;
        }
      }

      tr {
        .body-select,
        .header-select {
          button:hover {
            cursor: pointer;
          }
        }
      }

      // Row border
      tbody {
        tr:hover {
          td {
            background-color: $color-gray-50;
          }
        }
        // &.divide-y {
        //   tr:not(:last-child) {
        //     border-bottom: 1px solid $color-gray-300;
        //   }
        // }
      }

      tr {
        background-color: $color-primary-50;
        font-weight: 500;
        th {
          background-color: $color-primary-50;
          color: $color-primary-400;
          position: sticky;
          top: 0px;
          font-weight: 600;
          &::before {
            content: "";
            position: absolute;
            bottom: 0px;
            left: 0px;
            width: 100%;
            height: 1px;
            background-color: $color-gray-300;
          }
        }
        td {
          color: $text-light;
        }

        th:nth-child(1),
        th:nth-child(2),
        th:nth-child(3) {
          z-index: 2;
        }
        td:nth-child(1),
        td:nth-child(2),
        td:nth-child(3) {
          z-index: 1;
        }

        th:nth-child(1),
        th:nth-child(2),
        th:nth-child(3),
        td:nth-child(1),
        td:nth-child(2),
        td:nth-child(3) {
          position: sticky;
          top: 0px;
        }

        th:nth-child(1),
        td:nth-child(1) {
          left: 0px;
        }
        th:nth-child(2),
        td:nth-child(2) {
          left: 50px;
        }
        th:nth-child(3),
        td:nth-child(3) {
          left: 106px;
          &::after {
            content: "";
            position: absolute;
            top: 0;
            right: -1px;
            width: 1px;
            height: 100%;
            background-color: $color-gray-300;
            display: block;
          }
        }

        td {
          background-color: white;
        }
      }
    }
  }

  .blank {
    display: block;
    height: 132px;
    width: 100%;
  }
  .nodata {
    top: 98px;
    right: 50%;
    transform: translateX(50%);
    z-index: 2;
    position: absolute;
  }

  &.hasNodata {
    :deep(tbody) {
      height: 132px;
    }
  }
}
</style>
