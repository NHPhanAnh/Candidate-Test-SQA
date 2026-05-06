<template>
  <div class="left">
    <div class="content">
      <div class="row">
        <div class="block">
          <div class="label">
            <Icon name="majesticons:megaphone-line" />
            <span>Tin tuyển dụng</span>
          </div>
          <div class="value">
            <div class="value">{{ detail.jobAd?.title }}</div>
            <Icon name="tabler:external-link cursor-pointer" @click="handleClickJobAd" />
          </div>
        </div>
      </div>
      <div class="row">
        <div class="block">
          <div class="label">
            <Icon name="material-symbols:step-over-rounded" />
            <span>Vòng hiện tại</span>
          </div>
          <div class="value">{{ detail.jobAdProcess?.name }}</div>
        </div>
      </div>
      <div class="row">
        <div class="block">
          <div class="label">
            <Icon name="material-symbols:event-available-outline-rounded" />
            <span>Thời gian tiếp nhận</span>
          </div>
          <div class="value">
            {{
              `${detail.date?.[2]}/${detail.date?.[1]}/${detail.date?.[0]} ${String(
                detail.timeFrom?.[0],
              ).padStart(
                2,
                "0",
              )}:${String(detail.timeFrom?.[1]).padStart(2, "0")} - ${String(
                detail.timeTo?.[0],
              ).padStart(
                2,
                "0",
              )}:${String(detail.timeTo?.[1]).padStart(2, "0")}`
            }}
          </div>
        </div>
      </div>
      <div class="row">
        <div class="block">
          <div class="label">
            <Icon name="material-symbols:calendar-month-outline-rounded" />
            <span>Loại lịch</span>
          </div>
          <div class="value">
            {{ detail.calendarType?.displayName }}
          </div>
        </div>
      </div>

      <div v-if="detail.location" class="row">
        <div class="block">
          <div class="label">
            <Icon name="material-symbols:location-on-outline-rounded" />
            <span>Địa điểm</span>
          </div>
          <div class="value">
            {{ detail.location?.displayAddress }}
          </div>
        </div>
      </div>
      <div v-if="detail.meetingLink" class="row">
        <div class="block">
          <div class="label">
            <Icon name="material-symbols:location-on-outline-rounded" />
            <span>Link phòng họp</span>
          </div>
          <a :href="detail.meetingLink" target="_blank" class="value link">
            {{ detail.meetingLink }}
          </a>
        </div>
      </div>
      <div class="row">
        <div class="block">
          <div class="label">
            <Icon name="material-symbols:edit-calendar-outline-rounded" />
            <span>Người tạo</span>
          </div>
          <div class="value">
            {{ detail.creator?.fullName }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  detail: any;
};

const props = defineProps<TProps>();

const router = useRouter();

function handleClickJobAd() {
  const link = router.resolve(`/org/job-ad/detail/${props.detail.jobAd?.id}`);
  window.open(link.href, "_blank");
}
</script>
<style lang="scss" scoped>
.left {
  max-height: 100%;
  display: flex;
  flex-direction: column;
  width: 60%;
  gap: 8px;

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

    .row {
      display: flex;
      flex-direction: row;
      justify-content: space-between;
      gap: 8px;
      flex-wrap: wrap;
    }

    .link {
      text-decoration: underline;
      color: $color-primary-500;
    }

    .block {
      font-size: 14px;
      display: flex;
      flex-direction: column;
      gap: 4px;

      .iconify {
        display: block;
        font-size: 14px;
        width: 14px;
        height: 14px;
      }

      .label {
        font-weight: 600;
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 6px;
      }

      .value {
        display: flex;
        flex-direction: row;
        gap: 6px;
        align-items: center;
      }
    }
  }
}
</style>
