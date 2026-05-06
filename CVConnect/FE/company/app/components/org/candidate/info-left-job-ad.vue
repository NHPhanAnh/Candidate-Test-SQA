<template>
  <div class="job-ad-wrapper">
    <div class="label">
      {{ `Tin ứng tuyển (${props.jobAdInfos.length || 0})` }}
    </div>

    <OrgCandidateEliminateModal
      v-model="isRejectModalOpen"
      :rejecting-target="rejectingTarget"
      :candidate-info="props.candidateInfo"
      @rejected="handleCandidateEliminated"
    />
    <OrgCandidateChangeProcessModal
      v-model="isChangeProcessModalOpen"
      :change-process-target="changeProcessTarget"
      :candidate-info="props.candidateInfo"
      @submit="handleChangeProcess"
    />
    <OrgCandidateChangeOnboardDateModal
      v-model="isChangeOnboardDateModalOpen"
      :change-date-target="changeDateTarget"
      @submit="handleChangeOnboardDate"
    />

    <div class="info">
      <AppNoData v-if="!props.jobAdInfos.length" />
      <template v-else>
        <div
          v-for="(displayJobAd, index) of props.jobAdInfos"
          :key="index"
          class="job-ad"
        >
          <div class="info-top">
            <span class="title">{{ displayJobAd.jobAd.title }}</span>
            <span
              class="value chip"
              :title="statusTooltip(displayJobAd)"
              :style="{
                borderColor:
                  CANDIDATE_STATUS[displayJobAd.candidateStatus].color,
                color: CANDIDATE_STATUS[displayJobAd.candidateStatus].color,
                backgroundColor:
                  CANDIDATE_STATUS[displayJobAd.candidateStatus].background,
              }"
              >{{ CANDIDATE_STATUS[displayJobAd.candidateStatus].label }}</span
            >
          </div>
          <div class="info-dept-pos">
            <span :title="displayJobAd.jobAd.departmentName">{{ displayJobAd.jobAd.departmentCode }}</span>
            <span>•</span>
            <span>{{ displayJobAd.jobAd.positionName }}</span>
          </div>
          <div class="hr-info">
            <span class="hr-info-label">
              <Icon name="material-symbols:article-person-rounded" />
              <span>{{ displayJobAd.jobAd.hrContactName }}</span>
            </span>
          </div>
          <div class="processes">
            <div class="list">
              <div
                v-for="(process, index) of displayJobAd.jobAdProcessCandidates"
                :key="process.id"
                :title="processTooltip(process)"
                class="process"
              >
                <div
                  v-if="index !== 0"
                  class="line"
                  :class="{
                    highlighted:
                      index <= displayJobAdCurrentProcessIndex(displayJobAd),
                  }"
                >
                  <span></span>
                </div>
                <div
                  class="dot"
                  :class="{
                    highlighted:
                      index <= displayJobAdCurrentProcessIndex(displayJobAd),
                  }"
                >
                  <Icon name="stash:circle-dot" />
                  <span>{{ process.processName }}</span>
                </div>
              </div>
            </div>
            <div class="actions">
              <template v-if="displayJobAd.candidateStatus != 'REJECTED'">
                <template v-if="!isOnboardStep(displayJobAd)">
                  <div
                    title="Chuyển vòng"
                    class="action-btn next-step-btn"
                    @click="handleChangeProcessClick(displayJobAd)"
                  >
                    <Icon name="material-symbols:arrow-right-alt-rounded" />
                  </div>
                  <div
                    title="Loại ứng viên"
                    class="action-btn reject-btn"
                    @click="handleRejectClick(displayJobAd)"
                  >
                    <Icon name="material-symbols:close-rounded" />
                  </div>
                </template>
                <template
                  v-if="displayJobAd.candidateStatus === 'WAITING_ONBOARDING'"
                >
                  <div class="flex flex-row gap-1 justify-end flex-wrap">
                    <div
                      title="Onboard"
                      class="action-btn onboard-btn"
                      @click="handleMarkOnboard(displayJobAd.id, true)"
                    >
                      <Icon name="ci:check" />
                    </div>
                    <div
                      title="Không onboard"
                      class="action-btn not-onboard-btn"
                      @click="handleMarkOnboard(displayJobAd.id, false)"
                    >
                      <Icon name="ci:stop-sign" />
                    </div>
                    <div
                      title="Sửa ngày onboard"
                      class="action-btn edit-onboard-date-btn"
                      @click="handleChangeOnboardDateClick(displayJobAd)"
                    >
                      <Icon name="ci:edit-pencil-01" />
                    </div>
                  </div>
                  <div class="flex flex-row justify-end">
                    <div
                      title="Loại ứng viên"
                      class="action-btn reject-btn"
                      @click="handleRejectClick(displayJobAd)"
                    >
                      <Icon name="material-symbols:close-rounded" />
                    </div>
                  </div>
                </template>
                <template
                  v-if="
                    displayJobAd.candidateStatus === 'ONBOARDED' ||
                    displayJobAd.candidateStatus === 'NOT_ONBOARDED'
                  "
                >
                  <div class="flex flex-row gap-1 justify-end flex-wrap">
                    <div
                      title="Onboard"
                      class="action-btn onboard-btn"
                      @click="handleMarkOnboard(displayJobAd.id, true)"
                    >
                      <Icon name="ci:check" />
                    </div>
                    <div
                      title="Không onboard"
                      class="action-btn not-onboard-btn"
                      @click="handleMarkOnboard(displayJobAd.id, false)"
                    >
                      <Icon name="ci:stop-sign" />
                    </div>
                  </div>
                  <div class="flex flex-row justify-end">
                    <div
                      title="Loại ứng viên"
                      class="action-btn reject-btn"
                      @click="handleRejectClick(displayJobAd)"
                    >
                      <Icon name="material-symbols:close-rounded" />
                    </div>
                  </div>
                </template>
              </template>
            </div>
          </div>
          <template v-if="displayJobAd.candidateStatus === 'REJECTED'">
            <div class="misc-text">
              {{ `Lý do loại: ${displayJobAd.eliminateReason.description}` }}
            </div>
            <div
              class="misc-text"
              v-if="displayJobAd.eliminateReasonDetail"
            >
              {{ `${displayJobAd.eliminateReasonDetail}` }}
            </div>
          </template>
          <template
            v-if="
              displayJobAd.candidateStatus === 'WAITING_ONBOARDING' ||
              displayJobAd.candidateStatus === 'ONBOARDED'
            "
          >
            <div class="misc-text">
              {{ `Thời gian onboard: ${formatDateTime(displayJobAd.onboardDate, "DD/MM/YYYY - HH:mm")}` }}
            </div>
          </template>
        </div>
      </template>
    </div>
  </div>
