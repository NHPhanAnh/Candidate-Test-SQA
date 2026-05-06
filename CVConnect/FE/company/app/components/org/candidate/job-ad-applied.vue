<template>
  <div class="job-ad-applied">
    <div class="title">{{ props.data.jobAd.title }}</div>
    <div class="info">
      <div class="col">
        <div class="date info-row">
          <span class="label">Ngày ứng tuyển</span>
          <span class="value">{{
            formatDateTime(props.data.applyDate, "DD/MM/YYYY - HH:mm")
          }}</span>
        </div>
        <div class="status info-row">
          <span class="label">Trạng thái</span>
          <span
            class="value chip"
            :style="{
              borderColor: CANDIDATE_STATUS[props.data.candidateStatus].color,
              color: CANDIDATE_STATUS[props.data.candidateStatus].color,
              backgroundColor:
                CANDIDATE_STATUS[props.data.candidateStatus].background,
            }"
            >{{ CANDIDATE_STATUS[props.data.candidateStatus].label }}</span
          >
        </div>
      </div>
      <div class="col">
        <div class="hr-info info-row">
          <span class="label">Tên HR</span>
          <span class="value">{{ props.data.jobAd.hrContactName }}</span>
        </div>
        <div class="current-round info-row">
          <span class="label">Vòng hiện tại</span>
          <span
            class="value chip"
            :style="{
              borderColor: PROCESS_COLOR_CODE[props.data.currentRound.code],
              color: PROCESS_COLOR_CODE[props.data.currentRound.code],
              backgroundColor: `${PROCESS_COLOR_CODE[props.data.currentRound.code]}0D`,
            }"
            >{{ props.data.currentRound.name }}</span
          >
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { CANDIDATE_STATUS } from "~/const/views/org/candidates";
import { PROCESS_COLOR_CODE } from "~/const/views/system-admin/process-type";
import type { TJobAdCandidateApplied } from "~/types/candidate";

type TProps = {
  data: TJobAdCandidateApplied;
};

const props = defineProps<TProps>();
</script>
<style lang="scss" scoped>
.job-ad-applied {
  border-top: 1px solid $color-gray-100;
  border-bottom: 1px solid $color-gray-100;
  padding: 6px 8px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  .title {
    font-weight: 600;
    font-size: 14px;
  }

  .info {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    gap: 24px;
  }

  .col {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .info-row {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 24px;
    font-size: 14px;

    .label {
      min-width: 120px;
    }
  }

  .chip {
    border-radius: 4px;
    padding: 4px;
    border: 1px solid $color-gray-300;
    font-size: 12px;
    font-weight: 500;
  }
}
</style>
