<template>
  <div class="job-card">
    <ModalsApply
      v-model="isApplyModalOpen"
      :job-ad="props.data"
      @submit="handleApplyModalSubmit"
    />
    <div class="top">
      <div class="title">
        {{ props.data.title }}
      </div>
      <div class="right">
        <div class="due-date">{{ props.data.dueDateStr }}</div>
        <div class="salary">{{ props.data.salaryStr }}</div>
      </div>
    </div>
    <div class="company-info row">
      <div class="logo">
        <img :src="props.data.org?.logoUrl" alt="Logo công ty" />
      </div>
      <div class="info-block">
        <div class="name">
          {{ props.data.org?.name }}
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
        <div class="name">{{ props.data.position?.name }}</div>
      </div>
      <div class="row">
        <div v-if="location" class="location row" :title="locationTooltip">
          <Icon name="material-symbols:location-on-outline-rounded" />
          <div class="name">{{ location }}</div>
        </div>
      </div>
      <div
        v-if="props.allowPreview || props.allowApply"
        class="row ml-auto flex-wrap mt-auto"
      >
        <AppButton
          v-if="props.allowPreview"
          :text="'Xem nhanh'"
          class="preview-btn"
          @click.stop="handlePreview"
        />
        <AppButton
          v-if="props.data.dueDateStr != 'Đã hết hạn' && props.allowApply"
          :text="'Ứng tuyển'"
          class="apply-btn"
          @click.stop="handleApply"
        />
      </div>
    </div>
    <!-- <div class="divider"></div> -->
    <!-- <div class="benefit row"> -->
    <!--   <div class="content" v-html="props.data.benefit"></div> -->
    <!-- </div> -->
  </div>
</template>
<script setup lang="ts">
type TProps = {
  data: any;
  allowPreview?: boolean;
  allowApply?: boolean;
};

const props = withDefaults(defineProps<TProps>(), {
  allowPreview: true,
  allowApply: true,
});

const router = useRouter();
const jobsSearchStore = useJobsSearchStore();
const { setSelectedJob } = jobsSearchStore;

const isApplyModalOpen = ref<boolean>(false);

const location = computed(() => {
  if (!props.data.workLocations || props.data.workLocations.length == 0) {
    return "";
  }

  if (props.data.workLocations.length <= 2) {
    return props.data.workLocations.map((loc: any) => loc.province).join(", ");
  }

  const showStr = props.data.workLocations
    .map((loc: any) => loc.province)
    .join(", ");
  const countRest = props.data.workLocations.length - 2;
  return `${showStr} và ${countRest} địa điểm khác.`;
});

const locationTooltip = computed(() => {
  const showStr = props.data.workLocations
    .map((loc: any) => loc.province)
    .join(", ");
  return showStr;
});

const tags = computed(() => {
  return props.data.tags?.slice(0, 4) || [];
});

function handleApply() {
  isApplyModalOpen.value = true;
}

function handlePreview() {
  setSelectedJob(props.data);
}

function handleViewOrg() {
  const link = router.resolve({ path: `/org-profile/${props.data.org.id}` });
  window.open(link.href, "_blank");
}

function handleApplyModalSubmit() {
  isApplyModalOpen.value = false;
}
</script>
<style lang="scss" scoped>
.job-card {
  display: flex;
  flex-direction: column;
  gap: 4px;
  color: $text-light;
  padding: 8px;
  @include box-shadow;
  cursor: pointer;
  background-color: white;
  border-radius: 6px;
  border: 1px solid white;

  .external-link {
    display: inline-block !important;
    color: $color-info;
    cursor: pointer;
  }

  .apply-btn {
    background-color: $color-primary-400;
    border: 1px solid $color-primary-400;
    min-width: fit-content;
    font-size: 14px;
    margin-left: auto;
    color: $text-dark;
    padding: 4px 0px;
    align-self: flex-end;
    width: 104px;
  }

  .preview-btn {
    background-color: white;
    border: 1px solid $color-primary-400;
    min-width: fit-content;
    font-size: 14px;
    margin-left: auto;
    color: $color-primary-400;
    padding: 4px 0px;
    align-self: flex-end;
    width: 104px;
  }

  .top {
    width: 100%;
    display: flex;
    flex-direction: row;
    gap: 8px;
    justify-content: space-between;

    .right {
      display: flex;
      flex-direction: column-reverse;
      flex-wrap: wrap;
      gap: 2px;
      min-width: fit-content;
      justify-content: flex-end;

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

  .divider {
    display: block;
    width: 100%;
    height: 1px;
    background-color: $color-gray-200;
  }

  .block {
    display: flex;
    flex-direction: column;
    gap: 4px;
    color: $text-light;
    flex: 1;
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
    margin-right: 16px;
    .iconify {
      color: $color-gray-600;
    }

    .name {
      color: $color-gray-600;
      font-weight: 400;
    }
  }
}
</style>
