<template>
  <div class="wrapper">
    <OrgAdJobEditModal
      v-model="isEditModalOpen"
      :data="detail"
      @submit="handleUpdateSubmit"
    />
    <div v-if="detail" class="content">
      <div class="top">
        <div class="left">
          <div class="back-btn" @click="router.push({ path: '/org/job-ad' })">
            <Icon name="material-symbols:chevron-left-rounded" />
          </div>
          <div class="title">{{ detail.title }}</div>
        </div>
        <div class="right">
          <UDropdownMenu
            v-if="allowActions.includes('UPDATE')"
            :items="jobAdStatusActions"
            :ui="{
              item: 'cursor-pointer hover:bg-gray-100',
              content: 'w-[240px]',
            }"
          >
            <template #item="{ item }">
              <div class="dropdown-select-item">
                <div>
                  <div class="dropdown-select-title">{{ item.label }}</div>
                  <div class="dropdown-select-description">
                    {{ item.description }}
                  </div>
                </div>
              </div>
            </template>
            <div
              class="chip-action"
              :class="{
                active: localStatus.name == 'OPEN',
                paused: localStatus.name == 'PAUSE',
                closed: localStatus.name == 'CLOSED',
              }"
            >
              {{ localStatus.description }}
              <Icon name="mdi:chevron-down" />
            </div>
          </UDropdownMenu>
          <div
            v-else
            class="chip-action"
            :class="{
              active: localStatus.name == 'OPEN',
              paused: localStatus.name == 'PAUSE',
              closed: localStatus.name == 'CLOSED',
            }"
          >
            {{ localStatus.description }}
            <Icon name="mdi:chevron-down" />
          </div>
          <UDropdownMenu
            v-if="allowActions.includes('UPDATE')"
            :items="jobAdPublicityActions"
            :ui="{
              item: 'cursor-pointer hover:bg-gray-100',
              content: 'w-[240px]',
            }"
          >
            <template #item="{ item }">
              <div class="dropdown-select-item">
                <div>
                  <div class="dropdown-select-title">{{ item.label }}</div>
                  <div class="dropdown-select-description">
                    {{ item.description }}
                  </div>
                </div>
              </div>
            </template>
            <div
              class="chip-action"
              :class="{
                public: localIsPublic,
                private: !localIsPublic,
              }"
            >
              {{ localIsPublic ? "Công khai" : "Nội bộ" }}
              <Icon name="mdi:chevron-down" />
            </div>
          </UDropdownMenu>
          <div
            v-else
            class="chip-action"
            :class="{
              public: localIsPublic,
              private: !localIsPublic,
            }"
          >
            {{ localIsPublic ? "Công khai" : "Nội bộ" }}
            <Icon name="mdi:chevron-down" />
          </div>
          <UDropdownMenu
            :items="dotsActions"
            :ui="{
              item: 'cursor-pointer hover:bg-gray-100',
              content: 'w-[180px]',
            }"
          >
            <template #item-trailing="{ item }">
              <Icon :name="item.iconName" class="text-[16px] mr-[2px]" />
            </template>
            <div class="dots-btn">
              <Icon name="mdi:dots-vertical" />
            </div>
          </UDropdownMenu>
        </div>
      </div>
      <div class="detail-content">
        <div class="small">
          <div class="block">
            <Icon name="material-symbols:cases-outline-rounded" />
            <div class="text">{{ detail.position?.name }}</div>
          </div>
          <div v-if="detail.isAllLevel || detail.levels?.length" class="block">
            <Icon name="material-symbols:account-tree-outline-rounded" />
            <div class="text">{{ "Cấp bậc:" }}</div>
            <div class="text bold">
              {{
                detail.isAllLevel
                  ? "Mọi cấp bậc"
                  : detail.levels.map((level: any) => level.name).join(", ")
              }}
            </div>
          </div>

          <div class="block">
            <Icon name="material-symbols:person-add-outline-rounded" />
            <div class="text">{{ "Số lượng:" }}</div>
            <div class="text bold">{{ detail.quantity }}</div>
          </div>
          <div class="block">
            <Icon
              name="material-symbols:nest-clock-farsight-analog-outline-rounded"
            />
            <div class="text">{{ "Loại hình:" }}</div>
            <div class="text bold">{{ detail.jobType?.description }}</div>
          </div>
          <div v-if="detail.isRemote" class="block">
            <Icon
              name="material-symbols:nest-remote-comfort-sensor-outline-rounded"
            />
            <div class="text">{{ "Cho phép làm từ xa" }}</div>
          </div>
          <div class="block">
            <Icon
              name="material-symbols:nest-clock-farsight-analog-outline-rounded"
            />
            <div class="text">{{ "Mức lương:" }}</div>
            <div class="text bold">
              {{
                detail.salaryType?.name == "NEGOTIABLE"
                  ? `Thỏa thuận (${detail.currencyType.name})`
                  : `Từ ${getLocaleNumber(detail.salaryFrom)} đến ${getLocaleNumber(detail.salaryTo)} (${detail.currencyType.name})`
              }}
            </div>
          </div>
          <div class="block">
            <Icon name="material-symbols:home-work-outline-rounded" />
            <div class="text">{{ "Phòng ban:" }}</div>
            <div class="text bold">{{ detail.department?.name }}</div>
          </div>
          <div v-if="detail.workLocations.length" class="block">
            <Icon name="material-symbols:location-on-outline-rounded" />
            <div class="text">{{ "Địa điểm làm việc:" }}</div>
            <div class="text bold">
              {{
                detail.workLocations
                  ?.map((location: any) => location.displayAddress)
                  .join(", ")
              }}
            </div>
          </div>
          <div class="block">
            <Icon name="material-symbols:calendar-clock-outline-rounded" />
            <div class="text">{{ "Hạn nộp hồ sơ:" }}</div>
            <div class="text bold">
              {{ formatDateTime(detail.dueDate, "DD/MM/YYYY") }}
            </div>
          </div>
          <div class="block">
            <Icon name="material-symbols:contact-phone-outline-rounded" />
            <div class="text">{{ "HR liên hệ:" }}</div>
            <div class="text bold">
              {{ detail.hrContact?.fullName }}
            </div>
          </div>
          <div class="block">
            <Icon name="material-symbols:person-2-outline-rounded" />
            <div class="text">{{ "Người tạo:" }}</div>
            <div class="text bold">
              {{ detail.createdBy }}
            </div>
          </div>
          <div class="block">
            <Icon name="material-symbols:calendar-add-on-outline-rounded" />
            <div class="text">{{ "Ngày tạo:" }}</div>
            <div class="text bold">
              {{ formatDateTime(detail.createdAt, "DD/MM/YYYY") }}
            </div>
          </div>
          <div v-if="detail.updatedBy" class="block">
            <Icon name="material-symbols:person-edit-outline-rounded" />
            <div class="text">{{ "Người chỉnh sửa:" }}</div>
            <div class="text bold">
              {{ detail.updatedBy }}
            </div>
          </div>
          <div v-if="detail.updatedAt" class="block">
            <Icon name="material-symbols:edit-calendar-outline-rounded" />
            <div class="text">{{ "Ngày chỉnh sửa:" }}</div>
            <div class="text bold">
              {{ formatDateTime(detail.updatedAt, "DD/MM/YYYY") }}
            </div>
          </div>
        </div>
        <div class="large">
          <div
            v-for="process of processList"
            :key="process.sortOrder"
            class="process-block"
            :class="{ selected: currentProcessId == process.id }"
            @click="handleSetProcess(process)"
          >
            <div class="count">{{ process.count }}</div>
            <div class="name">{{ process.name }}</div>
          </div>
        </div>
        <OrgAdJobCandidateTable
          :job-ad-process-id="currentProcessId"
          :is-onboard="isOnboard"
        />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { DETAIL_BREADCRUMBS } from "~/const/views/org/job-ad";

