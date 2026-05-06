<template>
  <div class="calendar">
    <OrgCandidateCreateScheduleModal
      v-model="isCreateScheduleModalOpen"
      :job-ad-info="selectedJobAdInfo"
      :job-ad-candidate-id="selectedJobAdInfo.id"
      :candidate-info="props.candidateInfo"
      @submit="handleCreateSchedule"
    />
    <OrgCandidateViewScheduleModal
      v-model="isViewScheduleModalOpen"
      :target-id="detailId"
    />
    <div class="top">
      <div class="left">
        <AppInputSearchSelect
          :label="''"
          :required="false"
          :options="jobAdOpts"
          :value="selectedJobAd"
          :error="''"
          :placeholder="'Mời chọn tin tuyển dụng'"
          :remote-filter="false"
          :allow-clear="false"
          :multiple="false"
          :is-disabled="false"
          :slim-error="true"
          :fetch-fn="null"
          class="job-ad-select"
          @input="($event) => (selectedJobAd = $event)"
          @clear-value="() => (selectedJobAd = null)"
        />
        <AppInputSearchSelect
          :label="''"
          :required="false"
          :options="participationTypeOpts"
          :value="participationType"
          :error="''"
          :placeholder="'Mời chọn loại'"
          :remote-filter="false"
          :allow-clear="false"
          :multiple="false"
          :is-disabled="false"
          :slim-error="true"
          :fetch-fn="null"
          class="type-select"
          @input="($event) => (participationType = $event)"
          @clear-value="() => (participationType = null)"
        />
      </div>
      <div class="right">
        <AppButton
          :text="''"
          class="refresh"
          :is-disabled="!selectedJobAd"
          @click="fetchSchedules"
        >
          <template #icon>
            <Icon
              class="refresh-icon"
              name="material-symbols:refresh-rounded"
            />
          </template>
        </AppButton>
        <AppButton
          :text="'Tạo lịch hẹn'"
          class="create-schedule-btn"
          :title="
            !selectedJobAd ? 'Hãy chọn tin tuyển dụng để tạo lịch hẹn' : ''
          "
          :is-disabled="!selectedJobAd"
          @click="() => (isCreateScheduleModalOpen = true)"
        />
      </div>
    </div>
    <div class="schedule-list">
      <OrgCandidateInfoRightCalendarGroup
        v-for="(group, index) of scheduleList"
        :key="index"
        :label-date="group.labelDate"
        :quant="group.numOfCalendars"
        :list="group.calendars"
        @schedule-click="handleScheduleClick"
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
const { getSchedules } = useCandidateApi();

const selectedJobAd = ref<any>(null);
const participationType = ref<any>({
  label: "Tất cả",
  value: null,
});
const isNodata = ref<boolean>(false);
const isCreateScheduleModalOpen = ref<boolean>(false);
const isViewScheduleModalOpen = ref<boolean>(false);
const scheduleList = ref<any>([]);
const detailId = ref<any>(-1);

const props = defineProps<TProps>();

onBeforeMount(async () => {
  if (props.jobAds.length) {
    const ad = props.jobAds[0];
    selectedJobAd.value = {
      label: ad.jobAd.title,
      value: ad.jobAd.id,
    };
  }
  await fetchSchedules();
});

const participationTypeOpts = [
  {
    label: "Tôi tạo",
    value: "CREATED_BY_ME",
  },
  {
    label: "Tôi tham gia",
    value: "JOINED_BY_ME",
  },
  {
    label: "Tất cả",
    value: null,
  },
];

const jobAdOpts = computed(() => {
  return props.jobAds.map((ad) => ({
    label: ad.jobAd.title,
    value: ad.jobAd.id,
  }));
});

const selectedJobAdInfo = computed(() => {
  return props.jobAds.find((ad) => ad.jobAd.id === selectedJobAd.value?.value);
});

function handleScheduleClick(schedule: any) {
  detailId.value = schedule.calendarCandidateInfoId;
  isViewScheduleModalOpen.value = true;
}

async function fetchSchedules() {
  setLoading(true);
  console.log(selectedJobAdInfo.value);
  const params: any = {
    jobAdCandidateId: selectedJobAdInfo.value.id,
  };

  if (participationType.value.value) {
    params.participationType = participationType.value.value;
  }

  console.log(params);

  const res = await getSchedules(params);
  scheduleList.value = res.data;
  if (!res.data?.length) {
    isNodata.value = true;
  } else {
    isNodata.value = false;
  }
  setLoading(false);
}

function handleCreateSchedule() {
  isCreateScheduleModalOpen.value = false;
  fetchSchedules();
}

watch(selectedJobAd, async (newVal) => {
  if (newVal != undefined && newVal != null) {
    return;
  }

  fetchSchedules();
});

watch(participationType, async (newVal) => {
  fetchSchedules();
});
</script>
<style lang="scss" scoped>
.calendar {
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

    .left {
      display: flex;
      flex-direction: row;
      gap: 12px;
      align-items: center;
      flex-wrap: wrap;
      row-gap: 8px;
    }

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
    .type-select {
      min-width: 136px;
    }

    .create-schedule-btn {
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

  .schedule-list {
    flex: 1;
    min-height: 0;
    overflow: auto;
    display: flex;
    flex-direction: column;
    gap: 6px;
    margin-top: 12px;
    padding-bottom: 24px;
  }
}
</style>
