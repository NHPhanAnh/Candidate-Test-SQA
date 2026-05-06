<template>
  <div class="description-info">
    <div class="textarea-block">
      <div class="label">
        <span class="text">Mô tả chung về công việc</span>
        <span class="required">Bắt buộc</span>
      </div>
      <AppInputBasicTextEditor
        :value="formInput.description"
        @input="handleInput('description', $event)"
      />
    </div>
    <div class="row">
      <div class="textarea-block">
        <div class="label">
          <span class="text">Quyền lợi</span>
          <!-- ><span class="required">Bắt buộc</span> -->
        </div>
        <AppInputBasicTextEditor
          :value="formInput.benefit"
          @input="handleInput('benefit', $event)"
        />
      </div>
      <div class="textarea-block">
        <div class="label">
          <span class="text">Yêu cầu công việc</span>
          <!-- ><span class="required">Bắt buộc</span> -->
        </div>
        <AppInputBasicTextEditor
          :value="formInput.requirement"
          @input="handleInput('requirement', $event)"
        />
      </div>
    </div>
    <AppInputTextarea
      :label="'Thêm từ khóa'"
      :required="false"
      :slim-error="true"
      :error="''"
      :desc="`Bổ sung các từ khóa để giúp ứng viên dễ dàng tìm tin tuyển dụng. Từ khóa cách nhau bởi dấu ';'`"
      :placeholder="'Thêm từ khóa'"
      @input="handleInput('keyword', $event.target.value)"
    />
  </div>
</template>
<script setup lang="ts">
export type TDescriptionInfoForm = {
  description: string;
  benefit: string;
  requirement: string;
  keyword: string;
};

type TProps = {
  data?: TDescriptionInfoForm;
};

const props = withDefaults(defineProps<TProps>(), {
  data: () => ({
    description: "",
    benefit: "",
    requirement: "",
    keyword: "",
  }),
});
const emits = defineEmits<{
  (e: "dataChange", payload: TDescriptionInfoForm): void;
}>();

const formInput = ref<Record<string, any>>({});

onBeforeMount(() => {
  formInput.value = props.data;
});

function handleInput(key: string, value: any) {
  formInput.value[key] = value;
}

watch(
  formInput,
  (newVal) => {
    emits("dataChange", newVal as TDescriptionInfoForm);
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.description-info {
  display: flex;
  flex-direction: column;
  gap: 20px;

  .textarea-block {
    display: flex;
    flex-direction: column;
    gap: 4px;
    flex: 1;
    .label {
      display: flex;
      flex-direction: row;
      gap: 8px;
      align-items: center;
      width: fit-content;

      .text {
        font-size: 14px;
        line-height: 21px;
      }

      .required {
        font-size: 12px;
        font-style: italic;
        color: $color-danger;
      }
    }
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 20px;
    @include respond-max(972px) {
      flex-direction: column;
    }
  }
}
</style>
