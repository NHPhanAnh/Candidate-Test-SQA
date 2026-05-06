<template>
  <UModal
    v-model:open="isOpen"
    title="Tạo lịch hẹn"
    :ui="{ content: 'w-[80vw] min-w-[80vw]' }"
  >
    <template #body>
      <div class="body">
        <OrgCandidateCreateScheduleModalLeft
          ref="leftSideRef"
          :job-ad-info="props.jobAdInfo"
          :candidate-info="props.candidateInfo"
          @form-input="($event) => (formInput = { ...formInput, ...$event })"
        />
        <OrgCandidateCreateScheduleModalRight
          :job-ad-info="props.jobAdInfo"
          :duration="formInput.duration"
          :start-time="formInput.startTime"
          :candidate-info="props.candidateInfo"
          @form-input="($event) => (formInput = { ...formInput, ...$event })"
        />
      </div>
    </template>
    <template #footer>
      <div class="modal-footer">
        <AppButton
          class="cancel-btn btn"
          :text="'Đóng'"
          @click="handleCancel"
        />
        <AppButton
          class="submit-btn btn"
          :text="'Tạo'"
          :is-disabled="isSubmitDisabled"
          :is-loading="isLoading"
          @click="handleSubmit"
        />
        <AppButton
          v-if="formInput.useBlankTemplate"
          class="submit-btn btn"
          :text="'Tạo và lưu mẫu email'"
          :is-disabled="isSubmitCreateDisabled"
          :is-loading="isLoading"
          @click="handleSubmitCreate"
        />
      </div>
    </template>
  </UModal>
</template>
<script setup lang="ts">
import moment from "moment";

type TProps = {
  modelValue: boolean;
  jobAdInfo: any;
  jobAdCandidateId: any;
  candidateInfo: any;
};

const { createSchedule } = useCandidateApi();
const { createMailTemplateWithId } = useMailTemplateApi();

const props = defineProps<TProps>();

const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

onBeforeMount(async () => {});

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const isLoading = ref<boolean>(false);

const formInput = ref<any>({});
const leftSideRef = ref<any>(null);

function handleCancel() {
  emits("update:modelValue", false);
}

function convertDate(dateStr: string) {
  const m = moment(dateStr);

  return {
    date: m.format("YYYY-MM-DD"),
    timeFrom: m.format("HH:mm") + ":00",
  };
}

const isSubmitDisabled = computed(() => {
  const form = formInput.value;

  if (
    !form.startTime ||
    !form.duration ||
    !form.scheduleType ||
    !form.orgMembers?.length ||
    !form.candidates?.length
  ) {
    return true;
  }

  // Schedule type check
  if (currentScheduleType.value == "OFFLINE" && !form.location) {
    return true;
  }
  if (currentScheduleType.value == "ONLINE" && !form.meetingLink) {
    return true;
  }

  // Send email check
  if (form.sendEmail && !form.useBlankTemplate && !form.emailTemplate) {
    return true;
  }

  if (
    form.sendEmail &&
    form.useBlankTemplate &&
    (!form.subject?.trim() || !form.template?.trim())
  ) {
    return true;
  }
  return false;
});
async function handleSubmit() {
  const form = formInput.value;

  // Mapping the generic ones
  const payload: any = {
    jobAdProcessId: currentProcess.value.jobAdProcessId,
    calendarType: form.scheduleType.value,
    joinSameTime: form.batchPartake,
    durationMinutes: form.duration,
    note: form.note,
    participantIds: form.orgMembers.map((member: any) => member.value),
    candidateInfoIds: form.candidates.map((candidate: any) => candidate.value),
    sendEmail: form.sendEmail,
    ...convertDate(form.startTime),
  };

  if (currentScheduleType.value === "OFFLINE") {
    payload.orgAddressId = form.location.value;
  } else {
    payload.meetingLink = form.meetingLink;
  }

  if (form.sendEmail && !form.useBlankTemplate) {
    payload.emailTemplateId = form.emailTemplate.value;
  }

  if (form.sendEmail && form.useBlankTemplate) {
    payload.subject = form.subject;
    payload.template = parseHtmlToMergeTags(form.template);
    payload.placeholders = getUsedPlaceholdersCode();
  }

  isLoading.value = true;
  const res = await createSchedule(payload);
  isLoading.value = false;
  if (res) {
    emits("submit");
  }
}

