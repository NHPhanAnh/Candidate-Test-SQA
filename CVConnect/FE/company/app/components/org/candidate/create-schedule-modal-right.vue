<template>
  <div class="right">
    <div class="content">
      <div class="row">
        <AppInputSearchSelect
          :label="'Hội đồng tuyển dụng'"
          :required="true"
          :options="orgMemberOpts"
          :value="formInput.orgMembers"
          :error="''"
          :is-disabled="false"
          :placeholder="''"
          :remote-filter="true"
          :multiple="true"
          :slim-error="true"
          :is-paginated="true"
          :fetch-fn="fetchOrgMembers"
          @input="handleInput('orgMembers', $event)"
          @clear-value="handleInput('orgMembers', null)"
          @search-filter="
            () => {
              orgMembersList = [];
            }
          "
        />
      </div>
      <div class="row">
        <AppInputSearchSelect
          :label="'Ứng viên'"
          :required="true"
          :options="candidateOpts"
          :value="formInput.candidates"
          :error="''"
          :is-disabled="false"
          :placeholder="''"
          :remote-filter="false"
          :multiple="true"
          :slim-error="true"
          :is-paginated="true"
          :fetch-fn="null"
          @input="handleInput('candidates', $event)"
          @clear-value="handleInput('candidates', null)"
          @search-filter="
            () => {
              candidatesList = [];
            }
          "
        />
      </div>
      <div class="row">
        <UCheckbox
          class="checkbox"
          :model-value="formInput.batchPartake"
          :label="'Tham gia đồng thời'"
          @update:model-value="
            ($event) => (formInput.batchPartake = $event as boolean)
          "
        />
      </div>
      <div class="content">
        <draggable
          v-if="formInput.candidates?.length"
          :list="formInput.candidates"
          item-key="id"
          handle=".drag-handle"
          ghost-class="drag-ghost"
          chosen-class="drag-chosen"
          animation="200"
          class="drag-list"
        >
          <template #item="{ element, index }">
            <div class="candidate-card">
              <div class="drag-handle">
                <Icon name="uil:draggabledots" />
              </div>
              <div class="info">
                <div class="name">{{ stripCandidateEmail(element.label) }}</div>
                <div class="time">{{ candidateTimeframe(index) }}</div>
              </div>

              <div class="remove-icon" @click="handleRemove(index)">
                <Icon name="material-symbols:close-rounded" />
              </div>
            </div>
          </template>
        </draggable>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import draggable from "vuedraggable";
import moment from "moment";

type TProps = {
  startTime: any;
  duration: any;
  jobAdInfo: any;
  candidateInfo: any;
};

const { getOrgMembers } = useOrgMemberApi();
const { getJobAdCandidatesByProcess } = useCandidateApi();

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "formInput", payload: any): void;
}>();

const defaultFormInput = {
  candidates: [
    {
      label: `${props.candidateInfo.fullName} - ${props.candidateInfo.email}`,
      value: props.candidateInfo.id,
    },
  ] as any[],
  orgMembers: [] as any[],
  batchPartake: false,
};

const formInput = ref<any>(defaultFormInput);
const orgMembersList = ref<any>([]);
const candidatesList = ref<any>([]);

onBeforeMount(async () => {
  await fetchCandidates({});
  const currentCandidate = candidatesList.value.find(
    (candidate: any) => candidate.id == props.candidateInfo.id,
  );
  if (currentCandidate) {
    formInput.value.candidates = [
      {
        label: `${currentCandidate.fullName} - ${currentCandidate.email}${currentCandidate.hasSchedule ? " - Đã đặt lịch" : ""}`,
        value: currentCandidate.id,
      },
    ];
  }
  console.log(formInput.value.candidates);
});

const stripCandidateEmail = computed(() => {
  return (label: string) => {
    const tokens = label.split(" - ");
    return tokens[0];
  };
});

const candidateTimeframe = computed(() => {
  return (index: number) => {
    const start = props.startTime ? moment(props.startTime) : null;
    const duration = props.duration ?? null;

    // Missing data → show placeholder
    if (!start || !duration) return "--:-- - --:--";

    // Start time for this candidate
    const slotStart = start.clone();

    // If not batch mode, shift time by index * duration
    if (!formInput.value.batchPartake) {
      slotStart.add(duration * index, "minutes");
    }

    const slotEnd = slotStart.clone().add(duration, "minutes");

    return `${slotStart.format("HH:mm")} - ${slotEnd.format("HH:mm")}`;
  };
});

const orgMemberOpts = computed(() => {
  return orgMembersList.value.map((orgMember: any) => ({
    label: `${orgMember.fullName} - ${orgMember.email}`,
    value: orgMember.userId,
  }));
});

const candidateOpts = computed(() => {
  return candidatesList.value.map((candidate: any) => ({
    label: `${candidate.fullName} - ${candidate.email}${candidate.hasSchedule ? " - Đã đặt lịch" : ""}`,
    value: candidate.id,
  }));
});

const currentProcess = computed(() => {
  return props.jobAdInfo.jobAdProcessCandidates.find(
    (process: any) => process.isCurrentProcess,
  );
});

function handleRemove(index: any) {
  formInput.value.candidates.splice(index, 1);
}

function handleInput(key: string, value: any) {
  formInput.value[key] = value;
}

async function fetchOrgMembers(params: any, controller?: AbortController) {
  const res = await getOrgMembers(params, controller);
  if (!res) {
    return null;
  }

  const nextPage = res.data.data;
  orgMembersList.value = [...orgMembersList.value, ...nextPage];

  return res.data.data;
}

async function fetchCandidates(params: any, controller?: AbortController) {
  const res = await getJobAdCandidatesByProcess(
    currentProcess.value.jobAdProcessId,
    controller,
  );
  if (!res) {
    return null;
  }

  const nextPage = res.data;
  candidatesList.value = [...candidatesList.value, ...nextPage];

  return res.data;
}

watch(
  () => formInput.value,
  (newVal) => {
    emits("formInput", newVal);
  },
  { immediate: true, deep: true },
);
</script>
<style lang="scss" scoped>
.right {
  max-height: 100%;
  display: flex;
  flex-direction: column;
  width: 40%;
  gap: 8px;

  .row {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
  }

  .header {
    font-size: 16px;
    font-weight: 500;
  }

  .content {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 8px;
    overflow: auto;
    min-height: 0;

    .checkbox {
      max-width: fit-content;
      :deep(label) {
        color: $text-light;
        font-weight: 400;
        cursor: pointer !important;
      }
      :deep(button) {
        cursor: pointer !important;
      }
    }

    .drag-list {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .candidate-card {
      display: flex;
      flex-direction: row;
      align-items: center;
      color: $text-light;
      gap: 8px;
      padding: 6px;
      background-color: $color-gray-100;
      border-radius: 6px;

      .drag-handle {
        .iconify {
          display: block;
          height: 16px;
          width: 16px;
          cursor: grabbing;
        }
      }
      .remove-icon {
        .iconify {
          display: block;
          height: 16px;
          width: 16px;
          cursor: pointer;
        }
      }

      .info {
        display: flex;
        flex-direction: row;
        gap: 8px;
        align-items: center;
        justify-content: space-between;
        flex: 1;

        .name {
          font-size: 14px;
          font-weight: 600;
        }

        .time {
          font-size: 14px;
          font-weight: 400;
          color: $color-gray-600;
        }
      }
    }
  }

  :deep(.search-select-input) {
    max-width: 100%;
  }
}
</style>
