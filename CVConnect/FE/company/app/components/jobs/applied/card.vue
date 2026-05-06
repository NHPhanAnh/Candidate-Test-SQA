<template>
  <div class="applied-job-card">
    <ModalsAppliedDetail v-model="isDetailModalShow" :detail="props.data" />
    <div class="top row space-between">
      <div class="logo-section">
        <div class="logo">
          <img :src="props.data.org?.logoUrl" alt="Logo công ty" />
        </div>
        <div class="info-section">
          <div class="title">
            {{ props.data.jobAd.title }}
            <Icon
              class="external-link"
              name="ci:external-link"
              @click="handleViewDetailJob"
            />
          </div>
          <div class="company-name">{{ props.data.org.name }}</div>
          <div class="block">
            <div class="label">
              <Icon name="material-symbols:event-available-rounded" />
              <span>Ngày ứng tuyển</span>
            </div>
            <span class="value">{{
              formatDateTime(props.data.applyDate, "DD/MM/YYYY HH:mm")
            }}</span>
          </div>
        </div>
      </div>
      <span
        class="value chip"
        :style="{
          borderColor:
            CANDIDATE_STATUS[props.data.candidateStatusDto.name].color,
          color: CANDIDATE_STATUS[props.data.candidateStatusDto.name].color,
          backgroundColor:
            CANDIDATE_STATUS[props.data.candidateStatusDto.name].background,
        }"
        >{{ props.data.candidateStatusDto.label }}</span
      >
    </div>
    <div class="body">
      <div class="block">
        <div class="label">
          <Icon name="fluent:step-24-filled" />
          <span>Vòng hiện tại</span>
        </div>
        <span
          class="chip"
          :style="{
            borderColor: PROCESS_COLOR_CODE[props.data.currentRound.code],
            color: PROCESS_COLOR_CODE[props.data.currentRound.code],
            backgroundColor: `${PROCESS_COLOR_CODE[props.data.currentRound.code]}0D`,
          }"
        >
          {{ props.data.currentRound.name }}
        </span>
      </div>
      <div
        v-if="
          props.data.onboardDate &&
          props.data.candidateStatusDto.name != 'REJECTED'
        "
        class="block"
      >
        <div class="label">
          <Icon name="material-symbols:event-available-rounded" />
          <span>Ngày onboard</span>
        </div>
        <span class="value">{{
          formatDateTime(props.data.onboardDate, "DD/MM/YYYY HH:mm")
        }}</span>
      </div>
      <div
        v-if="props.data.candidateStatusDto.name == 'REJECTED'"
        class="block"
      >
        <div class="label">
          <Icon name="material-symbols:event-busy-rounded" />
          <span>Ngày bị loại</span>
        </div>
        <span class="value">{{
          formatDateTime(props.data.eliminateDate, "DD/MM/YYYY HH:mm")
        }}</span>
      </div>
      <div
        v-if="props.data.candidateStatusDto.name == 'REJECTED'"
        class="block"
      >
        <div class="label">
          <Icon name="material-symbols:edit-note-rounded" />
          <span>Lí do bị loại</span>
        </div>
        <span class="value">{{ props.data.eliminateReason.description }}</span>
      </div>
      <div class="divider"></div>
      <div class="bottom">
        <div
          class="message-btn"
          :class="{ 'has-new': props.data.hasMessageUnread }"
        >
          Tin nhắn
        </div>
        <div class="detail-btn" @click="handleViewDetail">Thông tin ứng tuyển</div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { CANDIDATE_STATUS } from "~/const/views/org/candidates";
import { PROCESS_COLOR_CODE } from "~/const/views/system-admin/process-type";

type TProps = {
  data: any;
};

const router = useRouter();

const props = defineProps<TProps>();

const isDetailModalShow = ref<boolean>(false);

function handleViewDetailJob() {
  const link = router.resolve({ path: `/job-ad/detail/${props.data.id}` });

  window.open(link.href, "_blank");
}

function handleViewDetail() {
  isDetailModalShow.value = true;
}
</script>
<style lang="scss" scoped>
.applied-job-card {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px;
  border-radius: 12px;
  border: 1px solid $color-gray-300;
  width: 100%;
  color: $text-light;

  .iconify {
    display: inline-block;
    font-size: 20px;
    height: 20px;
    width: 20px;
    min-width: 20px;
    color: $color-gray-500;
  }

  .external-link {
    color: $color-info;
    cursor: pointer;
  }

  .row {
    display: flex;
    flex-direction: row;
    gap: 8px;
    align-items: center;
  }

  .space-between {
    justify-content: space-between;
  }

  .title {
    font-size: 14px;
    font-weight: 600;
  }

  .top {
    align-items: flex-start;

    .info-section {
      display: flex;
      flex-direction: column;
      gap: 2px;

      .company-name {
        color: $color-gray-400;
        font-size: 14px;
      }
    }

    .logo-section {
      display: flex;
      flex-direction: row;
      gap: 8px;

      .logo {
        display: block;
        height: 64px;
        width: 64px;
        min-width: 64px;
        border-radius: 12px;
        overflow: hidden;
        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
          border-radius: inherit;
        }
      }
    }
  }

  .chip {
    border-radius: 4px;
    padding: 4px;
    border: 1px solid $color-gray-300;
    font-size: 12px;
    font-weight: 500;
  }

  .block {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 8px;
    font-size: 13px;

    .label {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 4px;
      color: $color-gray-500;
    }
  }

  .body {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .divider {
    width: 100%;
    height: 1px;
    display: block;
    background-color: $color-gray-200;
  }

  .bottom {
    display: flex;
    flex-direction: row;
    justify-content: flex-end;
    gap: 8px;

    .message-btn {
      padding: 4px 8px;
      background-color: white;
      border: 1px solid $color-primary-400;
      color: $color-primary-400;
      font-size: 14px;
      border-radius: 6px;
      cursor: pointer;
      position: relative;

      &.has-new {
        &::after {
          content: "";
          position: absolute;
          display: block;
          height: 10px;
          width: 10px;
          border-radius: 999px;
          background-color: $color-primary-400;
          top: -4px;
          right: -4px;
        }
      }
    }

    .detail-btn {
      padding: 4px 8px;
      background-color: $color-primary-400;
      border: 1px solid $color-primary-400;
      color: $text-dark;
      font-size: 14px;
      border-radius: 6px;
      cursor: pointer;
      position: relative;
    }
  }
}
</style>