</template>
<script setup lang="ts">
import { CANDIDATE_STATUS } from "~/const/views/org/candidates";

type TProps = {
  jobAdInfos: Record<string, any>[];
  candidateInfo: Record<string, any>;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "refetch"): void;
}>();

const { markOnboard } = useCandidateApi();
const { setLoading } = useLoadingStore();

const isRejectModalOpen = ref<boolean>(false);
const isChangeProcessModalOpen = ref<boolean>(false);
const isChangeOnboardDateModalOpen = ref<boolean>(false);
const rejectingTarget = ref<any>(null);
const changeProcessTarget = ref<any>(null);
const changeDateTarget = ref<any>(null);

const processTooltip = computed(() => {
  return (process: any) => {
    let tooltip = "";
    if (process.actionDate) {
      const dateTime = formatDateTime(process.actionDate, "DD/MM/YYYY HH:mm");
      if (process.processName == "Ứng tuyển") {
        tooltip += `Ngày ứng tuyển: ${dateTime}`;
      } else {
        tooltip += `Ngày chuyển vòng: ${dateTime}`;
      }
    }

    return tooltip;
  };
});

const statusTooltip = computed(() => {
  return (displayJobAd: any) => {
    if (displayJobAd.candidateStatus === "REJECTED") {
      return formatDateTime(displayJobAd.eliminateDate, "DD/MM/YYYY - HH:mm");
    }
    return "";
  };
});

const displayJobAdCurrentProcessIndex = computed(() => {
  return (displayJobAd: any) => {
    let index = displayJobAd.jobAdProcessCandidates.findIndex(
      (process: any) => process.isCurrentProcess,
    );
    if (index == -1) {
      index = 0;
    }

    return index;
  };
});

const isOnboardStep = computed(() => {
  return (displayJobAd: any) => {
    const index =
      displayJobAd.jobAdProcessCandidates.findIndex(
        (process: any) => process.isCurrentProcess,
      ) || 0;

    return index === displayJobAd.jobAdProcessCandidates.length - 1;
  };
});

function clearRejectTarget() {
  rejectingTarget.value = null;
}

function clearChangeProcessTarget() {
  changeProcessTarget.value = null;
}

function clearChangeOnboardDateTarget() {
  changeDateTarget.value = null;
}

function handleRejectClick(jobAd: any) {
  isRejectModalOpen.value = true;
  rejectingTarget.value = jobAd;
}

