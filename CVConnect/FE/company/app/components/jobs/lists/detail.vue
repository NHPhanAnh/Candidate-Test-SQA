<template>
  <div class="detail">
    <div v-if="isLoading" class="spinner">
      <AppSpinnerHalfCircle />
    </div>
    <template v-else>
      <div class="job-card">
        <div class="top">
          <div class="title">
            <span class="title-span">
              {{ info.title }}
              <Icon
                class="external-link"
                name="ci:external-link"
                @click.stop="handleViewDetail"
              />
            </span>
          </div>
          <div class="top-right">
            <div class="right">
              <div class="due-date">{{ info.dueDateStr }}</div>
              <div class="salary">{{ info.salaryStr }}</div>
            </div>

            <div class="control">
              <Icon
                name="material-symbols:close-rounded"
                @click="() => setSelectedJob(null)"
              />
            </div>
          </div>
        </div>
        <div class="company-info row">
          <div class="logo">
            <img :src="info.org?.logoUrl" alt="Logo công ty" />
          </div>
          <div class="info-block">
            <div class="name">
              {{ info.org?.name }}
              <Icon
                class="external-link"
                name="ci:external-link"
                @click.stop="handleViewOrg"
              />
            </div>
            <div class="tags">
              <div v-for="(tag, index) of tags" :key="index" class="tag">
                {{ tag }}
              </div>
            </div>
          </div>
        </div>
        <div class="divider"></div>
        <div class="block">
          <div class="position row">
            <Icon name="majesticons:suitcase-2-line" />
            <div class="name">{{ info.position?.name }}</div>
          </div>
          <div class="level row">
            <div class="left">
              <Icon name="material-symbols:account-tree-outline-rounded" />
              <span>Cấp bậc</span>
            </div>
            <div class="level-tags">
              <div
                v-for="(tag, index) of levelTags"
                :key="index"
                class="level-tag"
              >
                {{ tag }}
              </div>
            </div>
          </div>
          <div v-if="location" class="location row" :title="locationTooltip">
            <Icon name="material-symbols:location-on-outline-rounded" />
            <div class="name">{{ location }}</div>
          </div>
        </div>
        <div class="row w-full">
          <AppButton
            v-if="info.dueDateStr != 'Đã hết hạn'"
            :text="'Ứng tuyển'"
            class="apply-btn"
            @click.stop="handleApply"
          />
        </div>
        <div class="divider"></div>
        <div class="content">
          <div class="text-block">
            <div class="label">Mô tả công việc</div>
            <div
              v-if="info.description"
              class="text-content"
              v-html="info.description"
            />
            <div v-else class="text-content empty" v-html="'Không có'" />
          </div>

          <div class="text-block">
            <div class="label">Yêu cầu công việc</div>
            <div
              v-if="info.requirement"
              class="text-content"
              v-html="info.requirement"
            />
            <div v-else class="text-content empty" v-html="'Không có'" />
          </div>

          <div class="text-block">
            <div class="label">Quyền lợi</div>
            <div
              v-if="info.benefit"
              class="text-content"
              v-html="info.benefit"
            />
            <div v-else class="text-content empty" v-html="'Không có'" />
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
<script setup lang="ts">
const router = useRouter();

const jobsSearchStore = useJobsSearchStore();
const { setSelectedJob } = jobsSearchStore;
const { selectedJob } = storeToRefs(jobsSearchStore);
const { getJobAdPreview } = useJobsSearchApi();

const controller = ref<AbortController | null>(null);
const isLoading = ref<boolean>(false);
const info = ref<any>({});

const tags = computed(() => {
  return info.value.tags?.slice(0, 4) || [];
});

const levelTags = computed(() => {
  const levelTagsArr = [];
  if (info.value.isAllLevel) {
    levelTagsArr.push("Tất cả");
  } else {
    for (const lvl of info.value.levels) {
      levelTagsArr.push(lvl.name);
    }
  }

  return levelTagsArr;
});

const location = computed(() => {
  if (!info.value.workLocations || info.value.workLocations.length == 0) {
    return "";
  }

  if (info.value.workLocations.length <= 2) {
    return info.value.workLocations.map((loc: any) => loc.province).join(", ");
  }

  const showStr = info.value.workLocations
    .map((loc: any) => loc.province)
    .join(", ");
  const countRest = info.value.workLocations.length - 2;
  return `${showStr} và ${countRest} địa điểm khác.`;
});

const locationTooltip = computed(() => {
  const showStr = info.value.workLocations
    .map((loc: any) => loc.province)
    .join(", ");
  return showStr;
});

function handleApply() {
  console.log("apply");
}

function handleViewOrg() {
  const link = router.resolve({ path: `/org-profile/${info.value.org.id}` });
  window.open(link.href, "_blank");
}

function handleViewDetail() {
  const link = router.resolve({
    path: `/job-ad/detail/${selectedJob.value.id}`,
  });
  window.open(link.href, "_blank");
}

