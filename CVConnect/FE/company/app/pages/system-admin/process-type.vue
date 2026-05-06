<template>
  <div class="process-type">
    <div class="title">Vòng tuyển dụng</div>
    <div class="content">
      <ProcessTypeItem
        v-if="typeLists.length"
        :id="typeLists[0]?.id || null"
        :code="typeLists[0]!.code"
        :name="typeLists[0]!.name"
        :is-default="typeLists[0]!.isDefault"
        :allow-drag="false"
        :allow-edit="false"
        class="readonly"
      />
      <draggable
        v-model="draggableTypeList"
        group="people"
        item-key="id"
        handle=".drag-icon"
        class="draggable-content"
        ghost-class="drag-ghost"
        chosen-class="drag-chosen"
        animation="200"
      >
        <template #item="{ element, index }">
          <ProcessTypeItem
            :id="element.id || null"
            :code="element.code"
            :name="element.name"
            :is-default="element.isDefault"
            @update="handleUpdate($event, index)"
            @delete="handleDelete(index)"
            @is-editing="handleIsEditing($event, index)"
          />
        </template>
      </draggable>
      <div v-if="typeLists.length" class="add-button" @click="handleAddClick">
        <div class="text">Thêm mới</div>
      </div>
      <ProcessTypeItem
        v-if="typeLists.length"
        :id="typeLists[typeLists.length - 1]?.id || null"
        :code="typeLists[typeLists.length - 1]!.code"
        :name="typeLists[typeLists.length - 1]!.name"
        :is-default="typeLists[typeLists.length - 1]!.isDefault"
        :allow-drag="false"
        :allow-edit="false"
        class="readonly"
      />
    </div>
    <div class="buttons">
      <AppButton
        class="reset-button"
        :text="'Hủy bỏ'"
        :is-disabled="isResetDisabled"
        @click="handleReset"
      />
      <AppButton
        class="submit-button"
        :text="'Cập nhật'"
        :is-disabled="isSubmitDisabled"
        @click="handleSubmit"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
import { cloneDeep, isEqual } from "lodash";
import draggable from "vuedraggable";
import type { TProcessTypeItem } from "~/types/processType";

definePageMeta({
  layout: "system-admin",
});

const typeLists = ref<TProcessTypeItem[]>([]);
const draggableTypeList = ref<TProcessTypeItem[]>([]);
const snapshot = ref<TProcessTypeItem[]>([]);

const { getAll, updateList } = useProcessTypeApi();
const { setLoading } = useLoadingStore();

onBeforeMount(async () => {
  await initList();
});

const isResetDisabled = computed(() => {
  if (!typeLists.value.length) {
    return true;
  }
  const list = [
    typeLists.value[0],
    ...draggableTypeList.value,
    typeLists.value[typeLists.value.length - 1],
  ];

  return isEqual(list, snapshot.value);
});

const isSubmitDisabled = computed(() => {
  if (!typeLists.value.length) {
    return true;
  }
  const list = [
    typeLists.value[0],
    ...draggableTypeList.value,
    typeLists.value[typeLists.value.length - 1],
  ];

  for (const type of draggableTypeList.value) {
    if (!type.code || !type.name || type.isEditing) {
      return true;
    }
  }

  return isEqual(list, snapshot.value);
});

const initList = async () => {
  setLoading(true);
  const res = await getAll();
  setLoading(false);
  typeLists.value = res.data;
  snapshot.value = cloneDeep(typeLists.value);
  draggableTypeList.value = typeLists.value.slice(1, -1);
};

const handleReset = () => {
  typeLists.value = cloneDeep(snapshot.value);
  draggableTypeList.value = typeLists.value.slice(1, -1);
};

const handleSubmit = async () => {
  console.log("submit");
  if (!typeLists.value.length) {
    return;
  }
  const list = [
    typeLists.value[0],
    ...draggableTypeList.value,
    typeLists.value[typeLists.value.length - 1],
  ];

  for (const [index, type] of list.entries()) {
    if (!type) {
      return;
    }
    type.sortOrder = index + 1;
  }

  setLoading(true);
  const isSuccess = await updateList(list as TProcessTypeItem[]);
  setLoading(false);
  if (isSuccess) {
    initList();
  }
};

const handleUpdate = (value: any, index: number) => {
  let target = draggableTypeList.value[index];
  if (!target) {
    return;
  }
  target = {
    ...target,
    ...value,
  };
  if (target) {
    draggableTypeList.value[index] = target;
  }
};

const handleDelete = (index: number) => {
  draggableTypeList.value.splice(index, 1);
};

const handleAddClick = () => {
  draggableTypeList.value.push({
    code: "",
    name: "",
    isDefault: false,
  });
};

const handleIsEditing = (event: boolean, index: number) => {
  let target = draggableTypeList.value[index];
  if (!target) {
    return;
  }
  target = {
    ...target,
    isEditing: event,
  };
  if (target) {
    draggableTypeList.value[index] = target;
  }
  console.log(draggableTypeList.value[index]);
};
</script>
<style lang="scss" scoped>
.process-type {
  @include box-shadow;
  @include custom-scrollbar;
  background-color: white;
  border-radius: 8px;
  margin-top: 8px;
  min-height: calc(100% - 48px - 8px);
  color: $text-light;
  padding: 20px;
  display: flex;
  flex-direction: column;

  .title {
    font-weight: 700;
    font-size: 16px;
    line-height: 20px;
    margin-bottom: 12px;
  }

  .content {
    @include custom-scrollbar;
    padding: 8px;
    display: flex;
    flex: 1;
    min-height: 0;
    overflow-y: auto;
    flex-direction: column;
    gap: 12px;

    .readonly {
      &.process-type-item {
        // background-color: #E8F5E9;
        // border: 1px solid #e3f2fd;
      }
    }

    .draggable-content {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .add-button {
      cursor: pointer;
      padding: 18px;
      border: 2px dashed rgba($color-danger, 0.3);
      border-radius: 16px;
      display: flex;
      justify-content: center;
      align-items: center;
      transition: background-color 200ms;
      &:hover {
        background-color: rgba($color-primary-50, 0.3);
      }
      .text {
        font-size: 16px;
        line-height: 20px;
        color: $color-danger;
      }
    }
  }

  .buttons {
    display: flex;
    flex-direction: row;
    justify-content: center;
    gap: 18px;
    margin-top: 24px;

    .submit-button {
      background-color: $color-primary-500;
      padding: 6px 16px;
      color: $text-dark;

      &.disabled {
        background-color: $color-gray-300;
      }
    }
    .reset-button {
      color: $color-primary-500;
      background-color: #ffffff;
      border: 1px solid $color-primary-500;
      padding: 6px 16px;

      &.disabled {
        border: 1px solid $color-gray-300;
        color: $color-gray-300;
      }
    }
  }
}
</style>
