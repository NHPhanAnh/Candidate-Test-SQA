<template>
  <div class="change-logo-modal">
    <UModal
      v-model:open="isOpen"
      :ui="{ content: 'w-[600px] max-w-[600px]' }"
      :title="'Đổi ảnh bìa doanh nghiệp'"
    >
      <template #body>
        <div class="modal-body">
          <UFileUpload
            v-model="uploadFile"
            accept="image/*"
            class="file-upload"
          />
        </div>
      </template>
      <template #footer>
        <div class="footer">
          <div class="buttons">
            <AppButton
              :text="'Hủy bỏ'"
              class="cancel-button"
              @click.prevent="emits('update:modelValue', false)"
            />
            <AppButton
              :is-disabled="!uploadFile"
              :text="'Lưu'"
              :is-loading="isSubmiting"
              class="submit-button"
              @click="handleSubmit"
            />
          </div>
        </div>
      </template>
    </UModal>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  modelValue: boolean;
};
const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

const { updateCover } = useOrgApi();

const isSubmiting = ref<boolean>(false);

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

async function handleSubmit() {
  const formDataReq = new FormData();

  if (uploadFile.value instanceof File) {
    formDataReq.append("file", uploadFile.value);
  }

  isSubmiting.value = true;
  const res = await updateCover(formDataReq);
  if (res) {
    emits("submit");
  }
  isSubmiting.value = false;
}

const uploadFile = ref<File | undefined>(undefined);
</script>
<style lang="scss" scoped>
.modal-body {
  display: flex;
  justify-content: center;
  :deep(.file-upload) {
    cursor: pointer;
    width: 100%;

    button {
      cursor: pointer;
    }
    img {
      cursor: default;
    }
  }
}

.footer {
  width: 100%;
  height: fit-content;
  :deep(.buttons) {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: flex-end;
    gap: 8px;

    .cancel-button,
    .submit-button {
      padding: 4px 14px 4px 14px;

      :deep(.button-text) {
        font-size: 14px;
      }
    }

    .submit-button {
      background-color: $color-primary-400;
      color: $text-dark;

      &.disabled {
        background-color: $color-gray-400;
      }
    }
    .cancel-button {
      padding: 3px 14px 3px 14px;
      background-color: white;
      color: $color-primary-400;
      border: 1px solid $color-primary-400;
    }

    .active-btn {
      background-color: white;
      padding: 3px 14px 3px 14px;

      :deep(.button-text) {
        font-size: 14px;
      }

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
  }
}
</style>
