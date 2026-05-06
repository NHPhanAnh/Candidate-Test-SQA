<template>
  <div class="jobs-list">
    <div class="list">
      <JobsListsCard
        v-for="job of jobsList"
        :key="job.id"
        :data="job"
        :class="{ selected: job.id == selectedJob?.id }"
        @click="handleViewDetail(job)"
      />
      <div v-if="isFetchingJobs" class="spinner">
        <AppSpinnerHalfCircle />
      </div>
      <AppNoData v-if="isNoData && jobsList.length == 0 && !isFetchingJobs" />
      <div
        v-if="!isNoData && !isFetchingJobs"
        class="show-more"
        @click="() => emits('fetchMore')"
      >
        Hiển thị thêm
      </div>
    </div>
    <!-- <div class="detail">detail hien ra day</div> -->
  </div>
</template>
<script setup lang="ts">
const router = useRouter();
const jobsSearchStore = useJobsSearchStore();
const { jobsList, selectedJob, isFetchingJobs, isNoData } =
  storeToRefs(jobsSearchStore);

const emits = defineEmits<{
  (e: "fetchMore"): void;
}>();

function handleViewDetail(job: any) {
  const link = router.resolve({ path: `/job-ad/detail/${job.id}` });
  window.open(link.href, "_blank");
}
</script>
<style lang="scss" scoped>
.jobs-list {
  .list {
    display: flex;
    flex-direction: column;
    gap: 8px;

    .detail {
      position: sticky;
      top: 120px;
    }

    .job-card {
      transition: border 0.2s;
      &.selected {
        border: 1px solid $color-primary-400;
      }
    }
  }

  .spinner {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 21px;
    min-width: 360px;
  }

  .show-more {
    width: 100%;
    text-align: center;
    color: $color-primary-400;
    text-decoration: underline;
    cursor: pointer;
    font-size: 14px;
  }
}
</style>
