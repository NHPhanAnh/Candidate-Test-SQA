<template>
  <div class="job-ad-detail">
    <div class="content">
      <div class="wrapper">
        <div class="title">Tin đã ứng tuyển</div>
        <div class="filter">
          <AppInputText
            :label="''"
            :required="false"
            :error="''"
            :placeholder="'Tìm kiếm'"
            :value="filter.keyword ?? ''"
            :slim-error="true"
            class="search-bar"
            @input="handleInputDebounce('keyword', $event)"
          >
            <template #input-icon>
              <Icon name="material-symbols:search-rounded" class="mag-icon" />
            </template>
          </AppInputText>
          <AppInputSearchSelect
            class="job-ad-status-select"
            :label="''"
            :required="true"
            :options="candidateStatusOpts"
            :value="filter.candidateStatus"
            :error="''"
            :slim-error="true"
            :placeholder="'Trạng thái'"
            :remote-filter="false"
            :allow-clear="true"
            :multiple="false"
            :fetch-fn="null"
            @input="handleInput('candidateStatus', $event)"
            @clear-value="filter.candidateStatus = undefined"
          />
          <div class="count">{{ `${total} tin` }}</div>
        </div>
        <div class="applied-jobs-list">
          <JobsAppliedCard
            v-for="jobAd of list"
            :key="jobAd.id"
            :data="jobAd"
          />
          <div v-if="isLoading" class="spinner">
            <AppSpinnerHalfCircle />
          </div>
          <AppNoData v-if="list.length == 0 && !isLoading" />
          <div v-if="!isEmpty && !isLoading" class="show-more" @click="handleShowMore">Hiển thị thêm</div>
        </div>
      </div>
    </div>
    <AppFooter />
  </div>
</template>
<script setup lang="ts">
import { debounce } from "lodash";
import { CANDIDATE_STATUS } from "~/const/views/org/candidates";

definePageMeta({
  layout: "public",
});

const router = useRouter();
const route = useRoute();

const { setLoading } = useLoadingStore();
const { getAppliedJobAds } = useCandidateApi();

const filter = ref<any>({
  keyword: "",
  candidateStatus: undefined,
});
const currentPage = ref<any>(0);
const list = ref<any>([]);
const isLoading = ref<boolean>(false);
const isEmpty = ref<boolean>(false);
const total = ref<any>(0);

onBeforeMount(async () => {
  await fetchData();
});

const candidateStatusOpts = computed(() => {
  const opts = Object.keys(CANDIDATE_STATUS).map((key: string) => {
    return {
      label: CANDIDATE_STATUS[key].label,
      value: key,
    };
  });
  return opts;
});

async function fetchData() {
  isLoading.value = true;
  const payload: any = {
    pageIndex: currentPage.value,
  };
  if (filter.value.keyword.trim()) {
    payload.keyword = filter.value.keyword.trim();
  }
  if (filter.value.candidateStatus) {
    payload.candidateStatus = filter.value.candidateStatus.value;
  }
  const res = await getAppliedJobAds(payload);
  console.log({ res });
  if (!res) {
    isLoading.value = false;
    return;
  }
  list.value = [...list.value, ...res.data.data];
  
  if (res.data.data.length) {
    isEmpty.value = false;
  } else {
    isEmpty.value = true;
  }
  isLoading.value = false;
}

const debounced = debounce((key: string, value: any) => {
  filter.value[key] = value;
}, 300);

function handleInputDebounce(key: string, value: any) {
  debounced(key, value);
}

function handleInput(key: string, value: any) {
  filter.value[key] = value;
}

function handleShowMore() {
  currentPage.value += 1;
  fetchData();
}

watch(
  filter,
  (newVal) => {
    currentPage.value = 0;
    list.value = [];
    fetchData();
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.job-ad-detail {
  overflow: auto;
  min-height: calc(100vh - 54px);
  display: flex;
  flex-direction: column;

  .content {
    flex: 1;
    width: 100%;

    margin: 0 auto;

    padding-top: 12px;
    padding-bottom: 128px;
    min-height: calc(100vh - 54px);

    max-width: min(75%, 1080px);
    width: min(75%, 1080px);
    @media (max-width: 768px) {
      max-width: 100%;
      width: 100%;
    }
    display: flex;
    flex-direction: row;
    gap: 8px;
    min-height: fit-content;

    .wrapper {
      background-color: white;
      padding: 12px;
      border-radius: 12px;
      width: 100%;
      @include box-shadow;
      display: flex;
      flex-direction: column;
      gap: 12px;

      .title {
        font-weight: 700;
        font-size: 16px;
        line-height: 20px;
      }

      .filter {
        display: flex;
        flex-direction: row;
        gap: 12px;
        align-items: center;
        flex-wrap: wrap;
        background-color: white;

        .count {
          color: $color-gray-400;
          font-style: italic;
          font-size: 14px;
        }

        .right {
          display: flex;
          flex-direction: row;
          gap: 12px;
          align-items: center;
          flex-wrap: wrap;
        }

        .filter-btn,
        .sort-btn {
          background-color: $color-gray-100;
          border-radius: 999px;
          cursor: pointer;
          height: 36px;
          width: 36px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: $color-primary-500;
          .iconify {
            display: block;
            font-size: 20px;
          }
        }

        .search-bar {
          width: 360px;
          :deep(.input) {
            padding: 6px 8px;
            input {
              font-size: 14px;
            }
          }
        }

        .job-ad-status-select {
          max-width: 180px;
          width: 180px;
          min-width: 180px;
        }
      }

      .applied-jobs-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
        width: 100%;

        .spinner {
          height: 24px;
          width: 100%;
          display: flex;
          justify-content: center;
          align-items: center;
        }

        .show-more {
          height: 24px;
          width: 100%;
          display: flex;
          justify-content: center;
          align-items: center;

          font-size: 14px;
          color: $color-primary-500;
          text-decoration: underline;
          cursor: pointer;
        }
      }
    }
  }
}
</style>
