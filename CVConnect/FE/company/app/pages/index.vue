<template>
  <div class="home">
    <div class="content">
      <HomeSearchSection @search="handleSearch" />
      <HomeRecommendedJob v-if="userInfo != null" />
      <HomeHotJobs />
      <HomeHotOrgs />
    </div>
    <AppFooter />
  </div>
</template>
<script setup lang="ts">
definePageMeta({
  layout: "public",
});

const router = useRouter();

const jobsSearchStore = useJobsSearchStore();
const { filter } = storeToRefs(jobsSearchStore);
const { setFilter } = jobsSearchStore;
const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);

function handleSearch(payload: any) {
  const newFilter: any = {
    ...filter.value,
    keyword: payload.keyword,
    searchOrg: payload.searchOrg,
  }

  setFilter(newFilter);
  router.push({
    path: "/jobs",
    query: { keyword: filter.value.keyword ?? "", searchOrg: "" },
  });
}
</script>
<style lang="scss" scoped>
.home {
  overflow: auto;
  .content {
    min-height: calc(100vh - 54px);
    padding-bottom: 128px;
  }
}
</style>