const currentProcess = computed(() => {
  return props.jobAdInfo.jobAdProcessCandidates.find(
    (process: any) => process.isCurrentProcess,
  );
});

const isSubmitCreateDisabled = computed(() => {
  const form = formInput.value;

  if (
    !form.startTime ||
    !form.duration ||
    !form.scheduleType ||
    !form.orgMembers?.length ||
    !form.candidates?.length
  ) {
    return true;
  }

  // Schedule type check
  if (currentScheduleType.value == "OFFLINE" && !form.location) {
    return true;
  }
  if (currentScheduleType.value == "ONLINE" && !form.meetingLink) {
    return true;
  }

  // Send email check
  if (form.sendEmail && !form.useBlankTemplate && !form.emailTemplate) {
    return true;
  }

  if (
    form.sendEmail &&
    form.useBlankTemplate &&
    (!form.subject?.trim() ||
      !form.template?.trim() ||
      !form.templateName?.trim() ||
      !form.templateCode?.trim())
  ) {
    return true;
  }
  return false;
});
async function handleSubmitCreate() {
  const form = formInput.value;

  const createTemplatePayload: any = {
    code: form.templateCode,
    name: form.templateName,
    subject: form.subject,
    body: parseHtmlToMergeTags(form.template),
    placeholderIds: getUsedPlaceholdersId(),
  };

  isLoading.value = true;
  const createRes = await createMailTemplateWithId(createTemplatePayload);
  if (createRes === false) {
    isLoading.value = false;
    return;
  }

  // Mapping the generic ones
  const payload: any = {
    jobAdProcessId: currentProcess.value.jobAdProcessId,
    calendarType: form.scheduleType.value,
    joinSameTime: form.batchPartake,
    durationMinutes: form.duration,
    note: form.note,
    participantIds: form.orgMembers.map((member: any) => member.value),
    candidateInfoIds: form.candidates.map((candidate: any) => candidate.value),
    sendEmail: form.sendEmail,
    ...convertDate(form.startTime),
    emailTemplateId: createRes.data.id,
  };

  if (currentScheduleType.value === "OFFLINE") {
    payload.orgAddressId = form.location.value;
  } else {
    payload.meetingLink = form.meetingLink;
  }

  const res = await createSchedule(payload);
  isLoading.value = false;
  if (res) {
    emits("submit");
  }
}

function getUsedPlaceholdersCode() {
  if (leftSideRef.value) {
    const placeholders = leftSideRef.value.getUsedPlaceholdersCode();
    return placeholders;
  }

  return [];
}

function getUsedPlaceholdersId() {
  if (leftSideRef.value) {
    const placeholders = leftSideRef.value.getUsedPlaceholdersId();
    return placeholders;
  }

  return [];
}

const currentScheduleType = computed(() => {
  if (leftSideRef.value) {
    return leftSideRef.value.currentScheduleType;
  }

  return "OFFLINE";
});
watch(
  () => props.modelValue,
  (newVal) => {
    if (!newVal) {
      // clear everything
      formInput.value = {};
    }
  },
);
</script>
<style lang="scss" scoped>
.body {
  display: flex;
  flex-direction: row;
  gap: 8px;
  height: 100%;
  max-height: 65vh;
}

.modal-footer {
  width: 100%;
  display: flex;
  flex-direction: row;
  gap: 8px;
  justify-content: flex-end;
}

.btn {
  font-size: 14px;
  padding: 6px 12px;
  min-width: 64px;

  &.cancel-btn {
    border: 1px solid $color-primary-500;
    color: $color-primary-500;
  }

  &.submit-btn {
    background-color: $color-primary-500;
    border: 1px solid $color-primary-500;
    color: $text-dark;

    &.disabled {
      background-color: $color-gray-400;
      border: 1px solid $color-gray-400;
    }
  }
}
</style>
