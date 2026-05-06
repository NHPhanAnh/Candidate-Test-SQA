<template>
  <div v-if="isLoading || jobs.length > 0" class="recommended-jobs">
    <div class="title">
      <Icon name="fluent-color:lightbulb-checkmark-32" />
      Việc làm thích hợp cho bạn
    </div>
    <div class="content">
      <div v-if="isLoading" class="spinner">
        <AppSpinnerHalfCircle />
      </div>
      <JobsListsCard
        v-for="job of jobs"
        :key="job.id"
        :data="job"
        :allow-preview="false"
        :allow-apply="false"
        @click="handleViewDetail(job)"
      />
    </div>
    <div class="paginator">
      <UPagination
        :show-edges="true"
        :sibling-count="1"
        :variant="'ghost'"
        active-variant="subtle"
        :items-per-page="20"
        :page="currentPage"
        :total="pageInfo.totalElements"
        @update:page="handlePageIndexChange($event)"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
const { getRecommendedJobAds } = useJobsSearchApi();

const isLoading = ref<boolean>(false);
const controller = ref<AbortController | null>(null);
const jobs = ref<any>([]);
const pageInfo = ref<any>({});
const currentPage = ref<any>(1);
const router = useRouter();

onBeforeMount(async () => {
  await fetchData();
});

async function fetchData() {
  isLoading.value = true;

  if (controller.value) {
    controller.value.abort();
  }

  controller.value = new AbortController();

  const res = await getRecommendedJobAds(
    { pageIndex: currentPage.value - 1, pageSize: 20 },
    controller.value,
  );
  jobs.value = res.data.data;
  pageInfo.value = res.data.pageInfo;

  isLoading.value = false;
}

function handlePageIndexChange(page: any) {
  currentPage.value = page;
  fetchData();
}

function handleViewDetail(job: any) {
  const link = router.resolve({ path: `/job-ad/detail/${job.id}` });
  window.open(link.href, "_blank");
}
</script>
<style lang="scss" scoped>
.recommended-jobs {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-bottom: 36px;

  .title {
    background-color: $color-gray-100;
    border-top: 1px solid $color-gray-300;
    border-bottom: 1px solid $color-gray-300;
    padding: 16px 0px;
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;
    justify-content: center;

    font-size: 20px;
    font-weight: 600;

    .iconify {
      display: inline-block;
      font-size: 24px;
      height: 24px;
      width: 24px;
      color: $color-primary-400;
    }
  }

  .content {
    display: flex;
    flex-direction: row;
    gap: 8px;
    row-gap: 8px;
    flex-wrap: wrap;

    margin: 0px auto;

    max-width: min(75%, 1080px);
    width: min(75%, 1080px);
    @media (max-width: 768px) {
      max-width: 100%;
      width: 100%;
    }

    :deep(.job-card) {
      max-width: calc((100% - 16px) / 3);
      min-width: calc((100% - 16px) / 3);

      @media (max-width: 1000px) {
        max-width: calc((100% - 8px) / 2);
        min-width: calc((100% - 8px) / 2);
      }
    }

    .spinner {
      width: 100%;
      height: 84px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }

  .paginator {
    display: flex;
    justify-content: center;
  }
}
</style>
