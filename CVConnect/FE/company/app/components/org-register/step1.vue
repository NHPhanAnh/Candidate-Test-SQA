<template>
  <div class="step1">
    <div class="form-body">
      <AppInputText
        :label="'Tên doanh nghiệp'"
        :required="true"
        :value="props.data.name as string"
        :error="formError.name"
        @input="handleInput('name', $event)"
        @blur="validateKey('name')"
      />
      <AppInputText
        :label="'Địa chỉ website'"
        :required="false"
        :value="props.data.website as string"
        :error="''"
        @input="handleInput('website', $event)"
      />
      <div class="company-misc-wrapper">
        <div class="company-type-wrapper">
          <div class="label">Lĩnh vực</div>
          <div class="select-input" :title="selectedCompanyType">
            <div v-if="selectedCompanyType" class="clear-button" @click="handleInput('companyType', [])">
              <Icon name="material-symbols:close-rounded" />
            </div>
            <USelectMenu
              :model-value="props.data.companyType"
              :items="companyTypeOptions"
              class="selector"
              :variant="'none'"
              autocomplete="autocomplete"
              :search-input="{
                placeholder: 'Tìm kiếm',
              }"
              multiple
              :ui="{
                trailingIcon:
                  'group-data-[state=open]:rotate-180 transition-transform duration-200',
              }"
              @update:model-value="handleInput('companyType', $event)"
              @update:open="
                ($event) =>
                  $event ? attachScrollListener() : detachScrollListener()
              "
            />
          </div>
        </div>
        <div class="staff-count-wrapper">
          <div class="label">Số lượng nhân sự</div>
          <div class="select-input">
            <USelect
              v-model="companySize"
              :items="companySizeOptions"
              class="selector"
              :variant="'none'"
            />
          </div>
        </div>
      </div>
      <div class="text-editor-wrapper">
        <div class="label">Thông tin doanh nghiệp</div>
        <AppInputBasicTextEditor
          :value="props.data.description as string"
          @input="handleInput('description', $event)"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { debounce } from "lodash";

type TProps = {
  data: Record<string, any>;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "input", event: Record<string, any>): void;
}>();

const { getIndustry } = useCommonApi();

const currentIndustryPage = ref<number>(0);
const formError = ref<Record<string, any>>({
  name: "",
});
const scrollTarget = ref<HTMLElement | null>(null);
const hasReachBottom = ref<boolean>(false);
let lastScrollTop = 0;

const attachScrollListener = () => {
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
};

const detachScrollListener = () => {
  nextTick(() => {
    if (scrollTarget.value) {
      scrollTarget.value.removeEventListener("scroll", onScroll);
      scrollTarget.value = null;
    }
    lastScrollTop = 0;
  });
};

const companySize = ref<string>("");
type TCompanyType = {
  label: string;
  value: number;
};
const companyTypeOptions = ref<TCompanyType[]>([]);

const companySizeOptions = [
  { label: "Từ 1 đến 50", value: "1-50" },
  { label: "Từ 50 đến 100", value: "50-100" },
  { label: "Từ 100 đến 200", value: "100-200" },
  { label: "Từ 200 đến 500", value: "200-500" },
  { label: "Trên 500", value: "500-" },
];

onBeforeMount(async () => {
  await fetchIndustry();
});

const selectedCompanyType = computed(() => {
  const companyTypes: string[] = [];
  for (const companyType of props.data.companyType) {
    const found = companyTypeOptions.value.find(
      (type) => type.value == companyType.value,
    );
    if (found) {
      companyTypes.push(found.label);
    }
  }
  console.log(props.data.companyType);
  return companyTypes.join(", ");
});

const handleScroll = debounce(async (el: HTMLElement) => {
  if (el.scrollTop + el.clientHeight >= el.scrollHeight - 20) {
    await fetchIndustry();
  }
}, 250);

const fetchIndustry = async () => {
  if (hasReachBottom.value) {
    return;
  }
  const prevScrollTop = scrollTarget.value?.scrollTop;

  const res = await getIndustry(10, currentIndustryPage.value);
  const newData = res.data.data.map((data: any) => ({
    label: data.name,
    value: data.id,
  }));
  if (newData.length == 0) {
    hasReachBottom.value = true;
  }
  companyTypeOptions.value = [...companyTypeOptions.value, ...newData];

  await nextTick();
  if (scrollTarget.value && prevScrollTop) {
    scrollTarget.value.scrollTop = prevScrollTop;
  }

  currentIndustryPage.value += 1;
};

const onScroll = (e: Event) => {
  const el = e.target as HTMLElement;
  const currentTop = el.scrollTop;

  if (currentTop <= lastScrollTop) {
    lastScrollTop = currentTop;
    return;
  }
  lastScrollTop = currentTop;

  handleScroll(el);
};

const handleInput = (key: string, $event: any) => {
  if (key == "companyType" && $event.length > 5) {
    return;
  }
  if (formError.value[key]) {
    formError.value[key] = "";
  }
  emits("input", { key, value: $event });
};

const validateKey = (key: string) => {
  if (!props.data[key].trim()) {
    formError.value[key] = "Xin mời nhập";
  }
};

watch(companySize, (newVal) => {
  emits("input", { key: "companySize", value: newVal });
});
</script>

<style lang="scss" scoped>
.step1 {
  display: flex;
  flex-direction: column;
  width: 100%;

  .form-body {
    display: flex;
    flex-direction: column;
    gap: 4px;

    .label,
    span {
      font-size: 14px;
      line-height: 21px;
      color: $text-light;
    }

    .label {
      margin-bottom: 4px;
    }

    .company-misc-wrapper {
      display: flex;
      flex-direction: row;
      gap: 12px;
      max-width: 100%;

      .staff-count-wrapper,
      .company-type-wrapper {
        margin-bottom: 24px;
        flex: 1;
        max-width: calc(50% - 6px);

        .select-input {
          position: relative;
          .clear-button {
            position: absolute;
            cursor: pointer;
            top: 7px;
            right: 32px;
            z-index: 1;
            span {
              font-size: 20px;
              height: 20px;
              width: 20px;
              min-width: 20px;
              color: $color-gray-400;
            }
          }
          :deep(button.selector) {
            cursor: pointer;
            border: 1px solid rgba($color-primary-800, 0.1);
            border-radius: 10px !important;
            padding: 4px 48px 4px 6px !important;
            font-weight: 500 !important;
            color: $color-gray-600 !important;
            height: 32px;
            background-color: $color-gray-100 !important;
            width: 100%;
            max-width: 100%;

            &:hover {
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
              color: $color-gray-400;
              font-weight: 400 !important;
            }
          }
        }

        .label,
        span {
          font-size: 14px;
          line-height: 21px;
          color: $text-light;
        }

        .label {
          margin-bottom: 4px;
        }

        span {
          min-width: 32px;
        }
      }

      .company-type-wrapper {
        .select-input {
          :deep(button.selector) {
            width: 100%;
            max-width: 100%;
          }
        }
      }
    }
  }
}
</style>
