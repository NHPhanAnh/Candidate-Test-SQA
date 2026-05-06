<template>
  <div class="role-menu-select" :class="{ disabled: props.isDisabled }">
    <div class="row header-row">
      <div class="header menu-cell">Chức năng</div>
      <div class="header checkbox-cell">Tất cả</div>
      <div class="header checkbox-cell">Xem</div>
      <div class="header checkbox-cell">Thêm</div>
      <div class="header checkbox-cell">Sửa</div>
      <div class="header checkbox-cell">Xóa</div>
      <div class="header checkbox-cell">Xuất bản</div>
    </div>
    <div v-for="menu of props.menus" :key="menu.id" class="body">
      <div class="line border-top">
        <div class="menu-title">
          {{ menu.menuLabel }}
        </div>
        <div class="checkbox-cell">
          <UCheckbox
            :model-value="getCheckboxValue(menu, 'ALL')"
            @update:model-value="handleCheckbox(menu, 'ALL', $event)"
          />
        </div>
        <div class="checkbox-cell">
          <UCheckbox
            :model-value="getCheckboxValue(menu, 'VIEW')"
            @update:model-value="handleCheckbox(menu, 'VIEW', $event)"
          />
        </div>
        <div class="checkbox-cell">
          <UCheckbox
            :model-value="getCheckboxValue(menu, 'ADD')"
            @update:model-value="handleCheckbox(menu, 'ADD', $event)"
          />
        </div>
        <div class="checkbox-cell">
          <UCheckbox
            :model-value="getCheckboxValue(menu, 'UPDATE')"
            @update:model-value="handleCheckbox(menu, 'UPDATE', $event)"
          />
        </div>
        <div class="checkbox-cell">
          <UCheckbox
            :model-value="getCheckboxValue(menu, 'DELETE')"
            @update:model-value="handleCheckbox(menu, 'DELETE', $event)"
          />
        </div>
        <div class="checkbox-cell">
          <UCheckbox
            :model-value="getCheckboxValue(menu, 'EXPORT')"
            @update:model-value="handleCheckbox(menu, 'EXPORT', $event)"
          />
        </div>
      </div>
      <div v-if="menu.children && menu.children.length" class="menu-child">
        <div v-for="subMenu1 of menu.children" :key="subMenu1.id">
          <div class="line">
            <div class="menu-title">
              {{ subMenu1.menuLabel }}
            </div>
            <div class="checkbox-cell">
              <UCheckbox
                :model-value="getCheckboxValue(subMenu1, 'ALL')"
                @update:model-value="handleCheckbox(subMenu1, 'ALL', $event)"
              />
            </div>
            <div class="checkbox-cell">
              <UCheckbox
                :model-value="getCheckboxValue(subMenu1, 'VIEW')"
                @update:model-value="handleCheckbox(subMenu1, 'VIEW', $event)"
              />
            </div>
            <div class="checkbox-cell">
              <UCheckbox
                :model-value="getCheckboxValue(subMenu1, 'ADD')"
                @update:model-value="handleCheckbox(subMenu1, 'ADD', $event)"
              />
            </div>
            <div class="checkbox-cell">
              <UCheckbox
                :model-value="getCheckboxValue(subMenu1, 'UPDATE')"
                @update:model-value="handleCheckbox(subMenu1, 'UPDATE', $event)"
              />
            </div>
            <div class="checkbox-cell">
              <UCheckbox
                :model-value="getCheckboxValue(subMenu1, 'DELETE')"
                @update:model-value="handleCheckbox(subMenu1, 'DELETE', $event)"
              />
            </div>
            <div class="checkbox-cell">
              <UCheckbox
                :model-value="getCheckboxValue(subMenu1, 'EXPORT')"
                @update:model-value="handleCheckbox(subMenu1, 'EXPORT', $event)"
              />
            </div>
          </div>
          <div
            v-if="subMenu1.children && subMenu1.children.length"
            class="menu-child1"
          >
            <div v-for="subMenu2 of subMenu1.children" :key="subMenu2.id">
              <div class="line">
                <div class="menu-title">
                  {{ subMenu2.menuLabel }}
                </div>
                <div class="checkbox-cell">
                  <UCheckbox
                    :model-value="getCheckboxValue(subMenu2, 'ALL')"
                    @update:model-value="
                      handleCheckbox(subMenu2, 'ALL', $event)
                    "
                  />
                </div>
                <div class="checkbox-cell">
                  <UCheckbox
                    :model-value="getCheckboxValue(subMenu2, 'VIEW')"
                    @update:model-value="
                      handleCheckbox(subMenu2, 'VIEW', $event)
                    "
                  />
                </div>
                <div class="checkbox-cell">
                  <UCheckbox
                    :model-value="getCheckboxValue(subMenu2, 'ADD')"
                    @update:model-value="
                      handleCheckbox(subMenu2, 'ADD', $event)
                    "
                  />
                </div>
                <div class="checkbox-cell">
                  <UCheckbox
                    :model-value="getCheckboxValue(subMenu2, 'UPDATE')"
                    @update:model-value="
                      handleCheckbox(subMenu2, 'UPDATE', $event)
                    "
                  />
                </div>
                <div class="checkbox-cell">
                  <UCheckbox
                    :model-value="getCheckboxValue(subMenu2, 'DELETE')"
                    @update:model-value="
                      handleCheckbox(subMenu2, 'DELETE', $event)
                    "
                  />
                </div>
                <div class="checkbox-cell">
                  <UCheckbox
                    :model-value="getCheckboxValue(subMenu2, 'EXPORT')"
                    @update:model-value="
                      handleCheckbox(subMenu2, 'EXPORT', $event)
                    "
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  menus: TSidebarItem[];
  initialPermMap?: any;
  isDisabled?: boolean;
};

