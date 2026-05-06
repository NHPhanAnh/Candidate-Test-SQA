<template>
  <div class="jobs-result" ref="scroller">
    <HomeSearchSection @search="handleSearch" />
    <JobsTopFilter class="top-filter" @filter="handleFilter" />
    <div class="content">
      <JobsFilter
        v-if="selectedJob == null"
        class="filtter-col"
        :class="{ 'has-filter': selectedJob == null }"
        @filter="handleFilter"
      />
      <JobsList
        class="list-col"
        :class="{ 'has-filter': selectedJob == null }"
        @fetch-more="handleFetchMore"
      />
      <JobsListsDetail
        v-if="selectedJob != null"
        class="detail-col"
        :class="{ 'has-filter': selectedJob == null }"
      />
    </div>
    <AppFooter />
  </div>
</template>
<script setup lang="ts">
import { cloneDeep } from "lodash";
import { SALARY_FILTER } from "~/const/views/public/jobs";

definePageMeta({
  layout: "public",
});

const route = useRoute();
const router = useRouter();

const jobsSearchStore = useJobsSearchStore();
const {
  setFilterOptions,
  setFilter,
  setJobsList,
  setNoData,
  setIsFetchingJobs,
} = jobsSearchStore;
const { filter, filterOptions, selectedJob, jobsList, sort } =
  storeToRefs(jobsSearchStore);
const { getFilter, getJobAds } = useJobsSearchApi();
const currentPage = ref<any>(0);
const controller = ref<AbortController | null>(null);
const scroller = useTemplateRef("scroller");

onBeforeMount(async () => {
  const res = await getFilter();
  res.data.careers = res.data.careers.map((career: any) => ({
    label: career.name,
    value: career.id,
  }));
  res.data.levels = res.data.levels.map((level: any) => ({
    label: level.name,
    value: level.id,
  }));
  res.data.levels.unshift({
    label: "Tất cả",
    value: 0,
  });
  res.data.jobTypes = res.data.jobTypes.map((t: any) => ({
    label: t.description,
    value: t.name,
  }));
  res.data.jobTypes.unshift({
    label: "Tất cả",
    value: "ALL",
  });

  const filters = {
    ...res.data,
    salary: SALARY_FILTER,
  };
  setFilterOptions(filters);

  syncFromQuery();
});

async function fetchJobs() {
  setIsFetchingJobs(true);

  if (controller.value) {
    controller.value.abort();
  }
  controller.value = new AbortController();

  const queryObj = {
    ...convertFilter(),
    ...sort.value.value,
  };

  const jobAdsRes = await getJobAds(queryObj, controller.value);
  setJobsList([...jobsList.value, ...jobAdsRes.data.data.data]);

  if (jobAdsRes.data.data.data.length == 0) {
    setNoData(true);
  } else {
    setNoData(false);
  }

  const locationFilter = jobAdsRes.data.locations.map((loc: any) => ({
    value: loc.province,
    label: `${loc.province} (${loc.jobAdCount})`,
  }));

  setFilterOptions({
    ...filterOptions.value,
    location: locationFilter,
  });

  setIsFetchingJobs(false);
}

function convertFilter() {
  const f = cloneDeep(filter.value);
  console.log({ f });
  const payload: any = {
    pageIndex: currentPage.value,
    pageSize: 20,
  };

  if (f.keyword?.trim()) {
    payload.keyword = f.keyword.trim();
  }
  if (f.searchOrg) {
    payload.searchOrg = true;
  }
  if (f.careers?.length) {
    payload.careerIds = f.careers.map((c: any) => c.value);
  }
  if (f.levels && f.levels != 0) {
    payload.levelIds = [f.levels];
  }
  if (f.location) {
    if (f.location == "Remote") {
      payload.isRemote = true;
    } else {
      payload.jobAdLocation = f.location;
    }
  }
  if (f.salary && f.salary != "ALL") {
    if (f.salary == "negotiable") {
      payload.negotiable = true;
    } else {
      const salaries = f.salary.split(",");

      const from = salaries[0];
      let to = null;
      if (salaries[1]) {
        to = salaries[1];
      }

      payload.salaryFrom = from;
      if (to != null) {
        payload.salaryTo = to;
      }
    }
  }
  if (f.jobTypes && f.jobTypes != "ALL") {
    payload.jobType = f.jobTypes;
  }

  console.log({ payload });

  return payload;
}

