<template>
  <div class="job-ad-card">
    <div class="top">
      <div class="left" @click="handleClickTitle">
        <Icon
          :name="
            props.data.isPublic
              ? 'ic:round-public'
              : 'ic:outline-private-connectivity'
          "
          class="public-icon"
          :class="{
            public: props.data.isPublic,
            private: !props.data.isPublic,
          }"
        />
        <div class="title">{{ props.data.title }}</div>
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
    <div class="small">
      <div class="block">
        <Icon name="material-symbols:cases-outline-rounded" />
        <div class="text">{{ props.data.position?.name }}</div>
      </div>
      <div class="block">
        <Icon name="material-symbols:person-add-outline-rounded" />
        <div class="text">{{ "Số lượng:" }}</div>
        <div class="text bold">{{ props.data.quantity }}</div>
      </div>
      <div class="block">
        <Icon name="material-symbols:home-work-outline-rounded" />
        <div class="text">{{ "Phòng ban:" }}</div>
        <div class="text bold">{{ props.data.department?.name }}</div>
      </div>
      <div class="block">
        <Icon name="material-symbols:calendar-clock-outline-rounded" />
        <div class="text">{{ "Hạn nộp hồ sơ:" }}</div>
        <div class="text bold">
          {{ formatDateTime(props.data.dueDate, "DD/MM/YYYY") }}
        </div>
      </div>
      <div class="block">
        <Icon name="material-symbols:contact-phone-outline-rounded" />
        <div class="text">{{ "HR liên hệ:" }}</div>
        <div class="text bold">
          {{ props.data.hrContact?.fullName }}
        </div>
      </div>
      <div class="block">
        <Icon name="material-symbols:person-2-outline-rounded" />
        <div class="text">{{ "Người tạo:" }}</div>
        <div class="text bold">
          {{ props.data.createdBy }}
        </div>
      </div>
      <div class="block">
        <Icon name="material-symbols:calendar-add-on-outline-rounded" />
        <div class="text">{{ "Ngày tạo:" }}</div>
        <div class="text bold">
          {{ formatDateTime(props.data.createdAt, "DD/MM/YYYY") }}
        </div>
      </div>
      <div v-if="props.data.updatedBy" class="block">
        <Icon name="material-symbols:person-edit-outline-rounded" />
        <div class="text">{{ "Người chỉnh sửa:" }}</div>
        <div class="text bold">
          {{ props.data.updatedBy }}
        </div>
      </div>
      <div v-if="props.data.updatedAt" class="block">
        <Icon name="material-symbols:edit-calendar-outline-rounded" />
        <div class="text">{{ "Ngày chỉnh sửa:" }}</div>
        <div class="text bold">
          {{ formatDateTime(props.data.updatedAt, "DD/MM/YYYY") }}
        </div>
      </div>
    </div>
    <div class="large">
      <div
        v-for="process of processList"
        :key="process.sortOrder"
        class="process-block"
        @click="handleViewDetailWithProcess(process)"
      >
        <div class="count">{{ process.count }}</div>
        <div class="name">{{ process.name }}</div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  data: any;
  jobAdStatus: any[];
};

const props = defineProps<TProps>();

const { setLoading } = useLoadingStore();
const { updateJobAdStatus, updateJobAdPublicity } = useJobAdApi();
const route = useRoute();
const router = useRouter();
const { getMenuItem } = useSidebarStore();
const toast = useToast();

const localStatus = ref<any>(null);
const localIsPublic = ref<any>(null);

onBeforeMount(() => {
  localStatus.value = props.data.jobAdStatus;
  localIsPublic.value = props.data.isPublic;
});

const processList = computed(() => {
  return props.data.jobAdProcess.map((process: any) => ({
    id: process.id,
    sortOrder: process.sortOrder,
    count: process.numberOfApplicants,
    name: process.name,
  }));
});

const allowActions = computed(() => {
  const url = route.path;
  const menuItem = getMenuItem(url);
  const permissions = Array.from(menuItem?.permissions || []);
  return permissions;
});

const jobAdStatusActions = computed(() => {
  const descriptionMap: Record<string, any> = {
    OPEN: "Cho phép ứng viên nộp hồ sơ vào tin này.",
    PAUSE: "Tạm thời ngừng nhận hồ sơ cho tin này.",
    CLOSED: "Dừng nhận hồ sơ cho tin này.",
  };
  return props.jobAdStatus.map((status: any) => ({
    label: status.label,
    value: status.value,
    description: descriptionMap[status.value],
    onSelect: () => handleChangeStatus(status),
  }));
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

async function handleChangeStatus(status: any) {
  setLoading(true);
  const payload = {
    jobAdId: props.data.id,
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
    jobAdId: props.data.id,
    isPublic: isPublic,
  };

  const success = await updateJobAdPublicity(payload);
  setLoading(false);
  if (success) {
    localIsPublic.value = isPublic;
  }
}

function handleEditJobAd() {
  const link = router.resolve({
    path: `/org/job-ad/detail/${props.data.id}`,
    query: {
      isEdit: "true",
    },
  });

  window.open(link.href, "_blank");
}

function handleCopyLink() {
  console.log("copy link");

  // TODO: Should link to public page, update me
  const link = router.resolve({
    path: `/org/job-ad/detail/${props.data.id}`,
  });

  navigator.clipboard.writeText(window.location.origin + link.href);
  toast.add({
    title: "Đã sao chép đường dẫn",
    color: "success",
  });
}

function handleClickTitle() {
  const selection = window.getSelection()?.toString();

  if (selection && selection.length > 0) {
    return;
  }

  const link = router.resolve({
    path: `/org/job-ad/detail/${props.data.id}`,
  });

  window.open(link.href, "_blank");
}

function handleViewDetail() {
  // TODO: Should link to public page, update me
  const link = router.resolve({
    path: `/job-ad/detail/${props.data.id}`, 
    query: {
      keyCodeInternal: props.data.isPublic
        ? undefined
        : props.data.keyCodeInternal,
    },
  });

  window.open(link.href, "_blank");
}

function handleViewDetailWithProcess(process: any) {
  const link = router.resolve({
    path: `/org/job-ad/detail/${props.data.id}`,
    query: {
      processId: process.id,
    },
  });

  window.open(link.href, "_blank");
}
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

.job-ad-card {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 12px;
  border-radius: 12px;
  // border: 1px solid $color-gray-200;
  @include box-shadow;

  .iconify {
    display: block;
    font-size: 20px;
    height: 20px;
    width: 20px;
  }

  .top {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
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

    .public-icon {
      display: block;
      font-size: 20px;
      height: 20px;
      width: 20px;

      &.private {
        color: $color-info;
      }
      &.public {
        color: $color-primary-400;
      }
    }

    .title {
      font-weight: 600;
      font-size: 16px;
      color: $text-light;
    }
  }

  .left {
    cursor: pointer;
  }

  .left,
  .right {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 8px;
  }

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
</style>
