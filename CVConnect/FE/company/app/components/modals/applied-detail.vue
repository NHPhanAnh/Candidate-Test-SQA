<template>
  <UModal
    v-model:open="isOpen"
    :title="'Thông tin ứng tuyển'"
    :ui="{ content: 'max-w-[720px]' }"
  >
    <template #body>
      <div class="body">
        <div class="row">
          <AppInputText
            :label="'Tên'"
            :required="false"
            :error="''"
            :placeholder="''"
            :value="props.detail.candidateInfo.fullName"
            :is-disabled="true"
            :slim-error="true"
            :title="''"
            class="text-input"
          />
          <AppInputText
            :label="'Email'"
            :required="false"
            :error="''"
            :placeholder="''"
            :value="props.detail.candidateInfo.email"
            :is-disabled="true"
            :slim-error="true"
            :title="''"
            class="text-input"
          />
        </div>
        <div class="preview-cv" @click="handlePreviewCV">
          <div class="text">Xem CV</div>
          <Icon name="ci:external-link" />
        </div>
        <AppInputTextarea
          :model-value="props.detail.candidateInfo.coverLetter"
          :label="'Cover letter'"
          :required="false"
          :is-disabled="true"
          :placeholder="''"
          :error="''"
          :show-error="false"
          :slim-error="true"
        />
      </div>
    </template>
    <template #footer>
      <div class="modal-footer">
        <AppButton class="submit-btn btn" :text="'OK'" @click="handleCancel" />
      </div>
    </template>
  </UModal>
</template>
<script setup lang="ts">
type TProps = {
  modelValue: boolean;
  detail: any;
};

const props = defineProps<TProps>();

const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

const route = useRoute();
const router = useRouter();

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

function handleCancel() {
  emits("update:modelValue", false);
}

function handlePreviewCV() {
  window.open(props.detail.candidateInfo.cvUrl, "_blank");
}
</script>
<style lang="scss" scoped>
.body {
  display: flex;
  flex-direction: column;
  gap: 8px;

  :deep(.text-input) {
    flex: 1;
    .input {
      padding: 6px 8px;
      input {
        font-size: 14px;
      }
    }
  }

  :deep(textarea) {
    max-height: 280px;
  }

  .preview-cv {
    display: flex;
    flex-direction: row;
    gap: 4px;
    cursor: pointer;
    width: fit-content;

    .text {
      color: $text-light;
      font-size: 14px;
    }

    .iconify {
      font-size: 20px;
      display: block;
      width: 20px;
      height: 20px;
      min-width: 20px;

      color: $color-info;
    }
  }
}

.row {
  display: flex;
  flex-direction: row;
  gap: 8px;
}

.modal-footer {
  width: 100%;
  display: flex;
  flex-direction: row;
  gap: 8px;
  justify-content: flex-end;
}

.btn {
  font-size: 14px;
  padding: 6px 12px;
  min-width: 84px;

  &.cancel-btn {
    border: 1px solid $color-primary-500;
    color: $color-primary-500;
  }

  &.submit-btn {
    background-color: $color-primary-500;
    border: 1px solid $color-primary-500;
    color: $text-dark;

    &.disabled {
      background-color: $color-gray-400;
      border: 1px solid $color-gray-400;
    }
  }
}
</style>
