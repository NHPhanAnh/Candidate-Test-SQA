<template>
  <UModal
    v-model:open="isOpen"
    title="Chỉnh sửa đánh giá"
    :ui="{ content: 'max-w-[840px]' }"
  >
    <template #body>
      <div class="body">
        <!-- <div class="job-ad-info"> -->
        <!--   <div class="info-top"> -->
        <!--     <span class="title">{{ props.jobAdInfo.jobAd.title }}</span> -->
        <!--     <span -->
        <!--       class="value chip" -->
        <!--       :title="statusTooltip(props.jobAdInfo)" -->
        <!--       :style="{ -->
        <!--         borderColor: -->
        <!--           CANDIDATE_STATUS[props.jobAdInfo.candidateStatus].color, -->
        <!--         color: CANDIDATE_STATUS[props.jobAdInfo.candidateStatus].color, -->
        <!--         backgroundColor: -->
        <!--           CANDIDATE_STATUS[props.jobAdInfo.candidateStatus].background, -->
        <!--       }" -->
        <!--       >{{ -->
        <!--         CANDIDATE_STATUS[props.jobAdInfo.candidateStatus].label -->
        <!--       }}</span -->
        <!--     > -->
        <!--   </div> -->
        <!--   <div class="info-dept-pos"> -->
        <!--     <span>{{ props.jobAdInfo.jobAd.departmentName }}</span> -->
        <!--     <span>•</span> -->
        <!--     <span>{{ props.jobAdInfo.jobAd.positionName }}</span> -->
        <!--   </div> -->
        <!--   <div class="hr-info"> -->
        <!--     <span class="hr-info-label"> -->
        <!--       <Icon name="material-symbols:article-person-rounded" /> -->
        <!--       <span>{{ props.jobAdInfo.jobAd.hrContactName }}</span> -->
        <!--     </span> -->
        <!--   </div> -->
        <!-- </div> -->
        <div class="form">
          <AppInputTextarea
            v-model="formInput.comments"
            :label="'Đánh giá'"
            :required="true"
            :placeholder="'Mời nhập đánh giá'"
            :is-disabled="false"
            :error="''"
            :slim-error="true"
            :show-error="false"
          />
          <div class="grade-input">
            <div class="label">
              <span>Điểm số</span>
            </div>
            <div class="row">
              <UInputNumber
                v-model="formInput.score"
                variant="none"
                :min="0"
                :max="10"
                class="num-input"
              />
              <Icon
                v-if="formInput.score != undefined"
                name="material-symbols:close-rounded"
                @click="() => (formInput.score = undefined)"
              />
            </div>
          </div>
        </div>
      </div>
    </template>
    <template #footer>
      <div class="modal-footer">
        <AppButton
          class="cancel-btn btn"
          :text="'Đóng'"
          @click="handleCancel"
        />
        <AppButton
          class="submit-btn btn"
          :text="'Cập nhật'"
          :is-disabled="isSubmitDisabled"
          :is-loading="isLoading"
          @click="handleSubmit"
        />
      </div>
    </template>
  </UModal>
</template>
<script setup lang="ts">

type TProps = {
  modelValue: boolean;
  // jobAdInfo: any;
  evaluationInfo: any;
  jobAdCandidateId: any;
};

const { editEvaluation } = useCandidateApi();

const props = defineProps<TProps>();

const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

onBeforeMount(async () => {});

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const isLoading = ref<boolean>(false);

const formInput = ref<Record<string, any>>({
  comments: "",
  score: undefined,
});

const statusTooltip = computed(() => {
  return (displayJobAd: any) => {
    if (displayJobAd.candidateStatus === "REJECTED") {
      return formatDateTime(displayJobAd.eliminateDate, "DD/MM/YYYY - HH:mm");
    }
    return "";
  };
});

function handleCancel() {
  emits("update:modelValue", false);
}

const isSubmitDisabled = computed(() => {
  if (!formInput.value.comments?.trim()) {
    return true;
  }
  return false;
});

async function handleSubmit() {
  isLoading.value = true;
  const payload: any = {
    comments: formInput.value.comments,
  };
  if (formInput.value.score != undefined) {
    payload.score = formInput.value.score;
  }

  const res = await editEvaluation(props.evaluationInfo.id, props.jobAdCandidateId, payload);
  isLoading.value = false;
  if (res) {
    emits("submit");
  }
}

watch(
  () => props.modelValue,
  (newVal) => {
    if (!newVal) {
      // clear everything
      formInput.value = {
        comments: "",
        score: undefined,
      };
    } else {
      formInput.value = {
        comments: props.evaluationInfo.comments,
        score: props.evaluationInfo.score,
      }
    }
  },
);
</script>
<style lang="scss" scoped>
.body {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .job-ad-info {
    font-size: 14px;
    border: 1px solid $color-gray-300;
    border-radius: 6px;
    padding: 6px;

    display: flex;
    flex-direction: column;
    gap: 8px;

    .hr-info {
      display: flex;
      flex-direction: row;
      gap: 8px;
      justify-content: space-between;
      flex-wrap: wrap;
      .hr-info-label {
        display: flex;
        flex-direction: row;
        gap: 4px;
        align-items: center;

        .iconify {
          display: block;
          font-size: 20px;
        }
      }
    }

    .info-dept-pos {
      display: flex;
      flex-direction: row;
      gap: 8px;
    }

    .info-top {
      display: flex;
      flex-direction: row;
      justify-content: space-between;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;

      .chip {
        border-radius: 4px;
        padding: 4px;
        border: 1px solid $color-gray-300;
        font-size: 12px;
        font-weight: 500;
      }
    }

    .misc-text {
      font-style: italic;
    }
  }

  .form {
    display: flex;
    flex-direction: column;
    gap: 6px;

    .grade-input {
      display: flex;
      flex-direction: column;
      gap: 4px;

      .label {
        font-size: 14px;
        color: $text-light;
      }
    }

    .num-input {
      max-width: 120px;
      :deep(input) {
        border: 1px solid rgba($color-primary-800, 0.1);
        border-radius: 12px;

        &:hover,
        &:focus {
          border: 1px solid rgba($color-primary-400, 1);
        }
      }
    }
  }

  :deep(textarea) {
    max-height: 90px;
  }

  .required {
    font-size: 12px;
    font-style: italic;
    color: $color-danger;
    margin-left: 8px;
  }

  :deep(.text-input) {
    flex: 1;
    .input {
      padding: 4px 6px;
      input {
        font-size: 14px;
      }
    }
  }

  .line {
    display: flex;
    flex-direction: row;
    gap: 8px;
    justify-content: space-between;
    flex: 1;
  }

  .iconify {
    font-size: 20px;
    display: block;
    width: 20px;
    cursor: pointer;
  }

  .row {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 8px;
    flex: 1;
  }
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
  min-width: 64px;

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
