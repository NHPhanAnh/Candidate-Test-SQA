import { defineStore } from "pinia";
import { JOBS_SORTER } from "~/const/views/public/jobs";

export const useJobsSearchStore = defineStore("jobsSearch", () => {
  const jobsList = ref<any[]>([]);
  const selectedJob = ref<any>(null);
  const filterOptions = ref<any>({});
  const filter = ref<any>({});
  const isNoData = ref<any>(false);
  const isFetchingJobs = ref<boolean>(false);
  const sort = ref<any>(JOBS_SORTER[0]);

  function setSelectedJob(job: any) {
    selectedJob.value = job;
  }

  function setFilterOptions(filter: any) {
    filterOptions.value = filter;
  }

  function setFilter(_filter: any) {
    filter.value = _filter;
  }

  function setNoData(state: boolean) {
    isNoData.value = state;
  }

  function setJobsList(list: any) {
    jobsList.value = list;
  }

  function setIsFetchingJobs(state: boolean) {
    isFetchingJobs.value = state;
  }

  function setSort(_sort: any) {
    sort.value = _sort;
  }

  return {
    jobsList,
    selectedJob,
    isNoData,
    filter,
    filterOptions,
    isFetchingJobs,
    sort,
    setSelectedJob,
    setFilterOptions,
    setFilter,
    setNoData,
    setJobsList,
    setIsFetchingJobs,
    setSort,
  };
});
