<template>
  <div class="filter-section">
    <AppInputSearchSelect
      :label="'Ngành nghề'"
      :required="false"
      :options="filterOptions?.careers ?? []"
      :value="filter?.careers ?? []"
      :error="''"
      :placeholder="'Chọn ngành nghề'"
      :search-placeholder="'Tìm kiếm'"
      :remote-filter="false"
      :multiple="true"
      :slim-error="true"
      :fetch-fn="null"
      @input="handleSetFilter('careers', $event)"
      @clear-value="handleSetFilter('careers', undefined)"
    />
    <div class="label">Cấp bậc</div>
    <div class="level-filter">
      <div class="level-col">
        <div
          v-for="option of filterOptions?.levels?.slice(
            0,
            filterOptions?.levels?.length / 2 + 1,
          ) ?? []"
          :key="option.value"
          class="radio-input"
          @click="handleSetFilter('levels', option.value)"
        >
          <input
            type="radio"
            name="levels"
            class="radio"
            :value="option.value"
            :checked="filter.levels == option.value"
          />
          <span>{{ option.label }}</span>
        </div>
      </div>
      <div class="level-col">
        <div
          v-for="option of filterOptions?.levels?.slice(
            filterOptions?.levels?.length / 2 + 1,
            filterOptions?.levels?.length,
          ) ?? []"
          :key="option.value"
          class="radio-input"
          @click="handleSetFilter('levels', option.value)"
        >
          <input
            type="radio"
            name="levels"
            class="radio"
            :value="option.value"
            :checked="filter.levels == option.value"
          />
          <span>{{ option.label }}</span>
        </div>
      </div>
    </div>
    <div class="label">Loại hình</div>
    <div class="job-type-filter">
      <div class="job-type-col">
        <div
          v-for="option of filterOptions?.jobTypes ?? []"
          :key="option.value"
          class="radio-input"
          @click="handleSetFilter('jobTypes', option.value)"
        >
          <input
            type="radio"
            name="jobTypes"
            class="radio"
            :value="option.value"
            :checked="filter.jobTypes == option.value"
          />
          <span>{{ option.label }}</span>
        </div>
      </div>
    </div>

    <div class="label">Mức lương</div>
    <div class="salary-filter">
      <div class="salary-col">
        <div
          v-for="option of filterOptions?.salary?.slice(
            0,
            filterOptions?.salary?.length / 2 + 1,
          ) ?? []"
          :key="option.value"
          class="radio-input"
          @click="handleSetFilter('salary', option.value)"
        >
          <input
            type="radio"
            name="salary"
            class="radio"
            :value="option.value"
            :checked="filter.salary == option.value"
          />
          <span>{{ option.label }}</span>
        </div>
      </div>
      <div class="salary-col">
        <div
          v-for="option of filterOptions?.salary?.slice(
            filterOptions?.salary?.length / 2 + 1,
            filterOptions?.salary?.length,
          ) ?? []"
          :key="option.value"
          class="radio-input"
          @click="handleSetFilter('salary', option.value)"
        >
          <input
            type="radio"
            name="salary"
            class="radio"
            :value="option.value"
            :checked="filter.salary == option.value"
          />
          <span>{{ option.label }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
const jobsSearchStore = useJobsSearchStore();
const { filterOptions, filter } = storeToRefs(jobsSearchStore);

const emits = defineEmits<{
  (e: "filter", newFilter: any): void;
}>();

function handleSetFilter(key: string, value: any) {
  emits("filter", { [key]: value });
}
</script>
<style lang="scss" scoped>
.filter-section {
  position: sticky;
  top: 8px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  background-color: white;
  border-radius: 12px;
  height: fit-content;
  padding: 12px;
  @include box-shadow;

  :deep(span.text),
  .label {
    font-weight: 600;
  }

  .search-select-input {
    max-width: 240px;
  }

  .label {
    font-size: 14px;
    color: $text-light;
    margin-bottom: -4px;
  }

  .level-filter,
  .job-type-filter,
  .salary-filter {
    display: flex;
    flex-direction: row;
    gap: 4px;
    justify-content: space-between;

    .job-type-col, .salary-col, .level-col {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .radio-input {
      display: flex;
      flex-direction: row;
      width: fit-content;
      gap: 6px;
      align-items: center;
      font-size: 14px;
      cursor: pointer;
      input[type="radio"] {
        appearance: none;
        width: 16px;
        height: 16px;
        border-radius: 50%;
        border: 1px solid $color-gray-400;
        background-color: #fff;
        cursor: pointer;

        &:checked {
          appearance: auto;
          accent-color: $color-primary-500;
        }

        &:hover {
          border-color: $color-primary-500;
        }

        &:focus {
          outline: none;
        }
      }
    }
  }
}
</style>
