<template>
  <div class="hot-jobs">
    <div class="title">Tin tuyển dụng</div>
    <AppInputText
      :label="''"
      :required="false"
      :error="''"
      :placeholder="'Tìm kiếm công việc'"
      :value="searchKeyword"
      :is-disabled="false"
      :slim-error="true"
      :title="''"
      class="text-input"
      @input="($event) => (searchKeyword = $event)"
    >
      <template #input-icon>
        <Icon name="material-symbols:search-rounded" class="mag-icon" />
      </template>
    </AppInputText>
    <div class="content">
      <JobsListsCard
        v-for="job of jobs"
        :key="job.id"
        :data="job"
        :allow-preview="false"
        @click="handleViewDetail(job)"
      />
      <div v-if="isLoading" class="spinner">
        <AppSpinnerHalfCircle />
      </div>
    </div>
    <div v-if="!isLoading && !isEmpty" class="show-more" @click="handleFetchNextPage">Hiển thị thêm</div>
  </div>
</template>
<script setup lang="ts">
import { debounce } from "lodash";

const { getJobAds } = useJobsSearchApi();

const isLoading = ref<boolean>(false);
const controller = ref<AbortController | null>(null);
const jobs = ref<any>([]);
const currentPage = ref<any>(1);
const router = useRouter();
const route = useRoute();

const searchKeyword = ref<string>("");
const isEmpty = ref<boolean>(false);

onBeforeMount(async () => {
  await fetchData();
});

async function fetchData() {
  isLoading.value = true;

  if (controller.value) {
    controller.value.abort();
  }

  controller.value = new AbortController();

  const payload: any = {
    pageIndex: currentPage.value - 1,
    pageSize: 20,
    orgId: route.params.id as string,
  };

  if (searchKeyword.value.trim()) {
    payload.keyword = searchKeyword.value.trim();
  }

  const res = await getJobAds(payload, controller.value);
  jobs.value = [...jobs.value, ...res.data.data.data];
  if (res.data.data.data.length == 0) {
    isEmpty.value = true;
  } else {
    isEmpty.value = false;
  }

  isLoading.value = false;
}

function handleFetchNextPage() {
  currentPage.value += 1;
  fetchData();
}

function handleViewDetail(job: any) {
  const link = router.resolve({ path: `/job-ad/detail/${job.id}` });
  window.open(link.href, "_blank");
}

const debouncedSearch = debounce(async () => {
  jobs.value = [];
  currentPage.value = 1;
  await fetchData();
}, 500);

watch(searchKeyword, (val) => {
  console.log("changed");
  debouncedSearch();
});
</script>
<style lang="scss" scoped>
.hot-jobs {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-bottom: 36px;

  .show-more {
    text-align: center;
    cursor: pointer;
    text-decoration: underline;
    color: $color-primary-500;
    font-size: 14px;
    margin-top: 12px;
  }

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

    max-width: 100%;
    width: 100%;
    @media (max-width: 1186px) {
      max-width: 100%;
      width: 100%;
    }

    :deep(.job-card) {
      max-width: calc((100% - 16px) / 3);
      min-width: calc((100% - 16px) / 3);

      @media (max-width: 1186px) {
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
