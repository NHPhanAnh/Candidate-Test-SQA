<template>
  <div class="org-info-wrapper">
    <div class="wrapper">
      <div class="org-info">
        <OrgOrgInfoChangeLogoModal
          v-model="isChangeLogoModalOpen"
          @submit="handleUpdateLogo"
        />
        <OrgOrgInfoChangeCoverModal
          v-model="isChangeCoverModalOpen"
          @submit="handleUpdateCover"
        />
        <OrgOrgInfoUpdateInfoModal
          v-model="isChangeInfoModalOpen"
          :company-info="orgInfo"
          @submit="handleUpdateInfo"
        />
        <div class="org-image-wrapper">
          <div class="org-cover">
            <img :src="orgInfo?.coverPhotoUrl ?? '/orgcover.jpg'" alt="" />
            <div
              v-if="allowActions.includes('UPDATE')"
              class="edit-cover-button"
              @click="isChangeCoverModalOpen = true"
            >
              <Icon name="material-symbols:edit-rounded" />
            </div>
          </div>
          <div class="org-logo">
            <div class="logo-wrapper">
              <img :src="orgInfo?.logoUrl ?? '/blankuser.jpg'" alt="" />
              <div
                v-if="allowActions.includes('UPDATE')"
                class="change-image"
                @click="isChangeLogoModalOpen = true"
              >
                <Icon name="material-symbols:android-camera" />
              </div>
            </div>
            <div class="company-info-misc">
              <div class="name">
                {{ orgInfo?.name }}
              </div>
              <div v-if="displayingAddresses" class="address truncate">
                <Icon
                  name="streamline:travel-map-location-pin-navigation-map-maps-pin-gps-location"
                />
                <span>
                  {{ displayingAddresses.mainAddress }}
                  <span
                    v-if="displayingAddresses.others"
                    class="link"
                    @click="routeToAddresses"
                    >{{ `và ${displayingAddresses.others} địa chỉ khác` }}</span
                  >
                </span>
              </div>
            </div>
          </div>
        </div>
        <div class="info-block">
          <div class="line">
            <div class="col">
              <div class="row">
                <div class="label">
                  <Icon name="mdi:web" />
                  Website
                </div>
                <a
                  :href="orgInfo?.website"
                  target="_blank"
                  class="value link"
                  >{{ orgInfo?.website }}</a
                >
              </div>
              <div class="row">
                <div class="label">
                  <Icon name="streamline-plump:office-worker-remix" />
                  Số lượng nhân viên
                </div>
                <div class="value">{{ employeeCount }}</div>
              </div>
              <div class="row">
                <div class="label">
                  <Icon name="iconoir:suitcase" />
                  Lĩnh vực
                </div>
                <div class="value">
                  <div class="industry-list">
                    <div
                      v-for="indus of orgInfo?.industryList ?? []"
                      :key="indus.id"
                      class="industry-item"
                    >
                      {{ indus.name }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col">
              <div class="row">
                <div class="label">
                  <Icon name="material-symbols:add-home-rounded" />
                  Ngày tạo
                </div>
                <div class="value">
                  {{ formatDateTime(orgInfo?.createdAt, "DD/MM/YYYY") }}
                </div>
              </div>
              <div class="row">
                <div class="label">
                  <Icon name="material-symbols:person-add-rounded" />
                  Người tạo
                </div>
                <div class="value">{{ orgInfo?.createdBy }}</div>
              </div>
              <div v-if="orgInfo?.updatedAt" class="row">
                <div class="label">
                  <Icon name="material-symbols:add-home-rounded" />
                  Ngày cập nhật
                </div>
                <div class="value">
                  {{ formatDateTime(orgInfo?.updatedAt, "DD/MM/YYYY") }}
                </div>
              </div>
              <div v-if="orgInfo?.updatedBy" class="row">
                <div class="label">
                  <Icon name="material-symbols:person-edit-rounded" />
                  Người cập nhật
                </div>
                <div class="value">{{ orgInfo?.updatedBy }}</div>
              </div>
            </div>
          </div>
          <div class="description-block">
            <div class="label">
              <Icon name="fluent:text-description-ltr-24-filled" />
              Mô tả chung
            </div>
            <div class="content" v-html="orgInfo?.description"></div>
          </div>
        </div>
        <AppButton
          v-if="allowActions.includes('UPDATE')"
          class="edit-button"
          :text="'Chỉnh sửa'"
          @click="isChangeInfoModalOpen = true"
        />
      </div>
    </div>
    <div class="notification-block-wrapper">
      <OrgOrgInfoNotificationsList />
    </div>
  </div>
</template>
<script setup lang="ts">
definePageMeta({
  layout: "org",
});

const { setLoading } = useLoadingStore();
const { getOrgInfo } = useOrgApi();
const { getOrgAddresses } = useOrgAddressApi();

const isChangeLogoModalOpen = ref<boolean>(false);
const isChangeCoverModalOpen = ref<boolean>(false);
const isChangeInfoModalOpen = ref<boolean>(false);
const orgInfo = ref<any>(null);
const orgAddresses = ref<any>(null);
const route = useRoute();
const { getMenuItem } = useSidebarStore();
const router = useRouter();

onBeforeMount(async () => {
  setLoading(true);
  const [orgInfoRes, orgAddressRes] = await Promise.all([
    getOrgInfo(),
    getOrgAddresses(),
  ]);
  orgInfo.value = orgInfoRes.data;
  orgAddresses.value = orgAddressRes.data;
  setLoading(false);
});

const employeeCount = computed(() => {
  if (!orgInfo.value) {
    return "";
  }

  const from = orgInfo.value.staffCountFrom;
  const to = orgInfo.value.staffCountTo;
  if (from && to) {
    return `Từ ${from} đến ${to}`;
  }
  if (!from && to) {
    return `Từ 1 đến ${to}`;
  }
  if (from && !to) {
    return `Trên ${from}`;
  }

  return "";
});

const allowActions = computed(() => {
  const url = route.path;
  const menuItem = getMenuItem(url);
  const permissions = Array.from(menuItem?.permissions || []);
  return permissions;
});

const displayingAddresses: any = computed(() => {
  if (!orgAddresses.value || !orgAddresses.value.length) {
    return null;
  }
  let showAddress = orgAddresses.value.find(
    (address: any) => address.isHeadquarter,
  );
  if (!showAddress) {
    showAddress = orgAddresses.value[0];
  }
  const otherAddress = orgAddresses.value.length - 1;
  if (otherAddress) {
    return {
      mainAddress: `${showAddress.detailAddress}, ${showAddress.province}`,
      others: otherAddress,
    };
  }
  return {
    mainAddress: `${showAddress.detailAddress}, ${showAddress.province}`,
  };
});

async function fetchInfo() {
  setLoading(true);
  const res = await getOrgInfo();
  orgInfo.value = res.data;
  setLoading(false);
}

function routeToAddresses() {
  const resolved = router.resolve({ path: "org-admin/org-address" });
  window.open(resolved.href, "_blank");
}

function handleUpdateLogo() {
  isChangeLogoModalOpen.value = false;
  fetchInfo();
}

function handleUpdateCover() {
  isChangeCoverModalOpen.value = false;
  fetchInfo();
}

function handleUpdateInfo() {
  isChangeInfoModalOpen.value = false;
  fetchInfo();
}
</script>
<style lang="scss" scoped>
.org-info-wrapper {
  display: flex;
  flex-direction: row;
  gap: 12px;
  flex: 1;
  min-height: 0;
}
.wrapper {
  min-height: 0;
  flex: 1;
  border-radius: 8px;
  background-color: #ffffff;
  margin-top: 8px;
  @include box-shadow;
  padding: 16px;
  overflow-y: auto;
  overflow-x: hidden;
  max-width: 60%;
  @include custom-scrollbar;
}

.notification-block-wrapper {
  min-height: 0;
  flex: 1;
  min-height: 0;
  border-radius: 8px;
  background-color: #ffffff;
  margin-top: 8px;
  @include box-shadow;
  max-width: 40%;
  max-height: 100%;
}

.org-info {
  display: flex;
  flex-direction: column;

  .link {
    text-decoration: underline;
    cursor: pointer;
    color: $color-primary-500;
  }

  .org-image-wrapper {
    position: relative;
    height: fit-content;

    .org-cover {
      max-height: 200px;
      height: 200px;
      border-radius: 6px;

      @media (max-width: $breakpoint-lg) {
        max-height: 160px;
        height: 160px;
      }
      @media (max-width: $breakpoint-md) {
        max-height: 120px;
        height: 120px;
      }
      width: 100%;
      overflow: hidden;
      position: relative;

      &:hover {
        .edit-cover-button {
          opacity: 100%;
        }
      }

      img {
        object-fit: cover;
        width: 100%;
        height: 100%;
      }

      .edit-cover-button {
        position: absolute;
        top: 12px;
        right: 12px;
        opacity: 0%;
        transition: opacity 0.2s;
        background-color: #ffffff;
        height: 32px;
        width: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 100%;
        cursor: pointer;
      }
    }

    .org-logo {
      position: absolute;
      bottom: -64px;
      left: 16px;
      display: flex;
      flex-direction: row;

      @media (max-width: 1330px) {
        flex-direction: column;
        left: 16px;
        bottom: -128px;
        .company-info-misc {
          margin-top: 0px !important;
        }
      }
      max-width: 100%;
      gap: 12px;
      .company-info-misc {
        align-self: flex-start;
        margin-top: 72px;

        .name {
          font-size: 20px;
          font-weight: 600;
        }
        .address {
          font-size: 14px;
          font-weight: 400;
          display: flex;
          align-items: center;
          gap: 8px;
          margin-top: 8px;
          .iconify {
            display: block;
          }
        }
      }
      .logo-wrapper {
        width: 128px;
        height: 128px;
        border-radius: 4px;
        overflow: hidden;
        position: relative;
        &:hover {
          .change-image {
            opacity: 100%;
          }
        }
        .change-image {
          position: absolute;
          width: 100%;
          height: 100%;
          background-color: rgba($color-gray-800, 0.2);
          top: 0px;
          cursor: pointer;
          display: flex;
          transition: opacity 0.2s;
          opacity: 0%;
          align-items: center;
          justify-content: center;
          .iconify {
            display: block;
            font-size: 48px;
          }
        }

        img {
          object-fit: cover;
          width: 100%;
          height: 100%;
        }
      }
    }
  }
  .line {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: flex-start;
    column-gap: 16px;
    row-gap: 8px;
    flex: 1;

    @media (max-width: 1330px) {
      flex-direction: column;
    }
  }
  .row {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: flex-start;
    column-gap: 16px;
    row-gap: 8px;
    flex: 1;
  }
  .col {
    display: flex;
    flex-direction: column;
    row-gap: 8px;
    flex: 1;
    height: fit-content;
    width: 100%;
  }
  .info-block {
    margin: 124px auto 24px auto;
    max-width: min(840px, 90%);
    min-width: min(840px, 90%);
    display: flex;
    flex-direction: column;

    @media (max-width: 1330px) {
      margin-top: 156px;
    }

    .industry-list {
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;
      gap: 4px;
      justify-content: flex-end;

      .industry-item {
        font-size: 13px;
        padding: 1px 2px;
        border: 1px solid $color-gray-300;
        color: $color-gray-500;
        border-radius: 6px;
        text-align: center;
      }
    }

    .label {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 4px;
      font-size: 14px;
      line-height: 20px;
      min-width: 156px;
      .iconify {
        display: block;
        font-size: 18px;
      }
    }

    .value {
      font-size: 14px;
      line-height: 20px;
    }

    .description-block {
      margin-top: 12px;
      :deep(.content) {
        font-size: 14px;
        word-break: break-all;
      }
    }
  }

  .edit-button {
    max-width: min(840px, 90%);
    min-width: min(840px, 90%);
    margin: auto;

    background-color: $color-primary-500;
    color: $text-dark;
    padding: 8px;
  }
}
</style>
