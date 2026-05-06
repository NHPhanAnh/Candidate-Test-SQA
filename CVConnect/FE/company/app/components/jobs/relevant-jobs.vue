<template>
  <div class="wrapper">
    <div class="title">Việc làm liên quan</div>
    <div v-if="isLoading" class="spinner">
      <AppSpinnerHalfCircle />
    </div>
    <AppNoData v-if="!isLoading && jobs.length == 0" />
    <div class="content">
      <JobsListsCard
        v-for="job of jobs"
        :key="job.id"
        :data="job"
        :allow-preview="false"
        @click="handleViewDetail(job)"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  sourceId: any;
};

const props = defineProps<TProps>();

const { getRelevantJobAds } = useJobsSearchApi();
const router = useRouter();

const isLoading = ref<boolean>(false);
const jobs = ref<any>([]);

onBeforeMount(async () => {
  isLoading.value = true;
  const res = await getRelevantJobAds(props.sourceId);
  jobs.value = res.data;
  console.log({ res });
  isLoading.value = false;
});

function handleViewDetail(job: any) {
  const link = router.resolve({ path: `/job-ad/detail/${job.id}` });
  window.open(link.href, "_blank");
}
</script>
<style lang="scss" scoped>
.wrapper {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
  min-height: 0;

  .title {
    font-size: 14px;
    color: $text-light;
    font-weight: 500;
  }

  .spinner {
    height: 64px;
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .content {
    overflow: auto;
    display: flex;
    flex-direction: column;
    min-height: 0;
    border-top: 1px solid $color-gray-300;
    border-bottom: 1px solid $color-gray-300;

    :deep(.job-card) {
      border-radius: 0px;
      &:not(:first-child) {
        border-top: 1px solid $color-gray-300;
      }
    }
  }
}
</style>
