<template>
  <div class="search-select-input">
    <div v-if="props.label" class="label">
      <span v-if="props.label" class="text">{{ props.label }}</span>
      <span v-if="props.required" class="required">Bắt buộc</span>
      <slot name="icon"></slot>
    </div>
    <div class="wrapper">
      <USelectMenu
        :search-term="searchValue"
        :model-value="props.value"
        :items="options"
        class="selector"
        :class="{ error: error, 'is-loading': isLoading }"
        :variant="'none'"
        autocomplete="autocomplete"
        :placeholder="props.placeholder"
        :multiple="props.multiple"
        :filter="!props.remoteFilter"
        :disabled="props.isDisabled"
        searchable
        :loading="isLoading"
        :title="title"
        :search-input="{ placeholder: props.searchPlaceholder }"
        :ui="{
          trailingIcon:
            'group-data-[state=open]:rotate-180 transition-transform duration-200',
        }"
        @update:model-value="handleInput($event)"
        @update:search-term="handleSearchInput($event)"
        @update:open="($event) => handleOpenUpdate($event)"
      >
        <template #item-label="{ item }">
          <div :title="item.label" class="truncate cursor-pointer">
            {{ item.label }}
          </div>
        </template>
      </USelectMenu>
      <div
        v-if="props.allowClear && hasValue"
        class="clear-button"
        @click="emits('clear-value')"
      >
        <Icon name="mdi:close-circle" />
      </div>
    </div>
    <div v-if="!props.slimError" class="error-message">{{ error }}</div>
  </div>
</template>
<script setup lang="ts">
import { debounce } from "lodash";

type TProps = {
  label?: string;
  required?: boolean;
  options?: Record<string, any>[];
  value: any;
  error?: string;
  isDisabled?: boolean;
  placeholder?: string;
  remoteFilter?: boolean;
  multiple?: boolean;
  allowClear?: boolean;
  isPaginated?: boolean;
  slimError?: boolean;
  searchPlaceholder?: string;
  fetchFn?:
    | ((params: any, controller?: AbortController) => Promise<any>)
    | null;
};

const props = withDefaults(defineProps<TProps>(), {
  label: "",
  required: false,
  options: () => [],
  error: "",
  placeholder: "Mời chọn",
  remoteFilter: false,
  multiple: false,
  isDisabled: false,
  fetchFn: null,
  slimError: false,
  allowClear: true,
  isPaginated: true,
  searchPlaceholder: "Tìm kiếm",
});
const emits = defineEmits<{
  (
    e: "input",
    value: Record<string, any> | Record<string, any>[] | undefined,
  ): void;
  (e: "open-update", value: boolean): void;
  (e: "search-filter" | "clear-value"): void;
}>();

const scrollTarget = ref<HTMLElement | null>(null);
const controller = ref<AbortController | null>(null);
const currentPage = ref<number>(0);
const searchValue = ref<string>("");
const hasReachBottom = ref<boolean>(false);
const isLoading = ref<boolean>(false);
let lastScrollTop = 0;

const title = computed(() => {
  if (props.value?.length) {
    return props.value?.map((i: any) => i.label).join(", ") ?? "";
  } else {
    return props.value?.label;
  }
});

const hasValue = computed(() => {
  if (props.value?.length >= 0) {
    return props.value.length > 0;
  } else {
    return !!props.value;
  }
});

function handleInput(
  value: Record<string, any> | Record<string, any>[] | undefined,
) {
  emits("input", value);
}

async function handleOpenUpdate(isOpen: boolean) {
  if (isOpen) {
    if (props.options.length == 0) {
      await resetAndFetch();
    }
    if (props.isPaginated) {
      attachScrollListener();
    }
  } else {
    if (props.isPaginated) {
      detachScrollListener();
    }
  }

  emits("open-update", isOpen);
}

function handleSearchInput(value: string) {
  searchValue.value = value;
}

function attachScrollListener() {
  nextTick(() => {
    scrollTarget.value = document.querySelector(
      '[role="presentation"]',
    ) as HTMLElement;

    if (scrollTarget.value) {
      scrollTarget.value.addEventListener("scroll", onScroll, {
        passive: true,
      });
    }
  });
}

