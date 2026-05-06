<template>
  <div class="evaluation">
    <OrgCandidateCreateEvaluationModal
      v-model="isCreateEvaluationModalOpen"
      :job-ad-info="selectedJobAdInfo"
      :job-ad-candidate-id="selectedJobAdInfo.id"
      @submit="handleCreateEvaluation"
    />
    <div class="top">
      <AppInputSearchSelect
        :label="''"
        :required="false"
        :options="jobAdOpts"
        :value="selectedJobAd"
        :error="''"
        :placeholder="'Mời chọn tin tuyển dụng'"
        :allow-clear="false"
        :remote-filter="false"
        :multiple="false"
        :is-disabled="false"
        :slim-error="true"
        :fetch-fn="null"
        class="job-ad-select"
        @input="($event) => (selectedJobAd = $event)"
        @clear-value="() => (selectedJobAd = null)"
      />
      <div class="right">
        <AppButton :text="''" class="refresh" :is-disabled="!selectedJobAd" @click="fetchGrades">
          <template #icon>
            <Icon
              class="refresh-icon"
              name="material-symbols:refresh-rounded"
            />
          </template>
        </AppButton>
        <AppButton
          :text="'Tạo đánh giá'"
          class="create-grading-btn"
          :title="
            !selectedJobAd ? 'Hãy chọn tin tuyển dụng để tạo đánh giá' : ''
          "
          :is-disabled="!selectedJobAd"
          @click="() => (isCreateEvaluationModalOpen = true)"
        />
      </div>
    </div>
    <div class="grade-list">
      <OrgCandidateEvaluationGroup
        v-for="(evaluatioGroup, index) of evaluationList"
        :key="index"
        :process="evaluatioGroup.jobAdProcess"
        :evaluations="evaluatioGroup.evaluations"
        :job-ad-candidate-id="selectedJobAdInfo.id"
        @refetch="fetchGrades"
      />
      <AppNoData v-if="isNodata" />
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  jobAds: any[];
  candidateInfo: any;
};

const { setLoading } = useLoadingStore();
const { getEvaluations } = useCandidateApi();

const selectedJobAd = ref<any>(null);
const isNodata = ref<boolean>(false);
const isCreateEvaluationModalOpen = ref<boolean>(false);
const evaluationList = ref<any>([]);

const props = defineProps<TProps>();

onBeforeMount(() => {
  if (props.jobAds.length) {
    const ad = props.jobAds[0];
    selectedJobAd.value = {
      label: ad.jobAd.title,
      value: ad.jobAd.id,
    };
  }
});

const jobAdOpts = computed(() => {
  return props.jobAds.map((ad) => ({
    label: ad.jobAd.title,
    value: ad.jobAd.id,
  }));
});

const selectedJobAdInfo = computed(() => {
  return props.jobAds.find((ad) => ad.jobAd.id === selectedJobAd.value?.value);
});

async function fetchGrades() {
  setLoading(true);
  const res = await getEvaluations(selectedJobAdInfo.value.id);
  evaluationList.value = res.data;
  if (res.data.length == 0) {
    isNodata.value = true;
  } else {
    isNodata.value = false;
  }

  setLoading(false);
}

function handleCreateEvaluation() {
  isCreateEvaluationModalOpen.value = false;
  fetchGrades();
}

watch(selectedJobAd, async (newVal) => {
  if (!newVal || newVal.value == -1) {
    return;
  }

  console.log(selectedJobAd);

  fetchGrades();
});
</script>
<style lang="scss" scoped>
.evaluation {
  display: flex;
  flex-direction: column;
  gap: 4px;
  max-height: 100%;

  .top {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;
    row-gap: 8px;

    .right {
      display: flex;
      flex-direction: row;
      gap: 12px;
      align-items: center;
      flex-wrap: wrap;
      row-gap: 8px;
    }

    .job-ad-select {
      max-width: 420px;
    }

    .create-grading-btn {
      padding: 7px 12px;
      font-size: 14px;
      line-height: 20px;
      background-color: $color-primary-500;
      color: $text-dark;

      &.disabled {
        background-color: $color-gray-400;
      }
    }

    .refresh {
      padding: 0px;
      gap: 0px;
      .refresh-icon {
        font-size: 20px;
      }
    }
  }

  .divider {
    width: 100%;
    height: 1px;
    display: block;
    background-color: $color-gray-200;
  }

  .grade-list {
    flex: 1;
    min-height: 0;
    overflow: auto;
    display: flex;
    flex-direction: column;
    gap: 6px;
    margin-top: 12px;
  }
}
</style>
