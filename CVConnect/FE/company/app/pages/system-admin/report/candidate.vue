<template>
  <div class="candidate-report-page">
    <div class="page-header">
      <h1 class="page-title">
        <Icon name="mdi:account-group-outline" class="title-icon" />
        Báo cáo Ứng viên
      </h1>
      <p class="page-subtitle">Tổng quan dữ liệu ứng viên trên hệ thống</p>
    </div>

    <!-- Stats summary row -->
    <div class="stats-row">
      <div class="stat-card blue">
        <Icon name="mdi:account-multiple-outline" class="stat-icon" />
        <div class="stat-info">
          <div class="stat-value">{{ stats.totalCandidates }}</div>
          <div class="stat-label">Tổng ứng viên</div>
        </div>
      </div>
      <div class="stat-card green">
        <Icon name="mdi:briefcase-check-outline" class="stat-icon" />
        <div class="stat-info">
          <div class="stat-value">{{ stats.totalApplications }}</div>
          <div class="stat-label">Tổng đơn ứng tuyển</div>
        </div>
      </div>
      <div class="stat-card amber">
        <Icon name="mdi:trophy-outline" class="stat-icon" />
        <div class="stat-info">
          <div class="stat-value">{{ stats.hiredCount }}</div>
          <div class="stat-label">Được tuyển</div>
        </div>
      </div>
      <div class="stat-card purple">
        <Icon name="mdi:domain" class="stat-icon" />
        <div class="stat-info">
          <div class="stat-value">{{ stats.totalOrgs }}</div>
          <div class="stat-label">Tổ chức tuyển dụng</div>
        </div>
      </div>
    </div>

    <!-- Recent candidates table -->
    <div class="section-card">
      <div class="section-header">
        <h2 class="section-title">
          <Icon name="mdi:account-search-outline" class="section-icon" />
          Danh sách ứng viên gần đây
        </h2>
        <NuxtLink to="/system-admin/users" class="see-all">Xem tất cả người dùng →</NuxtLink>
      </div>

      <div v-if="isLoading" class="skeleton-list">
        <div v-for="i in 5" :key="i" class="skeleton-row" />
      </div>

      <div v-else-if="candidates.length === 0" class="empty-state">
        <Icon name="mdi:account-off-outline" class="empty-icon" />
        <p>Chưa có dữ liệu ứng viên</p>
      </div>

      <div v-else class="candidate-table">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Tên người dùng</th>
              <th>Họ và tên</th>
              <th>Email</th>
              <th>Xác thực email</th>
              <th>Ngày tạo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(c, idx) in candidates" :key="c.id">
              <td class="idx-cell">{{ idx + 1 }}</td>
              <td class="username-cell">{{ c.username }}</td>
              <td>{{ c.fullName }}</td>
              <td class="email-cell">{{ c.email }}</td>
              <td>
                <span class="verify-badge" :class="c.emailVerified ? 'verified' : 'unverified'">
                  <Icon :name="c.emailVerified ? 'mdi:check-circle' : 'mdi:clock-outline'" />
                  {{ c.emailVerified ? "Đã xác thực" : "Chưa xác thực" }}
                </span>
              </td>
              <td class="date-cell">{{ formatDate(c.createdAt) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: "system-admin" });
useHead({ title: "Báo cáo Ứng viên" });

const { $axios } = useNuxtApp();

const isLoading = ref(true);
const candidates = ref<any[]>([]);
const stats = reactive({
  totalCandidates: 0,
  totalApplications: 0,
  hiredCount: 0,
  totalOrgs: 0,
});