function detachScrollListener() {
  nextTick(() => {
    if (scrollTarget.value) {
      scrollTarget.value.removeEventListener("scroll", onScroll);
      scrollTarget.value = null;
    }
    lastScrollTop = 0;
  });
}

function onScroll(e: Event) {
  const el = e.target as HTMLElement;
  const currentTop = el.scrollTop;
  if (currentTop <= lastScrollTop) {
    lastScrollTop = currentTop;
    return;
  }
  lastScrollTop = currentTop;
  handleScroll(el);
}

const handleScroll = debounce(async (el: HTMLElement) => {
  if (el.scrollTop + el.clientHeight >= el.scrollHeight - 20) {
    await fetchData(searchValue.value);
  }
}, 250);

async function resetAndFetch(searchTerm = "") {
  //Save scroll before reset (if open)
  if (!props.fetchFn) {
    return;
  }
  const prevScrollTop = scrollTarget.value?.scrollTop ?? 0;

  hasReachBottom.value = false;
  currentPage.value = 0;
  emits("search-filter");

  if (controller.value) {
    controller.value.abort();
  }

  await fetchData(searchTerm);

  //Restore scroll after reset
  await nextTick();
  if (scrollTarget.value) {
    scrollTarget.value.scrollTop = prevScrollTop;
  }
}

async function fetchData(searchTerm = "") {
  if (!props.fetchFn) {
    return;
  }
  if (hasReachBottom.value) {
    return;
  }
  if (controller.value) {
    controller.value.abort();
  }
  controller.value = new AbortController();

  const prevScrollTop = scrollTarget.value?.scrollTop ?? 0;

  const params: any = {
    pageIndex: currentPage.value,
    pageSize: 30,
  };
  if (searchTerm) params.name = searchTerm;

  isLoading.value = true;
  const res = await props.fetchFn(params, controller.value);
  isLoading.value = false;
  if (!res) {
    return;
  }

  if (res.length == 0) {
    hasReachBottom.value = true;
  }

  currentPage.value += 1;

  await nextTick();
  if (scrollTarget.value) {
    scrollTarget.value.scrollTop = prevScrollTop;
  }
}

const debouncedSearch = useDebounceFn(async (query: string) => {
  await resetAndFetch(query);
}, 400);

watch(searchValue, (val) => {
  if (!props.remoteFilter) {
    return;
  }
  debouncedSearch(val);
});
</script>
<style lang="scss" scoped>
.search-select-input {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;

  .clear-button {
    position: absolute;
    color: $color-gray-300;
    cursor: pointer;
    transition-duration: 200ms;
    &:hover {
      color: $color-primary-500;
    }
    top: 10px;
    right: 34px;
  }

  .label {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;
    width: fit-content;

    .text {
      font-size: 14px;
      line-height: 21px;
      color: $text-light;
    }

    .required {
      font-size: 12px;
      font-style: italic;
      color: $color-danger;
    }
  }

  .error-message {
    min-height: 16px;
    display: inline-block;
    color: $color-danger;
    font-size: 12px;
    line-height: 16px;
  }

  .wrapper {
    position: relative;
  }

  :deep(button.selector) {
    margin: 1px 0px;
    cursor: pointer;
    border: 1px solid rgba($color-primary-800, 0.1);

    &:disabled {
      border: 1px solid rgba($color-gray-300, 1);
      cursor: default;
      opacity: 100%;
    }

    &.error {
      border: 1px solid $color-danger;
    }

    border-radius: 10px !important;
    padding: 6px 48px 6px 8px !important;
    &.is-loading {
      padding: 6px 48px 6px 36px !important;
    }
    font-weight: 500 !important;
    color: $text-light !important;
    height: 36px;
    background-color: white !important;
    width: 100%;
    max-width: 100%;

    &:hover:not(:disabled) {
      border: 1px solid rgba($color-primary-400, 1);
    }

    span {
      font-size: 14px;
      line-height: 21px;
      color: $text-light;
      font-weight: 400 !important;
    }
    .text-dimmed {
      font-size: 14px;
      line-height: 21px;
      color: $color-gray-300;
      font-weight: 400 !important;
    }
  }
}
</style>
