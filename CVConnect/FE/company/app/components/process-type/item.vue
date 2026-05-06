<template>
  <div class="process-type-item">
    <div v-if="props.allowDrag" class="drag-icon">
      <Icon name="uil:draggabledots" />
    </div>
    <div class="content">
      <div
        :style="{ color: color(props.code) ?? DEFAULT_PROCESS_COLOR_CODE }"
        class="color-icon"
      >
        <Icon name="mdi:square-rounded" class="icon" />
      </div>
      <div v-if="currentMode == 'display'" class="name">
        <div v-if="props.name">{{ props.name }}</div>
        <div v-else class="empty">{{ "Trống" }}</div>
        <div>{{ ` - ` }}</div>
        <div v-if="props.code">{{ props.code }}</div>
        <div v-else class="empty">{{ "Trống" }}</div>
      </div>
      <div v-else class="edit-field">
        <input
          ref="inputRef"
          v-model.trim="editInfo.name"
          @keyup.enter="handleSave"
          @keyup.esc="handleCancel"
        />
        <div>{{ ` - ` }}</div>
        <input
          v-if="!props.id"
          v-model.trim="editInfo.code"
          @keyup.enter="handleSave"
          @keyup.esc="handleCancel"
        />
        <div v-else>{{ props.code }}</div>
      </div>
      <div v-if="props.allowEdit" class="actions">
        <Icon
          v-if="currentMode == 'display'"
          class="icon"
          title="Chỉnh sửa"
          name="mdi:pencil-outline"
          @click="handleEdit"
        />
        <Icon
          v-if="currentMode == 'edit'"
          class="icon save-icon"
          title="Lưu"
          name="material-symbols:check-rounded"
          :class="{ disabled: isSaveDisabled }"
          @click="handleSave"
        />
        <Icon
          v-if="currentMode == 'edit'"
          class="icon cancel-icon"
          title="Hủy"
          name="material-symbols:close-rounded"
          @click="handleCancel"
        />
        <Icon
          class="icon"
          title="Xóa"
          name="mdi:delete-outline"
          :class="{ disabled: props.isDefault }"
          @click="handleDelete"
        />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import {
  DEFAULT_PROCESS_COLOR_CODE,
  PROCESS_COLOR_CODE,
} from "~/const/views/system-admin/process-type";

type TProps = {
  id: number | null;
  code: string;
  name: string;
  isDefault: boolean;
  allowDrag?: boolean;
  allowEdit?: boolean;
  isNew?: boolean;
};

const props = withDefaults(defineProps<TProps>(), {
  allowDrag: true,
  allowEdit: true,
});
const emits = defineEmits<{
  (e: "update", payload: any): void;
  (e: "delete"): void;
  (e: "isEditing", value: boolean): void;
}>();

// "display" | "edit"
const currentMode = ref<string>("display");
const editInfo = ref<{ name: string; code: string }>({
  name: "",
  code: "",
});
const inputRef = ref<HTMLInputElement | null>(null);

onBeforeMount(() => {
  editInfo.value = {
    name: props.name,
    code: props.code,
  };
});

const isSaveDisabled = computed(() => {
  return !editInfo.value.name || !editInfo.value.code;
});

const color = computed(() => {
  return (code: string) => {
    const index = code as keyof typeof PROCESS_COLOR_CODE;
    return PROCESS_COLOR_CODE[index];
  };
});

const handleCancel = () => {
  editInfo.value = {
    name: props.name,
    code: props.code,
  };
  currentMode.value = "display";
  emits("isEditing", false);
};

const handleSave = () => {
  if (isSaveDisabled.value) {
    return;
  }
  if (!props.id) {
    emits("update", { name: editInfo.value.name, code: editInfo.value.code });
  } else {
    emits("update", { name: editInfo.value.name });
  }
  currentMode.value = "display";
  emits("isEditing", false);
};

const handleEdit = () => {
  currentMode.value = "edit";
  nextTick(() => {
    if (inputRef.value) {
      inputRef.value.focus();
    }
  });
  emits("isEditing", true);
};

const handleDelete = () => {
  if (props.isDefault) {
    return;
  }
  emits("delete");
  emits("isEditing", false);
};
</script>
<style lang="scss" scoped>
.process-type-item {
  padding: 20px;
  border-radius: 16px;
  @include box-shadow;
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 16px;
  font-size: 16px;
  line-height: 20px;
  background-color: white;
  transition:
    transform 0.2s ease,
    box-shadow 0.2s ease;

  .drag-icon {
    display: block;
    font-size: 20px;
    height: 20px;
    cursor: pointer;
  }

  .content {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 8px;
    flex: 1;

    .color-icon {
      height: 20px;
      .icon {
        display: block;
        font-size: 20px;
      }
    }

    .name,
    .edit-field {
      flex: 1;
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 6px;

      .empty {
        color: $color-gray-300;
        font-style: italic;
      }
    }

    .edit-field {
      input {
        outline: none;
        border: 1px solid $color-primary-100;
        padding: 4px;
        margin: -5px 0px;
        width: 160px;
        border-radius: 8px;
        transition: border 200ms;

        &:hover,
        &:focus {
          border: 1px solid $color-primary-500;
        }
      }
    }

    .actions {
      display: flex;
      flex-direction: row;
      gap: 8px;

      .icon {
        font-size: 20px;
        cursor: pointer;
        height: 20px;
        transition: color 200ms;

        &.save-icon {
          color: $color-success;

          &:hover:not(.disabled) {
            color: $color-success;
          }

          &.disabled {
            cursor: default;
            color: $color-gray-700;
          }
        }

        &.cancel-icon {
          color: $color-danger;

          &:hover:not(.disabled) {
            color: $color-danger;
          }
        }

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
}

.drag-chosen {
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
  opacity: 1;
}

.drag-ghost {
  opacity: 0.6;
  transform: scale(0.98);
}
</style>
