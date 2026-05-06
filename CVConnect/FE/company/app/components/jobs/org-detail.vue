<template>
  <div class="org-detail">
    <div class="info-block">
      <div class="top row">
        <div class="logo">
          <img :src="props.data.org?.logoUrl" alt="Logo công ty" />
        </div>
        <div class="name">
          {{ props.data.org?.name }}
        </div>
      </div>
      <div class="row wide">
        <div class="label row">
          <Icon name="i-streamline-plump:office-worker-remix" />
          <span>Quy mô</span>
        </div>
        <div class="value">{{ employeeCount }}</div>
      </div>
      <div class="row wide row-top">
        <div class="label row">
          <Icon name="i-iconoir:suitcase" />
          <span>Lĩnh vực</span>
        </div>
        <div class="tags-list">
          <div
            v-for="(tag, index) of industries"
            :key="index"
            :title="tag.tooltip"
            class="tag"
          >
            {{ tag.label }}
          </div>
        </div>
      </div>
      <div class="row wide row-top">
        <div class="label row">
          <Icon name="i-mdi:web" />
          <span>Trang web</span>
        </div>
        <a :href="props.data.org?.website" target="_blank" class="value link">{{
          props.data.org?.website
        }}</a>
      </div>
      <div class="view-org-detail link" @click="handleViewOrgDetail">
        Xem trang doanh nghiệp
      </div>
    </div>
    <div class="divider"></div>
    <JobsRelevantJobs
      v-if="jobAdId"
      :source-id="jobAdId"
      class="relevant-job"
    />
  </div>
</template>
<script setup lang="ts">
type TProps = {
  data: any;
};

const props = defineProps<TProps>();

const router = useRouter();
const route = useRoute();

const jobAdId = computed(() => {
  const id = route.params.id;
  return id;
});

const employeeCount = computed(() => {
  if (!props.data) {
    return "";
  }

  const from = props.data.org.staffCountFrom;
  const to = props.data.org.staffCountTo;
  if (from && to) {
    return `Từ ${from} đến ${to}`;
  }
  if (!from && to) {
    return `Từ 1 đến ${to}`;
  }
  if (from && !to) {
    return `Trên ${from}`;
  }

  return "";
});

const industries = computed(() => {
  const arr = [];

  for (const indus of props.data.org.industryList) {
    arr.push({
      label: indus.code,
      tooltip: indus.name,
    });
  }

  return arr;
});

function handleViewOrgDetail() {
  const link = router.resolve({ path: `/org-profile/${props.data.org.id}` });
  window.open(link.href, "_blank");
}
</script>
<style lang="scss" scoped>
.org-detail {
  padding: 12px;
  border-radius: 12px;
  background-color: white;
  @include box-shadow;

  .divider {
    width: 100%;
    height: 1px;
    display: block;
    background-color: $color-gray-300;
    margin: 8px 0px;
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;

    &.wide {
      justify-content: space-between;
    }

    &.row-top {
      align-items: flex-start;
    }
  }

  .iconify {
    display: block;
    font-size: 16px;
    height: 16px;
    width: 16px;
    min-width: 16px;
  }

  .label,
  .value {
    color: $color-gray-600;
    font-size: 13px;
  }

  .link {
    cursor: pointer;
    text-decoration: underline;
    color: $color-primary-500;
  }

  .info-block {
    display: flex;
    flex-direction: column;
    gap: 8px;
    font-size: 14px;

    .top {
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

      .name {
        font-weight: 500;
      }
    }

    .tags-list {
      display: flex;
      flex-direction: row;
      gap: 4px;
      flex-wrap: wrap;

      .tag {
        padding: 1px 8px;
        min-width: 36px;
        font-size: 12px;
        font-weight: 500;
        text-align: center;
        border: 1px solid $color-gray-300;
        border-radius: 4px;
      }
    }

    .view-org-detail {
      text-align: right;
    }
  }
}
</style>