const props = withDefaults(defineProps<TProps>(), {
  initialPermMap: {},
  isDisabled: false,
});
const emit = defineEmits<{
  (e: "permChange", payload: any): void;
}>();

const permValue = ref<any>({});

onBeforeMount(() => {
  console.log("perm map", props.initialPermMap);
});

const getCheckboxValue = computed(() => {
  const resolveValue = (
    menu: TSidebarItem,
    perm: TPermission | "ALL",
  ): boolean | "indeterminate" => {
    if (perm === "ALL") {
      const perms: TPermission[] = [
        "VIEW",
        "ADD",
        "UPDATE",
        "DELETE",
        "EXPORT",
      ];
      const results = perms.map((p) => resolveValue(menu, p));

      const allTrue = results.every((v) => v === true);
      const allFalse = results.every((v) => v === false);

      if (allTrue) return true;
      if (allFalse) return false;
      return "indeterminate";
    }

    if (menu.menuUrl) {
      return permValue.value[menu.id]?.[perm] ?? false;
    }

    if (menu.children?.length) {
      const results = menu.children.map((child) => resolveValue(child, perm));

      const allTrue = results.every((v) => v === true);
      const allFalse = results.every((v) => v === false);

      if (allTrue) return true;
      if (allFalse) return false;
      return "indeterminate";
    }

    return false;
  };

  return resolveValue;
});

const handleCheckbox = (
  item: TSidebarItem,
  perm: TPermission | "ALL",
  value: boolean | string,
) => {
  if (props.isDisabled) {
    return;
  }
  if (perm === "ALL") {
    const perms: TPermission[] = ["VIEW", "ADD", "UPDATE", "DELETE", "EXPORT"];
    for (const p of perms) {
      console.log(item);
      handleCheckbox(item, p, value);
    }
    return;
  }

  if (item.menuUrl) {
    handleCheckboxChange(item.id, perm, value);
  }

  if (item.children?.length) {
    for (const child of item.children) {
      handleCheckbox(child, perm, value);
    }
  }
};

const handleCheckboxChange = (
  id: number,
  perm: TPermission,
  value: boolean | string,
) => {
  if (!permValue.value[id]) {
    permValue.value[id] = {
      VIEW: false,
      ADD: false,
      UPDATE: false,
      DELETE: false,
      EXPORT: false,
    };
  }

  permValue.value[id][perm] = value;
  console.log(permValue.value);
  emit("permChange", permValue.value);
};

watch(
  () => props.initialPermMap,
  (newVal) => {
    if (!newVal) {
      permValue.value = {};
    } else {
      permValue.value = newVal;
    }
    console.log("watcher", newVal);
  },
  { immediate: true },
);
</script>
<style lang="scss" scoped>
.role-menu-select {
  @include custom-scrollbar;
  margin-top: 18px;
  max-height: 65%;
  overflow-y: auto;
  position: relative;
  border-radius: 6px;
  max-height: calc(60vh - 188px);
  border: 1px solid $color-gray-300;
  min-height: 0;
  flex: 1;
  .body {
    display: flex;
    flex-direction: column;
    &:not(:first-child) {
      .border-top {
        border-top: 1px solid $color-gray-300;
      }
    }
    .line {
      display: flex;
      flex-direction: row;
      align-items: center;
    }
  }
  .row {
    display: flex;
    flex-direction: row;
    align-items: center;

    &.header-row {
      position: sticky;
      z-index: 2;
      top: 0px;
      border-bottom: 1px solid $color-gray-300;
    }

    .header {
      background-color: $color-gray-100;
      padding: 4px 8px;
    }
  }

  .menu-title {
    padding: 4px 8px;
    width: fit-content;
    font-size: 13px;
    font-weight: 500;
    flex: 1;
  }
  .menu-child {
    padding-left: 16px;

    .menu-child1 {
      padding-left: 16px;
    }
  }

  .checkbox-cell {
    width: 86px;
    text-align: center;
    display: flex;
    justify-content: center;
    :deep(button) {
      cursor: pointer;
    }
  }

  &.disabled {
    .checkbox-cell {
      :deep(button) {
        cursor: default;
      }
    }
  }

  .menu-cell {
    flex: 1;
    text-align: left;
  }
}
</style>