definePageMeta({
  layout: "org",
});

const route = useRoute();
const router = useRouter();
const { setLoading } = useLoadingStore();
const { updateJobAdStatus, updateJobAdPublicity, getJobAdDetailOrg } =
  useJobAdApi();
const breadcrumbStore = useBreadcrumbStore();
const { overrideItems, clearOverrideItems } = breadcrumbStore;
const { getMenuItem } = useSidebarStore();
const { getJobAdStatus } = useEnumApi();
const toast = useToast();

const isEditModalOpen = ref<boolean>(false);
const detail = ref<any>(null);
const localStatus = ref<any>(null);
const localIsPublic = ref<any>(null);
const jobAdStatusList = ref<any[]>([]);
const currentProcessId = ref<any>(null);

onBeforeMount(async () => {
  const id = Number(route.params.id);
  if (id == undefined || id == null || isNaN(id)) {
    router.push({ path: "/404" });
  }
  setLoading(true);
  await fetchDetail();
  await fetchJobAdStatus();
  setLoading(false);
  overrideItems([
    ...DETAIL_BREADCRUMBS,
    {
      name: "Chi tiết",
      icon: "",
      url: `/org/job-ad/detail/${id}`,
    },
  ]);
  const isEdit = route.query.isEdit;
  if (isEdit) {
    isEditModalOpen.value = true;
  }
});

