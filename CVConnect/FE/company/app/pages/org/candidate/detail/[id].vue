<template>
  <div class="wrapper">
    <div class="top">
      <div class="back-btn" @click="router.push({ path: '/org/candidate' })">
        <Icon name="material-symbols:chevron-left-rounded" />
      </div>
      <div class="personal-information">
        <AppAvatar v-if="userInfo" :user-info="userInfo" />
        <span class="name">{{ userInfo?.fullName }}</span>
      </div>
    </div>
    <div v-if="detail" class="content">
      <OrgCandidateInfoLeft :detail="detail" @refetch="fetchData" />
      <div class="vert-divider"></div>
      <OrgCandidateInfoRight :detail="detail" />
    </div>
  </div>
</template>
<script lang="ts" setup>
import { DETAIL_BASE_BREADCRUMBS } from "~/const/views/org/candidates";

definePageMeta({
  layout: "org",
});

const detail = ref<Record<string, any> | null>(null);

const route = useRoute();
const router = useRouter();

const { getJobAdCandidateDetail } = useCandidateApi();
const { setLoading } = useLoadingStore();
const breadcrumbStore = useBreadcrumbStore();
const { overrideItems, clearOverrideItems } = breadcrumbStore;

onBeforeMount(async () => {
  await fetchData();
  overrideItems([
    ...DETAIL_BASE_BREADCRUMBS,
    {
      name: detail.value?.candidateInfo.fullName,
      icon: "",
      url: "/org/candidate/detail/" + detail.value?.candidateInfo.id,
    },
  ]);
});

async function fetchData() {
  setLoading(true);
  const candidateId = route.params.id;
  if (!candidateId || candidateId == undefined) {
    setLoading(false);
    router.push("/404");
    return;
  }
  const res = await getJobAdCandidateDetail(+candidateId);
  detail.value = res.data;
  document.title = `${detail.value?.candidateInfo.fullName} - CVConnect`;
  console.log(res);
  setLoading(false);
}

const userInfo = computed(() => {
  if (!detail.value) {
    return null;
  }

  return {
    avatarUrl: detail.value.candidateInfo.avatarUrl,
    fullName: detail.value.candidateInfo.fullName,
    id: detail.value.candidateInfo.id,
  };
});

onBeforeUnmount(() => {
  clearOverrideItems();
});
</script>
<style lang="scss" scoped>
.wrapper {
  overflow: hidden;
  min-height: 0;
  flex: 1;
  border-radius: 8px;
  margin-top: 8px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  @include box-shadow;
  padding: 12px;
  background-color: #ffffff;

  .vert-divider {
    height: 100%;
    width: 1px;
    display: block;
    background-color: $color-gray-200;
  }

  .top {
    display: flex;
    flex-direction: row;
    gap: 12px;
    align-items: center;
    :deep(.avatar) {
      width: 40px;
      height: 40px;
    }

    .back-btn {
      background-color: $color-gray-100;
      height: 32px;
      width: 32px;
      border-radius: 999px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;

      .iconify {
        font-size: 20px;
        display: block;
        width: 20px;
      }
    }

    .personal-information {
      display: flex;
      flex-direction: row;
      gap: 12px;
      align-items: center;

      .name {
        font-weight: 500;
        font-size: 18px;
      }
    }
  }

  .content {
    display: flex;
    flex-direction: row;
    gap: 12px;
    min-height: 0;
    flex: 1;
    border-top: 1px solid $color-gray-200;
    border-bottom: 1px solid $color-gray-200;
    max-height: 100%;

    .left {
      width: 30%;
    }

    .right {
      width: 70%;
    }

    @media (min-width: 880px) {
      .left,
      .right {
        overflow-y: auto;
        max-height: 100%;
      }
    }

    @media (max-width: 880px) {
      flex-direction: column;
      overflow-y: auto;
      .vert-divider {
        height: 1px;
        width: 100%;
      }

      .left,
      .right {
        width: 100%;
      }
    }
  }
}
</style>
