<template>
  <div class="process-block">
    <div class="list">
      <div v-if="props.processList[0]" class="process-unit immutable">
        <div
          :style="{
            color:
              color(props.processList[0]?.code) ?? DEFAULT_PROCESS_COLOR_CODE,
          }"
          class="color-icon"
        >
          <Icon name="mdi:square-rounded" class="icon" />
        </div>
        <div class="content">
          <div class="info">
            {{ `${props.processList[0]?.name}` }}
          </div>
        </div>
      </div>
      <draggable
        v-if="internalList.length"
        :list="internalList"
        item-key="processId"
        handle=".drag-handle"
        ghost-class="drag-ghost"
        chosen-class="drag-chosen"
        animation="200"
        class="drag-list"
        :disabled="props.disabled"
        @end="handleDragEnd"
      >
        <template #item="{ element, index }">
          <div class="process-unit">
            <div v-if="!props.disabled" class="remove-button" @click="handleRemove(index)">
              <Icon name="material-symbols:close-rounded" />
            </div>
            <div v-if="!props.disabled" class="drag-handle" title="Kéo để sắp xếp">
              <Icon name="material-symbols:drag-indicator" />
            </div>
            <div
              :style="{
                color:
                  color(itemCode(element.processId)) ??
                  DEFAULT_PROCESS_COLOR_CODE,
              }"
              class="color-icon"
            >
              <Icon name="mdi:square-rounded" class="icon" />
            </div>
            <div class="content">
              <div class="info">
                {{ `${element.processName}` }}
              </div>
              <AppInputText
                :label="''"
                :required="true"
                :error="''"
                :placeholder="'Mời nhập tên'"
                :value="element.name"
                :slim-error="true"
                :is-disabled="props.disabled"
                :title="element.name"
                class="text-input"
                @input="handleInput(index, $event)"
              />
            </div>
          </div>
        </template>
      </draggable>
      <div v-if="!props.disabled" class="select-input">
        <USelectMenu
          :key="resetKey"
          :model-value="undefined"
          :items="processOption"
          class="selector"
          :variant="'none'"
          autocomplete="autocomplete"
          placeholder="Thêm vòng tuyển dụng"
          :search-input="{ placeholder: 'Tìm kiếm' }"
          :ui="{
            base: 'flex justify-center items-center text-primary-400 font-medium gap-2',
            leadingIcon: 'flex items-center justify-center text-primary-400',
            trailingIcon: 'hidden',
          }"
          @update:model-value="handleAddNew($event)"
        >
        </USelectMenu>
      </div>
      <div
        v-if="props.processList[processList.length - 1]"
        class="process-unit immutable"
      >
        <div
          :style="{
            color:
              color(props.processList[processList.length - 1]?.code) ??
              DEFAULT_PROCESS_COLOR_CODE,
          }"
          class="color-icon"
        >
          <Icon name="mdi:square-rounded" class="icon" />
        </div>
        <div class="content">
          <div class="info">
            {{ `${props.processList[processList.length - 1]?.name}` }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import draggable from "vuedraggable";
import { cloneDeep } from "lodash";
import {
  DEFAULT_PROCESS_COLOR_CODE,
  PROCESS_COLOR_CODE,
} from "~/const/views/system-admin/process-type";

type TProps = {
  list: Record<string, any>[];
  processList: Record<string, any>[];
  disabled?: boolean;
};

const props = withDefaults(defineProps<TProps>(), {
  disabled: false,
});
const emits = defineEmits<{ (e: "input", payload: any[]): void }>();

const resetKey = ref(0);
const internalList = ref<Record<string, any>[]>([]);

onBeforeMount(async () => {
  internalList.value = cloneDeep(props.list);
});

watch(
  () => props.list,
  (val) => {
    internalList.value = cloneDeep(val);
  },
  { deep: true },
);

const processOption = computed(() =>
  props.processList.slice(1, props.processList.length - 1).map((process) => ({
    label: process.name,
    value: process.id,
  })),
);

const itemCode = computed(() => {
  return (id: number) => {
    const process = props.processList.find((process) => process.id == id);
    return process ? process.code : undefined;
  };
});

const color = computed(() => {
  return (code: string | undefined) => {
    if (!code) {
      return DEFAULT_PROCESS_COLOR_CODE;
    }
    const index = code as keyof typeof PROCESS_COLOR_CODE;
    return PROCESS_COLOR_CODE[index];
  };
});

const handleRemove = (index: number) => {
  const list = cloneDeep(internalList.value);
  list.splice(index, 1);
  emits("input", list);
};

const handleInput = (index: number, value: string) => {
  const list = cloneDeep(internalList.value);
  list[index]!.name = value;
  emits("input", list);
};

const handleAddNew = (newItem: any) => {
  const list = cloneDeep(internalList.value);
  resetKey.value++;
  emits("input", [
    ...list,
    {
      processName: newItem.label,
      processId: newItem.value,
      name: newItem.label,
    },
  ]);
};

const handleDragEnd = () => {
  if (props.disabled) {
    return;
  }
  emits("input", internalList.value);
};
</script>

<style lang="scss" scoped>
.process-block {
  .list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-top: 8px;

    .drag-list {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .process-unit {
      position: relative;
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 8px;
      border: 1px solid $color-gray-300;
      border-radius: 6px;
      padding: 8px;
      background: #fff;

      .color-icon {
        height: 20px;
        width: 20px;
        .iconify {
          display: block;
          font-size: 20px;
        }
      }

      &.immutable {
        padding: 16px;
      }

      .info {
        font-size: 14px;
        font-weight: 600;
      }

      .content {
        display: flex;
        flex-direction: column;
        gap: 4px;

        :deep(.text-input) {
          width: 360px;
          .input {
            padding: 6px 8px;
            input {
              font-size: 14px;
            }
          }
        }
      }

      .drag-handle {
        cursor: grab;
        .iconify {
          display: block;
          font-size: 20px;
          color: $color-gray-500;
        }
      }

      .remove-button {
        position: absolute;
        top: 4px;
        right: 4px;
        font-size: 20px;
        cursor: pointer;

        .iconify {
          color: $color-gray-500;
          transition-duration: 200ms;
          &:hover {
            color: $color-primary-500;
          }
        }
      }
    }

    .select-input {
      :deep(button.selector) {
        padding: 8px;
        border: 1px dashed $color-primary-400;
        background-color: rgba($color-primary-400, 0.05);
        cursor: pointer;
        width: 100%;

        .text-dimmed {
          color: $color-primary-400;
          font-weight: 500;
        }
      }
    }
  }
}

.drag-ghost {
  opacity: 0.4;
}
.drag-chosen {
  background: #f7fafc;
}
</style>