const isOnboard = computed(() => {
  const process = detail.value.jobAdProcess.find(
    (process: any) => process.id == currentProcessId.value,
  );
  console.log({ process });
  if (process && process.name == "Onboard") {
    return true;
  }
  return false;
});

const processList = computed(() => {
  return detail.value.jobAdProcess.map((process: any) => ({
    id: process.id,
    sortOrder: process.sortOrder,
    count: process.numberOfApplicants,
    name: process.name,
  }));
});

const jobAdStatusActions = computed(() => {
  const descriptionMap: Record<string, any> = {
    OPEN: "Cho phép ứng viên nộp hồ sơ vào tin này.",
    PAUSE: "Tạm thời ngừng nhận hồ sơ cho tin này.",
    CLOSED: "Dừng nhận hồ sơ cho tin này.",
  };
  return jobAdStatusList.value.map((status: any) => ({
    label: status.label,
    value: status.value,
    description: descriptionMap[status.value],
    onSelect: () => handleChangeStatus(status),
  }));
});

const jobAdPublicityActions = computed(() => {
  return [
    {
      label: "Công khai",
      value: true,
      description: "Hiển thị tin này trên kênh tuyển dụng.",
      onSelect: () => handleChangePublicity(true),
    },
    {
      label: "Nội bộ",
      value: false,
      description: "Chỉ các thành viên có đường dẫn mới xem được tin này.",
      onSelect: () => handleChangePublicity(false),
    },
  ];
});

function handleUpdateSubmit() {
  isEditModalOpen.value = false;
  fetchDetail();
}

async function fetchDetail() {
  const id = Number(route.params.id);
  if (id == undefined || id == null || isNaN(id)) {
    router.push({ path: "/404" });
  }
  const res = await getJobAdDetailOrg(id);
  detail.value = res.data;
  localStatus.value = detail.value.jobAdStatus;
  localIsPublic.value = detail.value.isPublic;
  document.title = `${detail.value.title} - CVConnect`;
  const processIdQuery = Number(route.query.processId);
  if (!isNaN(processIdQuery)) {
    currentProcessId.value = processIdQuery;
  } else {
    currentProcessId.value = detail.value.jobAdProcess[0]?.id;
  }
}

const allowActions = computed(() => {
  const menuItem = getMenuItem(`/org/job-ad`);
  const permissions = Array.from(menuItem?.permissions || []);
  return permissions;
});

const dotsActions = computed(() => {
  const actions = [];
  if (allowActions.value.includes("UPDATE")) {
    actions.push({
      label: "Sửa tin",
      onSelect: () => handleEditJobAd(),
      iconName: "material-symbols:edit-document-outline-rounded",
    });
  }
  actions.push({
    label: "Sao chép đường dẫn",
    onSelect: () => handleCopyLink(),
    iconName: "material-symbols:content-copy-outline-rounded",
  });
  if (allowActions.value.includes("VIEW")) {
    actions.push({
      label: "Xem tin tuyển dụng",
      onSelect: () => handleViewDetail(),
      iconName: "material-symbols:frame-inspect-rounded",
    });
  }
  return actions;
});

function handleViewDetail() {
  console.log({ detail: detail.value });

  // TODO: Should link to public page, update me
  const link = router.resolve({
    path: `/job-ad/detail/${detail.value.id}`,
    query: {
      keyCodeInternal: detail.value.isPublic
        ? undefined
        : detail.value.keyCodeInternal,
    },
  });

  console.log({ link });

  window.open(link.href, "_blank");
}

function handleEditJobAd() {
  isEditModalOpen.value = true;
  console.log("open modal");
}

function handleCopyLink() {
  console.log("copy link");

  const link = router.resolve({
    path: `/job-ad/detail/${detail.value.id}`,
  });

  navigator.clipboard.writeText(window.location.origin + link.href);
  toast.add({
    title: "Đã sao chép đường dẫn",
    color: "success",
  });
}

async function handleChangeStatus(status: any) {
  setLoading(true);
  const payload = {
    jobAdId: detail.value.id,
    status: status.value,
  };

  const success = await updateJobAdStatus(payload);
  setLoading(false);
  if (success) {
    localStatus.value = {
      name: status.value,
      description: status.label,
    };
  }
}

async function handleChangePublicity(isPublic: boolean) {
  setLoading(true);
  const payload = {
    jobAdId: detail.value.id,
    isPublic: isPublic,
  };

  const success = await updateJobAdPublicity(payload);
  setLoading(false);
  if (success) {
    localIsPublic.value = isPublic;
  }
}

async function fetchJobAdStatus() {
  const res = await getJobAdStatus();
  jobAdStatusList.value = res.data.map((status: any) => ({
    label: status.description,
    value: status.name,
  }));

  return res.data;
}

