<template>
  <div class="dashboard-page">
    <div class="page-header">
      <h1 class="page-title">Xin chào, {{ userName }} 👋</h1>
      <p class="page-subtitle">Tổng quan hoạt động ứng tuyển của bạn</p>
    </div>

    <!-- Stats Row -->
    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-icon applied">
          <Icon name="mdi:briefcase-check-outline" />
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ appliedJobs.length }}</div>
          <div class="stat-label">Việc đã ứng tuyển</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon pending">
          <Icon name="mdi:clock-outline" />
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ pendingCount }}</div>
          <div class="stat-label">Đang chờ xét duyệt</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon interview">
          <Icon name="mdi:calendar-check-outline" />
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ schedules.length }}</div>
          <div class="stat-label">Lịch phỏng vấn</div>
        </div>
      </div>
    </div>

    <div class="content-grid">
      <!-- Recent Applications -->
      <div class="card applied-section">
        <div class="card-header">
          <h2 class="card-title">
            <Icon name="mdi:briefcase-outline" class="card-icon" />
            Việc làm đã ứng tuyển gần đây
          </h2>
          <NuxtLink to="/application/list" class="see-all">Xem tất cả</NuxtLink>
        </div>
        <div v-if="isLoadingJobs" class="skeleton-list">
          <div v-for="i in 3" :key="i" class="skeleton-item" />
        </div>
        <div v-else-if="appliedJobs.length === 0" class="empty-state">
          <Icon name="mdi:briefcase-off-outline" class="empty-icon" />
          <p>Bạn chưa ứng tuyển việc làm nào</p>
          <NuxtLink to="/jobs" class="action-link">Tìm việc ngay</NuxtLink>
        </div>
        <div v-else class="job-list">
          <div v-for="job in appliedJobs.slice(0, 5)" :key="job.id" class="job-item">
            <div class="job-main">
              <div class="job-title">{{ job.jobAdTitle }}</div>
              <div class="job-org">{{ job.orgName }}</div>
            </div>
            <div class="job-meta">
              <span class="job-status" :class="statusClass(job.candidateStatus)">
                {{ statusLabel(job.candidateStatus) }}
              </span>
              <span class="job-date">{{ formatDate(job.applyDate) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Upcoming Interviews -->
      <div class="card schedule-section">
        <div class="card-header">
          <h2 class="card-title">
            <Icon name="mdi:calendar-month-outline" class="card-icon" />
            Lịch phỏng vấn sắp tới
          </h2>
        </div>
        <div v-if="isLoadingSchedules" class="skeleton-list">
          <div v-for="i in 2" :key="i" class="skeleton-item" />
        </div>
        <div v-else-if="schedules.length === 0" class="empty-state">
          <Icon name="mdi:calendar-blank-outline" class="empty-icon" />
          <p>Không có lịch phỏng vấn sắp tới</p>
        </div>
        <div v-else class="schedule-list">
          <div v-for="s in schedules.slice(0, 4)" :key="s.id" class="schedule-item">
            <div class="schedule-date-block">
              <div class="schedule-day">{{ formatDay(s.date) }}</div>
              <div class="schedule-month">{{ formatMonth(s.date) }}</div>
            </div>
            <div class="schedule-info">
              <div class="schedule-title">{{ s.jobAdTitle }}</div>
              <div class="schedule-time">
                <Icon name="mdi:clock-outline" />
                {{ s.timeFrom }} — {{ formatEndTime(s.timeFrom, s.durationMinutes) }}
              </div>
              <div v-if="s.meetingLink" class="schedule-link">
                <Icon name="mdi:video-outline" />
                <a :href="s.meetingLink" target="_blank">Tham gia phỏng vấn</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: "default" });
useHead({ title: "Dashboard - Ứng viên" });

const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);

const { getAppliedJobAds, getSchedules } = useCandidateApi();

const appliedJobs = ref<any[]>([]);
const schedules = ref<any[]>([]);
const isLoadingJobs = ref(true);
const isLoadingSchedules = ref(true);

const userName = computed(() => userInfo.value?.fullName || "bạn");

const pendingCount = computed(() =>
  appliedJobs.value.filter((j) => j.candidateStatus === "APPLYING").length
);

onMounted(async () => {
  const [jobsRes, schedRes] = await Promise.all([
    getAppliedJobAds({ pageIndex: 0, pageSize: 20 }),
    getSchedules({ pageIndex: 0, pageSize: 10 }),
  ]);

  if (jobsRes?.data) appliedJobs.value = jobsRes.data.data ?? [];
  isLoadingJobs.value = false;

  if (schedRes?.data) schedules.value = schedRes.data.data ?? [];
  isLoadingSchedules.value = false;
});

function statusLabel(status: string) {
  const map: Record<string, string> = {
    APPLYING: "Đang ứng tuyển",
    IN_PROGRESS: "Đang xét duyệt",
    HIRED: "Đã tuyển",
    ELIMINATED: "Không đạt",
  };
  return map[status] ?? status;
}
function statusClass(status: string) {
  const map: Record<string, string> = {
    APPLYING: "status-applying",
    IN_PROGRESS: "status-progress",
    HIRED: "status-hired",
    ELIMINATED: "status-eliminated",
  };
  return map[status] ?? "";
}
function formatDate(dateStr: string) {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleDateString("vi-VN");
}
function formatDay(dateStr: string) {
  return new Date(dateStr).getDate().toString().padStart(2, "0");
}
function formatMonth(dateStr: string) {
  return `Th${new Date(dateStr).getMonth() + 1}`;
}
function formatEndTime(timeFrom: string, duration: number) {
  if (!timeFrom) return "";
  const [h, m] = timeFrom.split(":").map(Number);
  const totalMin = h * 60 + m + duration;
  const endH = Math.floor(totalMin / 60);
  const endM = totalMin % 60;
  return `${String(endH).padStart(2, "0")}:${String(endM).padStart(2, "0")}`;
}
</script>

