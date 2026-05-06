<template>
  <div class="application-list-page">
    <div class="page-header">
      <h1 class="page-title">
        <Icon name="mdi:briefcase-check-outline" class="title-icon" />
        Danh sách đơn ứng tuyển
      </h1>
      <p class="page-subtitle">Tất cả các vị trí bạn đã ứng tuyển</p>
    </div>

    <!-- Filter Bar -->
    <div class="filter-bar">
      <UInput
        v-model="searchKeyword"
        icon="i-heroicons-magnifying-glass"
        placeholder="Tìm kiếm theo tên vị trí, công ty..."
        class="search-input"
        @input="handleSearch"
      />
      <select v-model="statusFilter" class="status-filter" @change="handleFilter">
        <option value="">Tất cả trạng thái</option>
        <option value="APPLYING">Đang ứng tuyển</option>
        <option value="IN_PROGRESS">Đang xét duyệt</option>
        <option value="HIRED">Đã tuyển</option>
        <option value="ELIMINATED">Không đạt</option>
      </select>
    </div>

    <!-- Skeleton loading -->
    <div v-if="isLoading" class="skeleton-list">
      <div v-for="i in 5" :key="i" class="skeleton-row" />
    </div>

    <!-- Empty state -->
    <div v-else-if="filteredList.length === 0" class="empty-state">
      <Icon name="mdi:briefcase-off-outline" class="empty-icon" />
      <p class="empty-text">
        {{ searchKeyword || statusFilter ? "Không tìm thấy kết quả phù hợp" : "Bạn chưa ứng tuyển vị trí nào" }}
      </p>
      <NuxtLink to="/jobs" class="browse-link">
        <Icon name="mdi:magnify" /> Tìm việc làm ngay
      </NuxtLink>
    </div>

    <!-- List -->
    <div v-else class="list-wrapper">
      <div
        v-for="job in filteredList"
        :key="job.id"
        class="application-card"
      >
        <div class="card-left">
          <div class="org-avatar">
            <img v-if="job.orgAvatarUrl" :src="job.orgAvatarUrl" :alt="job.orgName" />
            <Icon v-else name="mdi:office-building" class="default-org-icon" />
          </div>
          <div class="job-info">
            <div class="job-title">{{ job.jobAdTitle }}</div>
            <div class="job-org">
              <Icon name="mdi:office-building-outline" />
              {{ job.orgName }}
            </div>
            <div class="job-meta-row">
              <span class="job-type">
                <Icon name="mdi:clock-outline" />
                {{ jobTypeLabel(job.jobType) }}
              </span>
              <span class="apply-date">
                <Icon name="mdi:calendar-outline" />
                Ứng tuyển: {{ formatDate(job.applyDate) }}
              </span>
            </div>
          </div>
        </div>
        <div class="card-right">
          <span class="status-badge" :class="statusClass(job.candidateStatus)">
            {{ statusLabel(job.candidateStatus) }}
          </span>
          <NuxtLink :to="`/job-ad/${job.jobAdId}`" class="view-link">
            Xem tin tuyển dụng
          </NuxtLink>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="pagination">
        <button
          :disabled="currentPage === 0"
          class="page-btn"
          @click="changePage(currentPage - 1)"
        >
          <Icon name="mdi:chevron-left" />
        </button>
        <span class="page-info">Trang {{ currentPage + 1 }} / {{ totalPages }}</span>
        <button
          :disabled="currentPage >= totalPages - 1"
          class="page-btn"
          @click="changePage(currentPage + 1)"
        >
          <Icon name="mdi:chevron-right" />
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: "default" });
useHead({ title: "Đơn ứng tuyển của tôi" });

const { getAppliedJobAds } = useCandidateApi();

const applications = ref<any[]>([]);
const isLoading = ref(true);
const currentPage = ref(0);
const pageSize = 10;
const totalItems = ref(0);
const searchKeyword = ref("");
const statusFilter = ref("");

const totalPages = computed(() => Math.ceil(totalItems.value / pageSize));

const filteredList = computed(() => {
  let list = applications.value;
  const kw = searchKeyword.value.toLowerCase().trim();
  if (kw) {
    list = list.filter(
      (j) =>
        j.jobAdTitle?.toLowerCase().includes(kw) ||
        j.orgName?.toLowerCase().includes(kw),
    );
  }
  if (statusFilter.value) {
    list = list.filter((j) => j.candidateStatus === statusFilter.value);
  }
  return list;
});

async function fetchData() {
  isLoading.value = true;
  const res = await getAppliedJobAds({
    pageIndex: currentPage.value,
    pageSize,
  });
  if (res?.data) {
    applications.value = res.data.data ?? [];
    totalItems.value = res.data.totalItems ?? applications.value.length;
  }
  isLoading.value = false;
}

onMounted(fetchData);

