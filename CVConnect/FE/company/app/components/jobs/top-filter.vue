<template>
  <div class="top-filter">
    <div class="location-section">
      <div
        v-for="location of filterOptions.location"
        :key="location.value"
        class="location-tag"
        :class="{ selected: filter.location == location.value }"
        @click="handleSelectLocation(location)"
      >
        {{ location.label }}
      </div>
    </div>
    <div class="sort-section">
      <div class="label">Sắp xếp theo:</div>
      <AppInputSearchSelect
        :label="''"
        :required="false"
        :options="JOBS_SORTER"
        :value="sort"
        :error="''"
        :placeholder="'Sắp xếp'"
        :search-placeholder="'Tìm kiếm'"
        :remote-filter="false"
        :multiple="false"
        :slim-error="true"
        :fetch-fn="null"
        @input="handleSetSort($event)"
        @clear-value="handleSetSort($event)"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
import { JOBS_SORTER } from "~/const/views/public/jobs";

const jobsSearchStore = useJobsSearchStore();
const { setSort } = jobsSearchStore;
const { filter, filterOptions, sort } = storeToRefs(jobsSearchStore);

const emits = defineEmits<{
  (e: "filter", newFilter: any): void;
}>();

function handleSelectLocation(location: any) {
  if (filter.value.location == location.value) {
    emits("filter", { location: undefined });
  } else {
    emits("filter", { location: location.value });
  }
}

function handleSetSort(sort: any) {
  setSort(sort);
}
</script>
<style lang="scss" scoped>
.top-filter {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 8px;
  width: 100%;
  font-size: 14px;
  min-height: 45px;

  .location-section {
    flex: 1;
    min-width: 0;
    overflow-x: auto;
    display: flex;
    flex-direction: row;
    gap: 8px;
    border-right: 1px solid $color-gray-300;
    padding: 0px 8px 0px 0px;

    .location-tag {
      padding: 4px 10px;
      font-size: 13px;
      border: 1px solid $color-gray-300;
      border-radius: 999px;
      background-color: white;
      min-width: fit-content;
      cursor: pointer;

      &.selected {
        border-color: $color-primary-400;
        background-color: $color-primary-50;
        color: $color-primary-400;
      }
    }
  }
  .sort-section {
    width: 288px;
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;

    .label {
      color: $text-light;
    }
  }
}
</style>
