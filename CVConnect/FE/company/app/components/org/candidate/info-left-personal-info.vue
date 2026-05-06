<template>
  <div class="personal-info-wrapper">
    <div class="label">Thông tin cá nhân</div>
    <div class="row">
      <div class="info-row">
        <Icon name="material-symbols:mail-outline-rounded" />
        <span>{{ props.info.email }}</span>
      </div>
      <div class="info-row">
        <Icon name="material-symbols:call-outline-rounded" />
        <span>{{ props.info.phone }}</span>
      </div>
    </div>
    <div class="row">
      <div class="cover-letter">{{ props.info.coverLetter }}</div>
    </div>
    <div class="row">
      <AppInputSearchSelect
        :label="'Đánh giá cấp bậc'"
        :required="false"
        :options="levelOptions"
        :value="formInput.level"
        :error="''"
        :placeholder="'Mời chọn cấp bậc'"
        :remote-filter="true"
        :multiple="false"
        :is-disabled="false"
        :slim-error="true"
        :fetch-fn="fetchLevel"
        @input="handleInput('level', $event)"
        @clear-value="handleInput('level', null)"
        @search-filter="
          () => {
            levelList = [];
          }
        "
      />
    </div>
    <div class="row">
      <AppInputTextarea
        :model-value="formInput.skill"
        :label="'Kỹ năng'"
        :required="false"
        :is-disabled="false"
        :placeholder="'Mời nhập kỹ năng'"
        :error="''"
        :row="6"
        :slim-error="true"
        :show-error="false"
        @update:model-value="handleInput('skill', $event)"
      />
    </div>
    <div class="buttons">
      <AppButton
        :text="'Hủy'"
        class="button cancel-btn"
        @click="handleCancel"
      />
      <AppButton
        :text="'Lưu'"
        class="button submit-btn"
        :is-disabled="isSubmitDisabled"
        @click="handleUpdate"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
import { cloneDeep, isEmpty, isEqual } from "lodash";

type TProps = {
  info: Record<string, any>;
};

const props = defineProps<TProps>();
const { getLevels } = useLevelApi();
const { saveSummary } = useCandidateApi();
const { setLoading } = useLoadingStore();

const levelList = ref<Record<string, any>[]>([]);
const formInputSnapshot = ref<Record<string, any>>({});
const formInput = ref<Record<string, any>>({
  level: undefined,
  skill: "",
});

const levelOptions = computed(() => {
  return levelList.value.map((level) => ({
    label: level.name,
    value: level.id,
  }));
});

const isSubmitDisabled = computed(() => {
  return isEqual(formInput.value, formInputSnapshot.value);
});

async function fetchLevel(params: any, controller?: AbortController) {
  // const ids = formInput.value.department.value;
  const newParams = {
    ...params,
    // departmentIds: ids,
  };
  const res = await getLevels(newParams, controller);
  if (!res) {
    return null;
  }
  const nextPage = res.data.data;
  levelList.value = [...levelList.value, ...nextPage];
  return res.data.data;
}

function handleInput(key: string, value: any) {
  formInput.value[key] = value;
}

function handleCancel() {
  formInput.value = cloneDeep(formInputSnapshot.value);
}

async function handleUpdate() {
  console.log(formInput.value);
  const payload = {
    skill: formInput.value.skill,
    levelId: formInput.value.level?.value,
    candidateInfoId: props.info.id,
  };
  setLoading(true);
  const success = await saveSummary(payload);
  setLoading(false);
  if (success) {
    formInputSnapshot.value = cloneDeep(formInput.value);
  }
}

watch(
  () => props,
  (newValue) => {
    formInput.value = {
      level: {
        value: newValue.info.candidateSummaryOrg.level.id,
        label: newValue.info.candidateSummaryOrg.level.levelName,
      },
      skill: newValue.info.candidateSummaryOrg.skill,
    };
    formInputSnapshot.value = cloneDeep(formInput.value);
  },
  {
    immediate: true,
    deep: true,
  },
);
</script>
<style lang="scss" scoped>
.personal-info-wrapper {
  font-size: 14px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-right: 4px;

  .label {
    font-weight: 500;
    font-size: 16px;
    margin-top: 12px;
    color: $text-light;
  }

  .row {
    display: flex;
    flex-direction: row;
    column-gap: 32px;
    row-gap: 8px;
    align-items: center;
    flex-wrap: wrap;
  }

  .cover-letter {
    background-color: $color-gray-100;
    padding: 6px;
    border-radius: 6px;
  }

  .info-row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;
  }

  .iconify {
    display: block;
    font-size: 20px;
    width: 20px;
  }

  .buttons {
    display: flex;
    flex-direction: row;
    justify-content: center;
    gap: 16px;
    align-items: center;
    padding-bottom: 12px;
    padding-top: 12px;

    .button {
      padding: 4px 12px;
      font-size: 14px;
    }

    .submit-btn {
      background-color: $color-primary-500;
      border: 1px solid $color-primary-500;
      color: $text-dark;

      &.disabled {
        background-color: $color-gray-400;
        border-color: $color-gray-400;
      }
    }

    .cancel-btn {
      color: $color-primary-500;
      border: 1px solid $color-primary-500;
    }
  }

  :deep(.search-select-input) {
    .label {
      font-weight: 500;
    }
  }

  :deep(.textarea-input) {
    .label {
      font-weight: 500;
    }
  }
}
</style>
