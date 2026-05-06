<template>
  <div class="candidate-card">
    <div class="fullName row">
      <span class="text">{{ props.candidateData.candidateInfo.fullName }}</span>
      <AppButton
        class="view-detail-btn"
        text="Xem chi tiết"
        @click="handleViewDetail"
      />
    </div>

    <div class="info-row contact-info">
      <div class="email row" title="Email">
        <Icon name="material-symbols:mail-outline-rounded" />
        <span>{{ props.candidateData.candidateInfo.email }}</span>
      </div>
      <div class="phone row" title="Số điện thoại">
        <Icon name="material-symbols:call-outline-rounded" />
        <span>{{ props.candidateData.candidateInfo.phone }}</span>
      </div>
      <div
        v-if="props.candidateData.candidateInfo.candidateSummaryOrg.level.levelName"
        class="level row"
        title="Cấp bậc"
      >
        <Icon name="carbon:skill-level-basic" />
        <span>{{
          props.candidateData.candidateInfo.candidateSummaryOrg.level.levelName
        }}</span>
      </div>
    </div>

    <div class="accordant">
      <div
        class="header"
        :class="{ expanded: isExpanded }"
        @click="isExpanded = !isExpanded"
      >
        <span class="title">
          {{ `Đã ứng tuyển vào ${props.candidateData.numOfApply} tin` }}
        </span>
        <Icon v-if="!isExpanded" name="mdi:chevron-down" />
        <Icon v-else name="mdi:chevron-up" />
      </div>

      <div v-show="isExpanded" class="expanded-area">
        <table class="applied-table">
          <thead>
            <tr>
              <th>Tin tuyển dụng</th>
              <th>Trạng thái</th>
              <th>Loại vòng hiện tại</th>
              <th>Ngày ứng tuyển</th>
              <th>HR phụ trách</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(applied, index) in props.candidateData.jobAdCandidates"
              :key="index"
            >
              <td :title="applied.jobAd.title">
                {{ applied.jobAd.title }}
              </td>
              <td :title="CANDIDATE_STATUS[applied.candidateStatus].label">
                <span
                  class="chip"
                  :style="{
                    borderColor:
                      CANDIDATE_STATUS[applied.candidateStatus].color,
                    color: CANDIDATE_STATUS[applied.candidateStatus].color,
                    backgroundColor:
                      CANDIDATE_STATUS[applied.candidateStatus].background,
                  }"
                >
                  {{ CANDIDATE_STATUS[applied.candidateStatus].label }}
                </span>
              </td>
              <td :title="applied.currentRound.name">
                <span
                  class="chip"
                  :style="{
                    borderColor: PROCESS_COLOR_CODE[applied.currentRound.code],
                    color: PROCESS_COLOR_CODE[applied.currentRound.code],
                    backgroundColor: `${PROCESS_COLOR_CODE[applied.currentRound.code]}0D`,
                  }"
                >
                  {{ applied.currentRound.name }}
                </span>
              </td>
              <td
                :title="formatDateTime(applied.applyDate, 'DD/MM/YYYY - HH:mm')"
              >
                {{ formatDateTime(applied.applyDate, "DD/MM/YYYY - HH:mm") }}
              </td>
              <td :title="applied.jobAd.hrContactName">
                {{ applied.jobAd.hrContactName }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { CANDIDATE_STATUS } from "~/const/views/org/candidates";
import { PROCESS_COLOR_CODE } from "~/const/views/system-admin/process-type";
import { formatDateTime } from "~/utils/date";
import type { TJobAdCandidate } from "~/types/candidate";

type TProps = {
  candidateData: TJobAdCandidate;
};

const props = defineProps<TProps>();
const isExpanded = ref(false);
const router = useRouter();

function expand() {
  isExpanded.value = true;
}
function close() {
  isExpanded.value = false;
}

function handleViewDetail() {
  const resolved = router.resolve({
    path: `/org/candidate/detail/${props.candidateData.candidateInfo.id}`,
  });
  window.open(resolved.href, "_blank");
}

defineExpose({
  expand,
  close,
});
</script>

<style lang="scss" scoped>
.candidate-card {
  display: flex;
  flex-direction: column;
  padding: 12px 12px 24px;
  border: 2px solid $color-gray-200;
  border-radius: 12px;
  min-width: 360px;
  max-height: fit-content;

  .fullName {
    justify-content: space-between;
    margin-bottom: 12px;
    .text {
      font-size: 16px;
      font-weight: 600;
    }
  }

  .info-row {
    display: flex;
    flex-direction: row;
    gap: 48px;
    row-gap: 8px;
    align-items: center;
    font-size: 14px;
    flex-wrap: wrap;
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 12px;
    align-items: center;
    font-size: 14px;
  }

  .contact-info {
    margin-bottom: 8px;
  }

  .iconify {
    font-size: 20px;
  }

  .accordant {
    margin-top: 12px;
    display: flex;
    flex-direction: column;
    border: 1px solid $color-gray-100;
    border-radius: 7px;
    overflow: hidden;

    .header {
      cursor: pointer;
      padding: 8px 12px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      background-color: $color-gray-100;
      font-size: 14px;

      &.expanded {
        border-bottom-left-radius: 0;
        border-bottom-right-radius: 0;
      }
    }

    .expanded-area {
      padding: 12px;
      background-color: #fff;
      overflow-x: auto;
      @include custom-scrollbar;

      .applied-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 14px;
        table-layout: fixed;

        th,
        td {
          padding: 8px;
          border-bottom: 1px solid $color-gray-50;
          vertical-align: middle;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        th {
          text-align: left;
          font-weight: 600;
          color: $color-gray-600;
          border-bottom: 1px solid $color-gray-100;
        }

        th:nth-child(1),
        td:nth-child(1) {
          width: 30%;
        }

        th:nth-child(2),
        td:nth-child(2) {
          width: 15%;
        }

        th:nth-child(3),
        td:nth-child(3) {
          width: 20%;
        }

        th:nth-child(4),
        td:nth-child(4) {
          width: 20%;
        }

        th:nth-child(5),
        td:nth-child(5) {
          width: 15%;
        }

        .chip {
          display: inline-block;
          padding: 4px 6px;
          border: 1px solid;
          border-radius: 6px;
          font-size: 12px;
          font-weight: 500;
          line-height: 1.2;
        }
      }
    }
  }

  .view-detail-btn {
    padding: 6px 12px;
    font-size: 14px;
    background-color: $color-primary-500;
    color: $text-dark;
  }
}
</style>