<style lang="scss" scoped>
.dashboard-page {
  padding: 4px 8px 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  height: 100%;
  overflow-y: auto;

  .page-header {
    .page-title {
      font-size: 22px;
      font-weight: 700;
      color: $text-dark;
      margin: 0;
    }
    .page-subtitle {
      font-size: 13px;
      color: $text-light;
      margin: 4px 0 0;
    }
  }

  .stats-row {
    display: flex;
    gap: 16px;
    flex-wrap: wrap;

    .stat-card {
      flex: 1;
      min-width: 160px;
      background: white;
      border-radius: 12px;
      padding: 16px;
      display: flex;
      align-items: center;
      gap: 16px;
      @include box-shadow;

      .stat-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;

        &.applied { background: rgba($color-primary-500, 0.1); color: $color-primary-500; }
        &.pending { background: rgba(#f59e0b, 0.1); color: #f59e0b; }
        &.interview { background: rgba(#10b981, 0.1); color: #10b981; }
      }

      .stat-info {
        .stat-value {
          font-size: 28px;
          font-weight: 800;
          color: $text-dark;
          line-height: 1;
        }
        .stat-label {
          font-size: 12px;
          color: $text-light;
          margin-top: 4px;
        }
      }
    }
  }

  .content-grid {
    display: grid;
    grid-template-columns: 1fr 380px;
    gap: 16px;
    @media (max-width: 900px) {
      grid-template-columns: 1fr;
    }
  }

  .card {
    background: white;
    border-radius: 12px;
    padding: 20px;
    @include box-shadow;

    .card-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 16px;

      .card-title {
        margin: 0;
        font-size: 15px;
        font-weight: 700;
        color: $text-dark;
        display: flex;
        align-items: center;
        gap: 8px;
        .card-icon { font-size: 18px; color: $color-primary-500; }
      }
      .see-all {
        font-size: 12px;
        color: $color-primary-400;
        cursor: pointer;
        &:hover { text-decoration: underline; }
      }
    }
  }

  .skeleton-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
    .skeleton-item {
      height: 60px;
      border-radius: 8px;
      background: linear-gradient(90deg, $color-gray-100 25%, $color-gray-200 50%, $color-gray-100 75%);
      background-size: 200% 100%;
      animation: shimmer 1.5s infinite;
    }
  }

  @keyframes shimmer {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
  }

  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 32px 16px;
    gap: 8px;
    color: $text-light;
    .empty-icon { font-size: 48px; opacity: 0.4; }
    p { font-size: 14px; margin: 0; }
    .action-link {
      font-size: 13px;
      color: $color-primary-500;
      font-weight: 600;
      margin-top: 4px;
      &:hover { text-decoration: underline; }
    }
  }

  .job-list {
    display: flex;
    flex-direction: column;
    gap: 10px;

    .job-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px 14px;
      border-radius: 8px;
      border: 1px solid $color-gray-200;
      transition: background-color 150ms;
      &:hover { background: $color-gray-100; }

      .job-main {
        .job-title { font-size: 14px; font-weight: 600; color: $text-dark; }
        .job-org { font-size: 12px; color: $text-light; margin-top: 2px; }
      }

      .job-meta {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        gap: 4px;

        .job-status {
          font-size: 11px;
          padding: 2px 8px;
          border-radius: 20px;
          font-weight: 600;
          &.status-applying { background: rgba($color-primary-500, 0.1); color: $color-primary-500; }
          &.status-progress { background: rgba(#f59e0b, 0.1); color: #b45309; }
          &.status-hired { background: rgba(#10b981, 0.1); color: #047857; }
          &.status-eliminated { background: rgba(#ef4444, 0.1); color: #dc2626; }
        }
        .job-date { font-size: 11px; color: $text-light; }
      }
    }
  }

  .schedule-list {
    display: flex;
    flex-direction: column;
    gap: 12px;

    .schedule-item {
      display: flex;
      gap: 14px;
      padding: 12px;
      border-radius: 8px;
      border: 1px solid $color-gray-200;
      align-items: flex-start;

      .schedule-date-block {
        background: $color-primary-500;
        color: white;
        border-radius: 8px;
        padding: 8px 12px;
        text-align: center;
        min-width: 52px;
        flex-shrink: 0;
        .schedule-day { font-size: 22px; font-weight: 800; line-height: 1; }
        .schedule-month { font-size: 11px; margin-top: 2px; }
      }

      .schedule-info {
        flex: 1;
        .schedule-title { font-size: 13px; font-weight: 600; color: $text-dark; }
        .schedule-time {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 12px;
          color: $text-light;
          margin-top: 4px;
        }
        .schedule-link {
          display: flex;
          align-items: center;
          gap: 4px;
          margin-top: 4px;
          font-size: 12px;
          a { color: $color-primary-500; text-decoration: underline; }
        }
      }
    }
  }
}
</style>
