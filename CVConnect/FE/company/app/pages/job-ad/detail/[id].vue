<template>
  <div class="job-ad-detail">
    <div class="content">
      <JobsJobDetail v-if="info != null" class="main-col" :data="info" />
      <JobsOrgDetail v-if="info != null" class="sub-col" :data="info" />
    </div>
    <AppFooter />
  </div>
</template>
<script setup lang="ts">
definePageMeta({
  layout: "public",
});

const router = useRouter();
const route = useRoute();

const { setLoading } = useLoadingStore();
const { getJobAdPreview } = useJobsSearchApi();

const info = ref<any>(null);

onBeforeMount(async () => {
  setLoading(true);
  const id = route.params.id;
  if (!id) {
    router.push({ path: "/404" });
    setLoading(false);
    return;
  }
  const keyCodeInternal = route.query.keyCodeInternal;
  const res = await getJobAdPreview(id, keyCodeInternal);
  info.value = res.data;
  setLoading(false);
});
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

    .main-col {
      width: 60%;
      max-height: calc(100vh - 54px - 12px - 12px);
    }

    .sub-col {
      width: 40%;
      position: sticky;
      top: 12px;
      height: fit-content;
      max-height: calc(100vh - 54px - 12px - 12px);
      display: flex;
      flex-direction: column;
    }
  }
}
</style>
