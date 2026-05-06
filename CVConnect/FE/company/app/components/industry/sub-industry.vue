<template>
  <div class="sub-industry">
    <div class="left">
      <AppInputText
        :label="''"
        :required="false"
        :error="''"
        :placeholder="'Mời nhập mã'"
        :value="props.data.code"
        :is-disabled="props.isDisabled"
        :slim-error="true"
        :title="props.data.code"
        class="text-input"
        @input="handleInput('code', $event)"
      />
      <AppInputText
        :label="''"
        :required="false"
        :error="''"
        :placeholder="'Mời nhập tên'"
        :value="props.data.name"
        :is-disabled="props.isDisabled"
        :title="props.data.name"
        :slim-error="true"
        class="text-input"
        @input="handleInput('name', $event)"
      />
    </div>
    <div v-if="!props.isDisabled" class="right">
      <!-- <Icon -->
      <!--   v-if="!props.data.isEdit" -->
      <!--   class="icon" -->
      <!--   title="Chỉnh sửa" -->
      <!--   name="mdi:pencil-outline" -->
      <!--   :class="{ disabled: props.isDisabled }" -->
      <!--   @click="props.isDisabled ? () => {} : handleEdit()" -->
      <!-- /> -->
      <!-- <Icon -->
      <!--   v-if="props.data.isEdit" -->
      <!--   class="icon save-icon" -->
      <!--   title="Lưu" -->
      <!--   name="material-symbols:check-rounded" -->
      <!--   :class="{ disabled: isSaveDisabled }" -->
      <!--   @click="handleSave" -->
      <!-- /> -->
      <!-- <Icon -->
      <!--   v-if="props.data.isEdit" -->
      <!--   class="icon cancel-icon" -->
      <!--   title="Hủy" -->
      <!--   name="material-symbols:close-rounded" -->
      <!--   @click="handleCancel" -->
      <!-- /> -->
      <Icon
        class="icon"
        title="Xóa"
        name="mdi:delete-outline"
        :class="{ disabled: props.isDisabled }"
        @click="props.isDisabled ? () => {} : handleDelete()"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
import { cloneDeep } from "lodash";
import type { TSubIndustry } from "~/types/subIndustry";

type TProps = {
  data: TSubIndustry;
  isDisabled?: boolean;
};

const props = withDefaults(defineProps<TProps>(), {
  isDisabled: false,
});

const emits = defineEmits<{
  (e: "input", value: TSubIndustry): void;
  (e: "delete"): void;
}>();

const snapshot = ref<TSubIndustry | undefined>(undefined);

const isSaveDisabled = computed(() => {
  if (!props.data.code || !props.data.name) {
    return true;
  }
  return false;
});

const handleInput = <K extends keyof TSubIndustry>(
  key: K,
  value: TSubIndustry[K],
) => {
  if (key == "isEdit") {
    return;
  }
  emits("input", {
    ...props.data,
    [key]: (value as string).trim(),
  });
};

const handleEdit = () => {
  // Switch to edit
  if (!props.data.isEdit) {
    snapshot.value = cloneDeep(props.data);
  }
  emits("input", {
    ...props.data,
    isEdit: !props.data.isEdit,
  });
};

const handleCancel = () => {
  if (!snapshot.value) {
    return;
  }
  emits("input", {
    ...snapshot.value,
    isEdit: false,
  });
};

const handleSave = () => {
  if (isSaveDisabled.value) {
    return;
  }
  emits("input", {
    ...props.data,
    isEdit: false,
  });
};

const handleDelete = () => {
  emits("delete");
};
</script>
<style lang="scss" scoped>
.sub-industry {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 4px;
  border: 1px solid $color-gray-200;
  border-radius: 4px;
  padding: 8px;
  width: 100%;

  .left {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 8px;
    flex: 1;

    .text-input {
      max-width: 260px;

      :deep(input) {
        font-size: 13px;
      }
      :deep(.input) {
        padding: 6px 8px;
      }
    }
  }

  .right {
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
</style>
