<template>
  <div class="process-config">
    <div class="title">Quy trình ứng tuyển</div>
    <div v-if="isError" class="error-message">
      <span>
        Hãy chọn vị trí tuyển dụng để tiếp tục thiết lập quy trình ứng tuyển
      </span>
    </div>
    <div v-else class="content">
      <PositionCreateProcessBlock
        :list="formInput.processes"
        :process-list="processList"
        @input="handleInput('processes', $event)"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
const { getAll } = useProcessTypeApi();
const { getPositionDetail } = usePositionApi();
const { setLoading } = useLoadingStore();

export type TProcessConfigForm = {
  processes: Record<string, any>[];
};

type TProps = {
  data?: TProcessConfigForm;
  positionId: number;
};

const props = withDefaults(defineProps<TProps>(), {
  data: () => ({
    processes: [],
  }),
});
const emits = defineEmits<{
  (e: "dataChange", payload: TProcessConfigForm): void;
  (e: "paddedProcesses", payload: any[]): void;
}>();

const formInput = ref<Record<string, any>>({});

const processList = ref<Record<string, any>[]>([]);
const firstProcess = ref<Record<string, any>>({});
const lastProcess = ref<Record<string, any>>({});

onBeforeMount(async () => {
  setLoading(true);
  formInput.value = props.data;
  const res = await getAll();
  processList.value = res.data;

  setLoading(false);
});

const isError = computed(() => {
  return props.positionId == null;
});

function handleInput(key: string, value: any) {
  console.log(key, value);
  formInput.value[key] = value;
}

watch(
  formInput,
  (newVal) => {
    const padded = [firstProcess.value, ...newVal.processes, lastProcess.value];
    emits("dataChange", newVal as TProcessConfigForm);
    emits("paddedProcesses", [firstProcess.value, lastProcess.value]);
  },
  { deep: true },
);
watch(
  () => props.positionId,
  async (newVal) => {
    if (newVal != null) {
      const res = await getPositionDetail(newVal);
      if (res) {
        firstProcess.value = res.data.listProcess[0];
        lastProcess.value =
          res.data.listProcess[res.data.listProcess.length - 1];
        const processes = res.data.listProcess
          .slice(1, res.data.listProcess.length - 1)
          .map((process: any) => {
            const res = {
              processName: process.processType.name,
              processId: process.processTypeId,
              name: process.name,
              id: process.id,
            };
            return res;
          });
        emits("dataChange", { processes });
        emits("paddedProcesses", [firstProcess.value, lastProcess.value]);
      }
    }
  },
  { immediate: true },
);
watch(
  () => props.data,
  (newVal) => {
    formInput.value = newVal;
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.process-config {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .error-message {
    color: $color-danger;
    background-color: rgba($color-danger, 0.05);
    border-radius: 8px;
    border: 2px solid $color-danger;
    height: 64px;
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;

    .iconify {
      font-size: 20px;
      display: block;
      height: 20px;
    }
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    @include respond-max(958px) {
      flex-wrap: wrap;
      flex-direction: column;

      :deep(.search-select-input),
      :deep(.text-input),
      :deep(.datepicker-input) {
        max-width: calc((100%) * 1);
        min-width: calc((100%) * 1);
      }
    }
  }

  .title {
    color: $color-primary-400;
    font-size: 16px;
    line-height: 20px;
    font-weight: 600;
  }

  .loading {
    height: 160px;
    display: flex;
    align-items: center;
    justify-content: center;

    .iconify {
      display: block;
    }
  }

  :deep(.number-input) {
    .input-wrapper {
      .input {
        padding: 6px 8px;
        input {
          font-size: 14px;
        }
      }
    }
  }

  :deep(.text-input) {
    .input {
      padding: 6px 8px;
      input {
        font-size: 14px;
      }
    }

    @include respond-max(1064px) {
      max-width: 100%;
    }
  }

  :deep(.search-select-input),
  :deep(.text-input),
  :deep(.datepicker-input) {
    max-width: calc((100% - 16px) * 0.333333);
    min-width: calc((100% - 16px) * 0.333333);
  }

  .select-input {
    display: flex;
    flex-direction: column;
    gap: 4px;
    flex: 1;

    .label {
      display: flex;
      flex-direction: row;
      gap: 8px;
      align-items: center;
      width: fit-content;

      .text {
        font-size: 14px;
        line-height: 21px;
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

    :deep(button.selector) {
      margin: 0px 0px;
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
}
</style>
