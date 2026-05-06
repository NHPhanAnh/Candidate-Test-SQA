<template>
  <div class="wrapper">
    <div class="calendar-content">
      <OrgCalendarDetailModal
        v-model="isDetailModalShow"
        :target-id="detailId"
      />
      <div class="title">Lịch của tôi</div>
      <div class="top">
        <div class="left">
          <AppInputDatepicker
            :label="''"
            :required="false"
            :value="dateRange"
            :error="''"
            :slim-error="true"
            :placeholder="''"
            :is-range="true"
            @input="handleDateRange($event)"
          />
          <AppInputSearchSelect
            :label="''"
            :required="false"
            :options="participationTypeOpts"
            :value="filter.participationType"
            :error="''"
            :placeholder="'Mời chọn loại'"
            :remote-filter="false"
            :allow-clear="false"
            :multiple="false"
            :is-disabled="false"
            :slim-error="true"
            :fetch-fn="null"
            class="type-select"
            @input="($event) => (filter.participationType = $event)"
            @clear-value="() => (filter.participationType = undefined)"
          />

          <AppInputSearchSelect
            :label="''"
            :required="false"
            :options="jobAdOpts"
            :value="filter.jobAd"
            :error="''"
            :placeholder="'Mời chọn tin tuyển dụng'"
            :remote-filter="true"
            :allow-clear="true"
            :multiple="false"
            :is-disabled="false"
            :slim-error="true"
            :fetch-fn="fetchJobAds"
            class="job-ad-select"
            @input="($event) => (filter.jobAd = $event)"
            @clear-value="() => (filter.jobAd = undefined)"
            @search-filter="
              () => {
                jobAdList = [];
              }
            "
          />
        </div>
      </div>
      <div class="content">
        <OrgCalendarCard
          v-for="(group, index) of calendarGroups"
          :key="index"
          :label-date="group.labelDate"
          :quant="group.details.length"
          :list="group.details"
          @schedule-click="handleScheduleClick($event)"
        />
        <AppNoData v-if="isNoData" />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
definePageMeta({
  layout: "org",
});

const { getJobAdOrg } = useJobAdApi();
const { getSchedulesGeneral, getScheduleDetail } = useCalendarApi();
const { setLoading } = useLoadingStore();

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

const jobAdList = ref<any>([]);
const filter = ref<any>({});
const calendarGroups = ref<any>([]);
const isNoData = ref<boolean>(false);
const detailId = ref<any>(null);
const isDetailModalShow = ref<boolean>(false);

onBeforeMount(() => {
  filter.value.participationType = participationTypeOpts[2];
  const currentWeek = getLocalWeek();
  filter.value.dateFrom = currentWeek.start;
  filter.value.dateTo = currentWeek.end;
});

const jobAdOpts = computed(() => {
  return jobAdList.value.map((ad: any) => ({
    label: ad.title,
    value: ad.id,
  }));
});

const dateRange = computed(() => {
  const ranges = [];
  if (filter.value.dateFrom) {
    ranges.push(filter.value.dateFrom);
  } else {
    ranges.push(null);
  }

  if (filter.value.dateTo) {
    ranges.push(filter.value.dateTo);
  } else {
    ranges.push(null);
  }

  return ranges;
});

async function fetchJobAds(params: any, controller?: AbortController) {
  const newParams: any = {};
  if (params.name) {
    newParams.keyword = params.name;
  }

  const res = await getJobAdOrg(params, controller);
  jobAdList.value = [...jobAdList.value, ...res.data.data];

  return res.data.data;
}

function handleDateRange(value: any) {
  filter.value.dateFrom = value[0];
  filter.value.dateTo = value[1];
}

async function fetchData() {
  setLoading(true);
  const newVal = filter.value;

  const payload: any = {};
  if (newVal.dateFrom) {
    payload.dateFrom = toUtcDateStart(newVal.dateFrom);
  }
  if (newVal.dateTo) {
    payload.dateTo = toUtcDateStart(newVal.dateTo);
  }

  if (newVal.jobAd) {
    payload.jobAdId = newVal.jobAd.value;
  }

  if (newVal.participationType?.value) {
    payload.participationType = newVal.participationType.value;
  }

  const res = await getSchedulesGeneral(payload);
  console.log({ res });
  calendarGroups.value = res.data;
  if (calendarGroups.value.length == 0) {
    isNoData.value = true;
  } else {
    isNoData.value = false;
  }
  setLoading(false);
}

function handleScheduleClick(schedule: any) {
  detailId.value = {
    calendarId: schedule.calendarId,
    candidateInfoId: schedule.candidateInfos[0].id,
  };
  console.log({detailId: detailId.value})
  isDetailModalShow.value = true;

  console.log({ schedule });
}

watch(
  filter,
  async () => {
    await fetchData();
  },
  { immediate: false, deep: true },
);
</script>
<style lang="scss" scoped>
.wrapper {
  overflow: hidden;
  min-height: 0;
  flex: 1;
  border-radius: 8px;
  margin-top: 8px;
  @include box-shadow;
}
.calendar-content {
  background-color: white;
  min-height: calc(100% - 48px - 8px);
  @include box-shadow;
  color: $text-light;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  height: 100%;

  .title {
    font-weight: 700;
    font-size: 16px;
    line-height: 20px;
  }

  .top {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;
    row-gap: 8px;

    :deep(.datepicker-input) {
      min-width: 240px;
    }

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

  .content {
    min-height: 0;
    flex: 1;
    overflow: auto;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
}
</style>