function changePage(page: number) {
  currentPage.value = page;
  fetchData();
}

function handleSearch() {
  currentPage.value = 0;
}
function handleFilter() {
  currentPage.value = 0;
}

function formatDate(dateStr: string) {
  if (!dateStr) return "—";
  return new Date(dateStr).toLocaleDateString("vi-VN");
}

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

function jobTypeLabel(type: string) {
  const map: Record<string, string> = {
    FULL_TIME: "Toàn thời gian",
    PART_TIME: "Bán thời gian",
    INTERN: "Thực tập",
    FREELANCE: "Freelance",
  };
  return map[type] ?? type;
}
</script>

<style lang="scss" scoped>
.application-list-page {
  padding: 4px 8px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  height: 100%;
  overflow-y: auto;

  .page-header {
    .page-title {
      font-size: 20px;
      font-weight: 700;
      color: $text-dark;
      margin: 0;
      display: flex;
      align-items: center;
      gap: 8px;
      .title-icon { font-size: 22px; color: $color-primary-500; }
    }
    .page-subtitle {
      font-size: 13px;
      color: $text-light;
      margin: 4px 0 0;
    }
  }

  .filter-bar {
    display: flex;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;

    .search-input {
      flex: 1;
      min-width: 200px;
    }

    .status-filter {
      padding: 8px 12px;
      border: 1px solid $color-gray-300;
      border-radius: 8px;
      font-size: 13px;
      color: $text-dark;
      background: white;
      cursor: pointer;
      outline: none;
      &:focus { border-color: $color-primary-500; }
    }
  }

  .skeleton-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
    .skeleton-row {
      height: 88px;
      border-radius: 12px;
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
    padding: 60px 16px;
    gap: 12px;
    color: $text-light;

    .empty-icon { font-size: 64px; opacity: 0.35; }
    .empty-text { font-size: 15px; margin: 0; }

    .browse-link {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 10px 20px;
      background: $color-primary-500;
      color: $text-dark;
      border-radius: 8px;
      font-weight: 600;
      font-size: 14px;
      margin-top: 8px;
      transition: opacity 150ms;
      &:hover { opacity: 0.85; }
    }
  }

  .list-wrapper {
    display: flex;
    flex-direction: column;
    gap: 10px;

    .application-card {
      background: white;
      border-radius: 12px;
      padding: 16px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      @include box-shadow;
      border: 1px solid $color-gray-200;
      transition: border-color 150ms;
      &:hover { border-color: $color-primary-500; }

      .card-left {
        display: flex;
        align-items: center;
        gap: 14px;
        flex: 1;
        min-width: 0;

        .org-avatar {
          width: 48px;
          height: 48px;
          border-radius: 10px;
          border: 1px solid $color-gray-200;
          overflow: hidden;
          flex-shrink: 0;
          display: flex;
          align-items: center;
          justify-content: center;
          background: $color-gray-100;

          img { width: 100%; height: 100%; object-fit: cover; }
          .default-org-icon { font-size: 24px; color: $color-gray-400; }
        }

        .job-info {
          flex: 1;
          min-width: 0;

          .job-title {
            font-size: 14px;
            font-weight: 700;
            color: $text-dark;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }

          .job-org {
            display: flex;
            align-items: center;
            gap: 4px;
            font-size: 12px;
            color: $text-light;
            margin-top: 2px;
          }

          .job-meta-row {
            display: flex;
            gap: 14px;
            margin-top: 4px;
            flex-wrap: wrap;

            .job-type,
            .apply-date {
              display: flex;
              align-items: center;
              gap: 4px;
              font-size: 11px;
              color: $text-light;
            }
          }
        }
      }

      .card-right {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        gap: 8px;
        flex-shrink: 0;

        .status-badge {
          padding: 4px 12px;
          border-radius: 20px;
          font-size: 12px;
          font-weight: 600;

          &.status-applying { background: rgba($color-primary-500, 0.12); color: $color-primary-500; }
          &.status-progress { background: rgba(#f59e0b, 0.12); color: #b45309; }
          &.status-hired { background: rgba(#10b981, 0.12); color: #047857; }
          &.status-eliminated { background: rgba(#ef4444, 0.12); color: #dc2626; }
        }

        .view-link {
          font-size: 12px;
          color: $color-primary-400;
          cursor: pointer;
          &:hover { text-decoration: underline; }
        }
      }
    }

    .pagination {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      margin-top: 8px;

      .page-btn {
        width: 32px;
        height: 32px;
        border: 1px solid $color-gray-300;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: white;
        cursor: pointer;
        color: $text-dark;
        font-size: 18px;

        &:hover:not(:disabled) { border-color: $color-primary-500; color: $color-primary-500; }
        &:disabled { opacity: 0.4; cursor: not-allowed; }
      }

      .page-info { font-size: 13px; color: $text-light; }
    }
  }
}
</style>