function syncFromQuery() {
  const q = route.query;
  const f: any = {};
  if (q.keyword) {
    f.keyword = q.keyword;
  }
  if (q.searchOrg == "") {
    f.searchOrg = true;
  }
  if (q.careers) {
    const careers = (q.careers as string).split(",");
    const careersFilter = [];
    for (const c of careers) {
      const career = filterOptions.value.careers.find(
        (_c: any) => _c.value == +c,
      );
      if (career) {
        careersFilter.push(career);
      }
    }
    f.careers = careersFilter;
  }

  if (q.levels) {
    const levels = q.levels as string;
    const level = filterOptions.value.levels.find(
      (_c: any) => _c.value == +levels,
    );
    if (level) {
      f.levels = level.value;
    }
  }

  if (q.jobTypes) {
    const jobTypes = q.jobTypes as string;
    if (jobTypes) {
      f.jobTypes = jobTypes;
    }
  }

  if (q.salary) {
    const salaries = q.salary as string;

    if (salaries) {
      f.salary = salaries;
    }
  }

  if (q.location) {
    const locations = q.location as string;
    if (locations) {
      f.location = locations;
    }
  }

  setFilter(f);
}

function syncToQuery() {
  const f = filter.value;
  const q: any = {};
  if (f.keyword) {
    q.keyword = f.keyword;
  }
  if (f.searchOrg) {
    q.searchOrg = "";
  }
  if (f.careers && f.careers.length) {
    q.careers = f.careers.map((career: any) => career.value).join(",");
  }
  if (f.levels != undefined && f.levels != null) {
    q.levels = f.levels;
  }
  if (f.jobTypes) {
    q.jobTypes = f.jobTypes;
  }
  if (f.salary) {
    q.salary = f.salary;
  }
  if (f.location) {
    q.location = f.location;
  }

  router.replace({ query: q });
}

function handleSearch(payload: any) {
  const newFilter: any = {
    ...filter.value,
    keyword: payload.keyword,
    searchOrg: payload.searchOrg,
  }

  setFilter(newFilter);
  syncToQuery();
}

function handleFilter(newValue: any) {
  setFilter({ ...filter.value, ...newValue });
  console.log({ newValue, filter: filter.value });
  syncToQuery();
}

async function handleFetchMore() {
  currentPage.value += 1;
  await fetchJobs();
}

watch(
  [() => filter.value, () => sort.value],
  async () => {
    if (scroller.value) {
      console.log({ scroller: scroller.value });
      scroller.value.scrollTo({
        top: 219,
      });
    }

    currentPage.value = 0;
    setJobsList([]);
    await fetchJobs();
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.jobs-result {
  overflow: auto;
  min-height: calc(100vh - 54px);
  display: flex;
  flex-direction: column;

  .top-filter {
    margin-top: 8px;
    max-width: min(75%, 1080px);
    width: min(75%, 1080px);
    @media (max-width: 768px) {
      max-width: 100%;
      width: 100%;
    }
  }

  .content,
  .top-filter {
    margin-left: auto;
    margin-right: auto;
    display: flex;
    flex-direction: row;
    gap: 8px;
    padding: 8px;

    .filtter-col {
      max-width: 280px;
      width: 280px;
    }

    .list-col {
      max-width: 360px;

      &.has-filter {
        flex: 1;
        max-width: none;
      }
    }
    .detail-col {
      flex: 1;
    }
  }

  .content {
    padding-bottom: 128px;
    flex: 1;
    width: 100%;

    max-width: min(75%, 1080px);
    width: min(75%, 1080px);
    @media (max-width: 768px) {
      max-width: 100%;
      width: 100%;
    }
  }
}
</style>