function handleChangeProcessClick(jobAd: any) {
  console.log("change process of ", jobAd);
  isChangeProcessModalOpen.value = true;
  changeProcessTarget.value = jobAd;
}

function handleChangeOnboardDateClick(jobAd: any) {
  isChangeOnboardDateModalOpen.value = true;
  changeDateTarget.value = jobAd;
}

async function handleMarkOnboard(id: number | string, status: boolean) {
  setLoading(true);
  const res = await markOnboard(id, status);
  setLoading(false);
  if (res) {
    emits("refetch");
  }
}

function handleCandidateEliminated() {
  isRejectModalOpen.value = false;
  emits("refetch");
}

function handleChangeProcess() {
  isChangeProcessModalOpen.value = false;
  emits("refetch");
}

function handleChangeOnboardDate() {
  isChangeOnboardDateModalOpen.value = false;
  emits("refetch");
}

watch(isRejectModalOpen, (newVal) => {
  if (!newVal) {
    clearRejectTarget();
  }
});

watch(isChangeProcessModalOpen, (newVal) => {
  if (!newVal) {
    clearChangeProcessTarget();
  }
});

watch(isChangeOnboardDateModalOpen, (newVal) => {
  if (!newVal) {
    clearChangeOnboardDateTarget();
  }
});
</script>
<style lang="scss" scoped>
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

  &.submit-btn {
    background-color: $color-primary-500;
    border-color: 1px solid $color-primary-500;
    color: $text-dark;
  }
}

.job-ad-wrapper {
  font-size: 14px;
  display: flex;
  flex-direction: column;
  gap: 8px;

  .label {
    font-weight: 500;
    font-size: 16px;
    margin-top: 12px;
    color: $text-light;
  }

  .info {
    padding-right: 4px;
    display: flex;
    flex-direction: column;
    gap: 16px;

    .job-ad {
      border: 1px solid $color-gray-300;
      border-radius: 6px;
      padding: 6px;

      display: flex;
      flex-direction: column;
      gap: 8px;

      .misc-text {
        font-style: italic;
      }
    }
  }

  .title {
    font-weight: 500;
    font-size: 16px;
  }
  .hr-info {
    display: flex;
    flex-direction: row;
    gap: 8px;
    justify-content: space-between;
    flex-wrap: wrap;
    .hr-info-label {
      display: flex;
      flex-direction: row;
      gap: 4px;
      align-items: center;

      .iconify {
        display: block;
        font-size: 20px;
      }
    }
  }

  .processes {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    gap: 8px;

    .list {
      display: flex;
      flex-direction: column;

      .process {
        display: flex;
        flex-direction: column;

        .line {
          padding-left: 9px;
          &.highlighted {
            span {
              background-color: $color-primary-500;
            }
          }
          span {
            height: 16px;
            width: 2px;
            display: block;
            background-color: $color-gray-300;
          }
        }

        .dot {
          display: flex;
          flex-direction: row;
          align-items: center;
          gap: 4px;
          color: $color-gray-300;

          &.highlighted {
            color: $color-primary-500;
          }

          .iconify {
            display: block;
            font-size: 20px;
            min-width: 20px;
            min-height: 20px;
          }
        }
      }
    }

    .actions {
      display: flex;
      flex-direction: column;
      gap: 4px;

      .action-btn {
        height: 32px;
        width: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 1px solid $color-primary-500;
        cursor: pointer;
        border-radius: 4px;

        .iconify {
          font-size: 18px;
        }

        &.next-step-btn {
          border-color: $color-success;
          color: $color-success;
        }

        &.onboard-btn {
          border-color: $color-success;
          color: $color-success;
        }

        &.not-onboard-btn {
          border-color: $color-danger;
          color: $color-danger;
        }

        &.edit-onboard-date-btn {
          border-color: $color-warning;
          color: $color-warning;
        }

        &.reject-btn {
          border-color: $color-danger;
          color: $color-danger;
        }
      }
    }
  }

  .info-dept-pos {
    display: flex;
    flex-direction: row;
    gap: 8px;
  }

  .info-top {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;

    .chip {
      border-radius: 4px;
      padding: 4px;
      border: 1px solid $color-gray-300;
      font-size: 12px;
      font-weight: 500;
    }
  }

  .other-ad {
    border: 1px solid $color-gray-300;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;

    .chip {
      border-radius: 4px;
      padding: 4px;
      border: 1px solid $color-gray-300;
      font-size: 12px;
      font-weight: 500;
    }
  }

  .other-ad-list {
    border: 1px solid $color-gray-300;
    border-radius: 6px;

    display: flex;
    flex-direction: column;
    gap: 16px;
  }
}
</style>