function handleSetProcess(process: any) {
  currentProcessId.value = process.id;
}

onBeforeUnmount(() => {
  clearOverrideItems();
});

watch(currentProcessId, (newId) => {
  router.replace({
    query: {
      ...route.query,
      processId: newId,
    },
  });
});

watch(isEditModalOpen, (value) => {
  const query = { ...route.query };

  if (value) {
    query.isEdit = "true";
  } else {
    delete query.isEdit;
  }

  router.replace({ query });
});
</script>
<style lang="scss" scoped>
.dropdown-select-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  text-align: left;
  .dropdown-select-title {
    font-weight: 600;
    font-size: 14px;
  }
  .dropdown-select-description {
    font-weight: 400;
    font-size: 13px;
    color: $color-gray-400;
  }
}

.wrapper {
  overflow: hidden;
  min-height: 0;
  flex: 1;
  border-radius: 8px;
  margin-top: 8px;
  @include box-shadow;
  background-color: white;
  padding: 20px;
}

.content {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
  max-height: 100%;
  .top {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    gap: 16px;
    row-gap: 8px;
    flex-wrap: wrap;

    .dots-btn {
      background-color: $color-gray-100;
      border-radius: 999px;
      cursor: pointer;
      height: 28px;
      width: 28px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: $color-primary-500;
      .iconify {
        display: block;
        font-size: 20px;
      }
    }

    .back-btn {
      background-color: $color-gray-100;
      height: 32px;
      width: 32px;
      border-radius: 999px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;

      .iconify {
        font-size: 20px;
        display: block;
        width: 20px;
      }
    }

    .left {
      display: flex;
      flex-direction: row;
      gap: 8px;
      align-items: center;

      .title {
        font-weight: 600;
        font-size: 16px;
        line-height: 20px;
      }
    }

    .right {
      display: flex;
      flex-direction: row;
      gap: 8px;
      align-items: center;
    }
  }

  .chip-action {
    padding: 2px 6px;
    font-size: 12px;
    font-weight: 600;
    border-radius: 6px;
    cursor: pointer;
    display: flex;
    flex-direction: row;
    gap: 2px;
    align-items: center;

    .iconify {
      display: block;
      font-size: 14px;
      height: 14px;
      width: 14px;
    }

    &.public {
      color: $color-primary-400;
      border: 1px solid $color-primary-400;
      background-color: rbga($color-primary-400, 0.1);
    }

    &.private {
      color: $color-info;
      border: 1px solid $color-info;
      background-color: rbga($color-info, 0.1);
    }

    &.active {
      color: $color-success;
      border: 1px solid $color-success;
      background-color: rbga($color-success, 0.1);
    }
    &.paused {
      color: $color-warning;
      border: 1px solid $color-warning;
      background-color: rbga($color-warning, 0.1);
    }
    &.closed {
      color: $color-danger;
      border: 1px solid $color-danger;
      background-color: rbga($color-danger, 0.1);
    }
  }

  .detail-content {
    display: flex;
    flex-direction: column;
    gap: 8px;
    flex: 1;
    min-height: 0;
    overflow-y: auto;
    .small {
      display: flex;
      flex-direction: row;
      gap: 8px;
      flex-wrap: wrap;
      align-items: center;

      .block {
        display: flex;
        flex-direction: row;
        gap: 4px;
        align-items: center;
        padding-right: 8px;

        .iconify {
          color: $color-primary-400;
          font-size: 16px;
          display: block;
          width: 16px;
          min-width: 16px;
          height: 16px;
        }

        &:not(:last-child) {
          border-right: 2px solid $color-gray-300;
        }

        .text {
          font-size: 14px;
          color: $text-light;
          font-weight: 400;

          &.bold {
            font-weight: 600;
          }
        }
      }
    }
    .large {
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;
      margin-top: 12px;
      margin-bottom: 12px;
      row-gap: 16px;

      .process-block {
        display: flex;
        flex-direction: column;
        // max-width: 160px;
        min-width: 160px;
        flex: 1;
        gap: 8px;
        align-items: center;
        padding-left: 16px;
        padding-right: 16px;
        cursor: pointer;

        &.selected {
          .count,
          .name {
            color: $color-primary-400;
            font-weight: 600;
          }
        }

        transition: background-color 0.2s;
        &:hover {
          background-color: $color-gray-100;
        }

        &:not(:last-child) {
          border-right: 2px solid $color-gray-300;
        }
      }

      .count {
        font-size: 20px;
        font-weight: 600;
        color: $text-light;
      }

      .name {
        font-size: 13px;
        text-align: center;
        font-weight: 400;
        color: $text-light;
      }
    }
  }
}
</style>
