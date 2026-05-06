<template>
  <div class="evaluation-group">
    <OrgCandidateEditEvaluationModal
      v-model="isEditModalOpen"
      :evaluation-info="editingTarget"
      :job-ad-candidate-id="props.jobAdCandidateId"
      @submit="handleEditEvaluation"
    />
    <div class="wrapper" @click="() => (isExpanded = !isExpanded)">
      <div class="subject">
        {{
          `${props.process.name} (${props.evaluations.length ? props.evaluations.length : ""})`
        }}
      </div>
    </div>
    <div v-show="isExpanded" class="content">
      <div
        v-for="evaluation of props.evaluations"
        :key="evaluation.id"
        class="evaluation"
      >
        <div class="evaluation-card">
          <div class="line mb-2">
            <span class="evaluator-name"
              >{{ evaluation.evaluatorName
              }}<span
                v-if="evaluation.score != undefined"
                class="grade whitespace-pre"
                >{{ `  -  ${evaluation.score}/10` }}</span
              >
              <span
                v-if="isEdited(evaluation)"
                class="edited"
                :title="
                  formatDateTime(evaluation.updatedAt, 'DD/MM/YYYY - HH:mm')
                "
                >Đã chỉnh sửa</span
              >
            </span>
            <div class="right">
              <span class="evaluator-time"
                >{{
                  formatDateTime(evaluation.createdAt, "DD/MM/YYYY - HH:mm")
                }}
              </span>
              <span class="edit-btn">
                <Icon
                  name="material-symbols:edit-square-outline-rounded"
                  @click="handleEditClick(evaluation)"
                />
              </span>
            </div>
          </div>
          <!-- <div class="divider"></div> -->
          <div class="line mt-2">
            <AppInputTextarea
              v-model="evaluation.comments"
              :label="''"
              :required="false"
              :placeholder="''"
              :is-disabled="true"
              :error="''"
              :slim-error="true"
              :show-error="false"
            />
          </div>
          <!-- <div v-if="evaluation.score != undefined" class="line mt-2"> -->
          <!--   <div class="grade"> -->
          <!--     {{ `Điểm số: ${evaluation.score}/10` }} -->
          <!--   </div> -->
          <!-- </div> -->
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  process: any;
  evaluations: any;
  jobAdCandidateId: any;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "refetch"): void;
}>();

const isExpanded = ref<boolean>(false);
const editingTarget = ref<any>(null);
const isEditModalOpen = ref<boolean>(false);

const isEdited = computed(() => {
  return (evaluation: any) => {
    return !!evaluation.updatedAt;
  };
});

function handleEditClick(evaluation: any) {
  editingTarget.value = evaluation;
  isEditModalOpen.value = true;
}

function handleEditEvaluation() {
  isEditModalOpen.value = false;
  emits("refetch");
}
</script>
<style lang="scss" scoped>
.evaluation-group {
  font-size: 14px;
  display: flex;
  flex-direction: column;
  border: 1px solid $color-gray-300;
  border-radius: 6px;
  overflow: hidden;
  min-height: fit-content;

  .wrapper {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    flex-wrap: wrap;
    padding: 8px;
    cursor: pointer;

    .resend-button {
      padding: 7px 12px;
      font-size: 14px;
      line-height: 20px;
      background-color: $color-primary-500;
      color: $text-dark;
    }

    .subject {
      font-weight: 600;
    }

    .right {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 8px;

      .chip {
        border-radius: 4px;
        padding: 4px;
        font-size: 12px;
        border: 1px solid $color-gray-300;
        font-weight: 500;
      }
    }
  }

  .content {
    border-top: 1px solid $color-gray-300;
    display: flex;
    flex-direction: column;
    // gap: 8px;
    // padding: 12px;

    .evaluation-card {
      padding: 10px 0px;
      // border: 1px solid $color-gray-200;
      // border-radius: 6px;
      // @include box-shadow;

      .evaluator-name,
      .evaluator-time {
        font-weight: 600;
      }

      .right {
        display: flex;
        flex-direction: row;
        align-items: center;
      }

      .edit-btn {
        display: flex;
        align-items: center;
        .iconify {
          font-size: 20px;
          display: inline-block;
          width: 20px;
          height: 20px;
          margin-left: 8px;
          cursor: pointer;
        }
      }

      .divider {
        width: 100%;
        height: 1px;
        display: block;
        background-color: $color-gray-200;
      }

      .edited {
        font-weight: 400;
        font-size: 13px;
        font-style: italic;
        margin-left: 8px;
        color: $color-gray-400;
      }

      :deep(textarea) {
        max-height: fit-content;
      }

      .grade {
        font-size: 14px;
        color: $text-light;
      }

      .line {
        padding: 0px 10px;
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        align-content: center;
      }
    }
  }
}
</style>