watch(
  () => selectedJob.value,
  async (job) => {
    if (job) {
      isLoading.value = true;

      if (controller.value) {
        controller.value.abort();
      }
      controller.value = new AbortController();

      const res = await getJobAdPreview(job.id, controller.value);
      info.value = res.data;

      isLoading.value = false;
    }
  },
  { immediate: true, deep: true },
);
</script>
<style lang="scss" scoped>
.detail {
  position: sticky;
  max-height: calc(100vh - 54px - 8px - 8px);
  top: 8px;
  padding: 12px;
  border-radius: 12px;
  background-color: white;
  @include box-shadow;

  .spinner {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 84px;
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;
  }

  .iconify {
    color: $color-gray-600;
    font-size: 20px;
    display: block;
    height: 20px;
    width: 20px;
    min-width: 20px;
  }

  .control {
    display: flex;
    justify-content: flex-end;

    .iconify {
      cursor: pointer;
    }
  }

  display: flex;
  flex-direction: column;
  gap: 8px;

  .job-card {
    max-height: 100%;
    display: flex;
    flex-direction: column;
    gap: 4px;
    color: $text-light;

    .external-link {
      display: inline-block !important;
      color: $color-info;
      cursor: pointer;
    }

    .apply-btn {
      background-color: $color-primary-400;
      border: 1px solid $color-primary-400;
      font-size: 14px;
      margin-left: auto;
      color: $text-dark;
      padding: 4px 0px;
      align-self: flex-end;
      width: 100%;
    }

    .top {
      width: 100%;
      display: flex;
      flex-direction: row;
      gap: 8px;
      justify-content: space-between;

      .top-right {
        display: flex;
        flex-direction: row;
        align-items: flex-start;
        gap: 8px;
        min-width: fit-content;

        .right {
          display: flex;
          flex-direction: row;
          align-items: flex-start;
          gap: 8px;
          min-width: fit-content;

          .due-date {
            color: $color-gray-400;
            font-size: 13px;
            min-width: fit-content;
          }

          .salary {
            color: $color-gray-700;
            font-weight: 600;
            font-size: 13px;
            min-width: fit-content;
          }
        }
      }
    }

    .block {
      display: flex;
      flex-direction: column;
      gap: 4px;
      color: $text-light;
    }

    .iconify {
      display: block;
      font-size: 16px;
      height: 16px;
      width: 16px;
      min-width: 16px;
    }

    .posted-time {
      text-align: right;
      width: 100%;
      color: $color-gray-400;
      font-size: 12px;
    }

    .title {
      font-size: 14px;
      font-weight: 600;

      .title-span {
        margin-right: 4px;
      }
    }

    .row {
      display: flex;
      flex-direction: row;
      gap: 8px;
      align-items: center;
      font-size: 13px;
    }

    .company-info {
      align-items: flex-start !important;
      .logo {
        display: block;
        height: 48px;
        width: 48px;
        min-width: 48px;
        border-radius: 12px;
        overflow: hidden;
        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
          border-radius: inherit;
        }
      }

      .info-block {
        display: flex;
        flex-direction: column;
        gap: 4px;

        .name {
          color: $text-light;
          font-weight: 500;
        }

        .tags {
          display: flex;
          flex-direction: row;
          flex-wrap: wrap;
          gap: 8px;

          .tag {
            padding: 2px 10px;
            border: 1px solid $color-gray-300;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 500;
          }
        }
      }
    }

    .position {
      .iconify {
        color: $color-gray-600;
      }

      .name {
        color: $color-gray-600;
        font-weight: 400;
      }
    }

    .location {
      .iconify {
        color: $color-gray-600;
      }

      .name {
        color: $color-gray-600;
        font-weight: 400;
      }
    }

    .level {
      align-items: flex-start;

      .left {
        display: flex;
        flex-direction: row;
        gap: 8px;
        margin-top: 2px;
        align-items: center;
        color: $color-gray-600;
        .iconify {
          color: $color-gray-600;
        }
      }

      .level-tags {
        display: flex;
        flex-direction: row;
        gap: 4px;
        flex-wrap: wrap;

        .level-tag {
          padding: 2px 8px;
          border: 1px solid $color-gray-300;
          font-weight: 400;
          font-size: 13px;
          border-radius: 999px;
        }
      }
    }
  }

  .divider {
    display: block;
    width: 100%;
    height: 1px;
    background-color: $color-gray-200;
  }

  .content {
    flex: 1;
    overflow-y: auto;
    min-height: 0;
    display: flex;
    flex-direction: column;
    gap: 8px;

    .text-block {
      display: flex;
      flex-direction: column;
      gap: 4px;

      .label {
        font-size: 14px;
        font-weight: 600;
      }

      :deep(.text-content) {
        color: $text-light;
        font-size: 14px;

        &.empty {
          color: $color-gray-400;
          font-size: 14px;
          font-style: italic;
        }
      }
    }
  }
}
</style>