onMounted(async () => {
  try {
    // Fetch users with CANDIDATE role
    const res = await $axios.get(
      "/_api/user/user/filter?roleCode=CANDIDATE&pageIndex=0&pageSize=20",
    );
    if (res.data?.data) {
      const data = res.data.data;
      candidates.value = data.data ?? [];
      stats.totalCandidates = data.pageInfo?.totalElements ?? candidates.value.length;
    }
  } catch (e) {
    console.error("Failed to load candidates", e);
  }

  try {
    // Fetch orgs count
    const orgRes = await $axios.get("/_api/core/org/filter?pageIndex=0&pageSize=1");
    if (orgRes.data?.data?.pageInfo) {
      stats.totalOrgs = orgRes.data.data.pageInfo.totalElements ?? 0;
    }
  } catch (e) {
    // ignore
  }

  try {
    // Fetch job-ad-candidate stats
    const appRes = await $axios.get(
      "/_api/core/job-ad-candidate/filter?pageIndex=0&pageSize=1",
    );
    if (appRes.data?.data?.pageInfo) {
      stats.totalApplications = appRes.data.data.pageInfo.totalElements ?? 0;
    }
    const hiredRes = await $axios.get(
      "/_api/core/job-ad-candidate/filter?pageIndex=0&pageSize=1&candidateStatus=HIRED",
    );
    if (hiredRes.data?.data?.pageInfo) {
      stats.hiredCount = hiredRes.data.data.pageInfo.totalElements ?? 0;
    }
  } catch (e) {
    // ignore
  }

  isLoading.value = false;
});

function formatDate(dateStr: string) {
  if (!dateStr) return "—";
  return new Date(dateStr).toLocaleDateString("vi-VN");
}
</script>

<style lang="scss" scoped>
.candidate-report-page {
  padding: 4px 0 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;

  .page-header {
    .page-title {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 20px;
      font-weight: 700;
      color: $text-dark;
      margin: 0;
      .title-icon { color: $color-primary-500; font-size: 22px; }
    }
    .page-subtitle {
      font-size: 13px;
      color: $text-light;
      margin: 4px 0 0;
    }
  }

  .stats-row {
    display: flex;
    gap: 14px;
    flex-wrap: wrap;

    .stat-card {
      flex: 1;
      min-width: 150px;
      background: white;
      border-radius: 12px;
      padding: 18px 20px;
      display: flex;
      align-items: center;
      gap: 14px;
      @include box-shadow;
      border-left: 4px solid transparent;

      &.blue { border-color: #3b82f6; .stat-icon { color: #3b82f6; } }
      &.green { border-color: #10b981; .stat-icon { color: #10b981; } }
      &.amber { border-color: #f59e0b; .stat-icon { color: #f59e0b; } }
      &.purple { border-color: #8b5cf6; .stat-icon { color: #8b5cf6; } }

      .stat-icon { font-size: 32px; }

      .stat-info {
        .stat-value { font-size: 28px; font-weight: 800; color: $text-dark; line-height: 1; }
        .stat-label { font-size: 12px; color: $text-light; margin-top: 4px; }
      }
    }
  }

  .section-card {
    background: white;
    border-radius: 12px;
    padding: 20px;
    @include box-shadow;

    .section-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 16px;

      .section-title {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 15px;
        font-weight: 700;
        color: $text-dark;
        margin: 0;
        .section-icon { color: $color-primary-500; }
      }
      .see-all {
        font-size: 13px;
        color: $color-primary-400;
        &:hover { text-decoration: underline; }
      }
    }
  }

  .skeleton-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    .skeleton-row {
      height: 44px;
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
    padding: 40px;
    gap: 8px;
    color: $text-light;
    .empty-icon { font-size: 48px; opacity: 0.35; }
    p { margin: 0; font-size: 14px; }
  }

  .candidate-table {
    overflow-x: auto;

    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;

      thead tr {
        background: $color-gray-100;
        th {
          padding: 10px 12px;
          text-align: left;
          font-weight: 600;
          color: $text-light;
          white-space: nowrap;
          border-bottom: 1px solid $color-gray-200;
        }
      }

      tbody tr {
        border-bottom: 1px solid $color-gray-100;
        transition: background-color 150ms;
        &:hover { background: rgba($color-primary-500, 0.03); }

        td {
          padding: 10px 12px;
          color: $text-dark;
          vertical-align: middle;

          &.idx-cell { color: $text-light; font-size: 12px; }
          &.username-cell { font-weight: 600; }
          &.email-cell { color: $text-light; }
          &.date-cell { color: $text-light; white-space: nowrap; }
        }
      }
    }
  }

  .verify-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 2px 8px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 600;

    &.verified { background: rgba(#10b981, 0.1); color: #047857; }
    &.unverified { background: rgba(#f59e0b, 0.1); color: #b45309; }
  }
}
</style>
