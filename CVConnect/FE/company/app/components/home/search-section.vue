<template>
  <div class="search-section">
    <div class="inner">
      <div class="decoration">
        <div class="title">Kết nối tới nhà tuyển dụng</div>
        <div class="sub">miễn phí ngay với CVConnect</div>
      </div>
      <div v-on-click-outside="handleClickOutside" class="search-bar">
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
          @enter="handleSearch"
          @focus="handleFocusInput"
        >
          <template #input-icon>
            <Icon name="material-symbols:search-rounded" class="mag-icon" />
          </template>
        </AppInputText>
        <AppButton
          :text="'Tìm kiếm ngay'"
          class="search-btn"
          @click="handleSearch"
        >
          <template #icon>
            <Icon name="material-symbols:search-rounded" class="search-icon" />
          </template>
        </AppButton>
        <div v-if="isPopoverShow" class="popover">
          <div class="top">
            <UCheckbox
              :model-value="localSearchOrg"
              :label="'Tìm kiếm theo tên doanh nghiệp'"
              class="checkbox cursor-pointer"
              @update:model-value="localSearchOrg = $event as boolean"
            />
            <div v-if="historyList.length" class="delete-all" @click="handleDeleteAll">Xóa tất cả</div>
          </div>
          <template v-if="historyList.length">
            <div class="history-list">
              <div
                v-for="(keyword, index) of historyList"
                :key="index"
                class="keyword"
              >
                <div class="text" @click="handleSetKeyword(keyword.keyword)">
                  {{ keyword.keyword }}
                </div>
                <Icon
                  name="material-symbols:close-rounded"
                  @click="handleDeleteKeyword(keyword.id)"
                />
              </div>
            </div>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { vOnClickOutside } from "@vueuse/components";

definePageMeta({
  layout: "public",
});

const emits = defineEmits<{
  (e: "search", payload: any): void;
}>();

const searchKeyword = ref<string>("");
const isPopoverShow = ref<boolean>(false);
const localSearchOrg = ref<boolean>(false);
const controller = ref<any>(null);
const historyList = ref<any>([]);

const jobsSearchStore = useJobsSearchStore();
const { filter } = storeToRefs(jobsSearchStore);
const { getHistory, deleteHistory, deleteAllHistory } = useSearchHistoryApi();
const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);

function handleSearch() {
  emits("search", {
    keyword: searchKeyword.value,
    searchOrg: localSearchOrg.value,
  });
  isPopoverShow.value = false;
}

function handleClickOutside() {
  isPopoverShow.value = false;
}

function handleFocusInput() {
  isPopoverShow.value = true;
}

function handleSetKeyword(keyword: string) {
  searchKeyword.value = keyword;
  handleSearch();
}

async function fetchHistory() {
  if (controller.value) {
    controller.value.abort();
  }

  controller.value = new AbortController();
  const res = await getHistory(controller.value);
  historyList.value = res.data;
}

async function handleDeleteKeyword(id: any) {
  historyList.value = historyList.value.filter(
    (keyword: any) => keyword.id != id,
  );
  deleteHistory(id);
}

async function handleDeleteAll() {
  historyList.value = [];
  deleteAllHistory();
}

watch(
  filter,
  (newFilter) => {
    searchKeyword.value = newFilter?.keyword ?? "";
  },
  { immediate: true },
);

watch(isPopoverShow, (val) => {
  if (val) {
    localSearchOrg.value = filter.value.searchOrg;
    if (userInfo.value != null) {
      fetchHistory();
    }
  }
});
</script>
<style lang="scss" scoped>
.search-section {
  padding: 48px 0px 84px 0px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #7a0c0c;
  background: linear-gradient(
    103deg,
    rgba(122, 12, 12, 1) 0%,
    rgba(0, 0, 0, 1) 100%,
    rgba(237, 221, 83, 1) 100%
  );

  flex-direction: column;
  gap: 8px;

  .inner {
    width: calc(75% - 16px);
    max-width: min(calc(75% - 16px), 1064px);
    @media (max-width: 768px) {
      max-width: calc(100% - 32px);
      width: calc(100% - 32px);
    }
    display: flex;
    flex-direction: column;
    gap: 8px;

    :deep(.input) {
      background: white;
      border-radius: 4px;
      border: none;
      &:hover:not(.disabled),
      &:focus-within:not(.disabled) {
        border: none;
      }
    }

    .decoration {
      .title {
        display: inline;
        color: $text-dark;
        font-weight: 600;
        font-size: 24px;
      }
      .sub {
        display: inline;
        color: $text-dark;
        font-weight: 400;
        font-size: 14px;
        margin-left: 8px;
      }
    }

    .search-bar {
      width: 100%;
      display: flex;
      flex-direction: row;
      gap: 12px;

      position: relative;

      .popover {
        top: 46px;
        position: absolute;
        background-color: white;
        padding: 12px;
        @include box-shadow;
        width: calc(100% - 182px);
        border-radius: 4px;
        z-index: 2;

        .top {
          display: flex;
          flex-direction: row;
          justify-content: space-between;
          gap: 8px;
        }

        .delete-all {
          font-size: 14px;
          color: $color-primary-500;
          cursor: pointer;
        }

        .checkbox {
          :deep(button) {
            cursor: pointer;

            &:disabled {
              cursor: default;
            }
          }

          :deep(label) {
            font-size: 14px;
            line-height: 21px;
            font-weight: 400;
            color: $text-light;
            cursor: pointer;

            &.cursor-not-allowed {
              cursor: default;
            }
          }
        }

        .history-list {
          display: flex;
          flex-direction: column;
          padding: 4px 0px;
          gap: 4px;

          .keyword {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            .text {
              font-size: 13px;
              font-weight: 500;
              color: $text-light;
              cursor: pointer;
              flex: 1;
              word-break: break-all;
            }
            .iconify {
              font-size: 20px;
              display: block;
              width: 20px;
              height: 20px;
              min-width: 20px;
              cursor: pointer;
              color: $color-gray-300;

              &:hover {
                color: $color-gray-400;
              }
            }
          }
        }
      }

      .text-input {
        flex: 1;
      }

      .mag-icon {
        display: block;
        font-size: 14px;
        height: 20px;
        width: 20px;
        color: $color-gray-400;
      }

      .search-icon {
        display: block;
        font-size: 20px;
        height: 20px;
        width: 20px;
        color: white;
      }

      .search-btn {
        background-color: $color-primary-400;
        color: $text-dark;
        height: 42px;
      }
    }
  }
}
</style>
