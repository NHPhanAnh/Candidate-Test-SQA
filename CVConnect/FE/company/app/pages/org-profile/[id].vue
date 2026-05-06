<template>
  <div class="wrapper">
    <div class="org-info">
      <div class="org-image-wrapper">
        <div class="org-cover">
          <img :src="orgInfo?.coverPhotoUrl ?? '/orgcover.jpg'" alt="" />
        </div>
      </div>
      <div class="org-logo">
        <div class="logo-wrapper">
          <img :src="orgInfo?.logoUrl ?? '/blankuser.jpg'" alt="" />
        </div>
        <div class="company-info-misc">
          <div class="name">
            {{ orgInfo?.name }}
          </div>
          <div class="info-row">
            <div class="info-row-block">
              <Icon name="mdi:web" />
              <a :href="orgInfo?.website" target="_blank" class="value link">{{
                orgInfo?.website
              }}</a>
            </div>
            <div class="info-row-block">
              <Icon name="streamline-plump:office-worker-remix" />
              <div class="value">{{ employeeCount }}</div>
            </div>
          </div>
        </div>
      </div>

      <div class="info-content">
        <div class="info-block left">
          <div class="title">Thông tin chung</div>
          <div class="block-content">
            <div class="line">
              <div class="col">
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
            </div>
            <div class="description-block">
              <div class="label">
                <Icon name="fluent:text-description-ltr-24-filled" />
                Mô tả chung
              </div>
              <div class="content" v-html="orgInfo?.description"></div>
            </div>
          </div>
        </div>
        <div class="info-block right">
          <div class="title">Địa chỉ</div>
          <div class="block-content">
            <div
              v-for="(loc, index) of location"
              :key="index"
              class="address truncate"
            >
              <Icon
                :name="
                  loc.isHeadquarter
                    ? 'material-symbols-light:home-work-rounded'
                    : 'streamline:travel-map-location-pin-navigation-map-maps-pin-gps-location'
                "
              />
              <span>
                {{ loc.displayAddress }}
              </span>
            </div>
          </div>
        </div>
      </div>
      <OrgProfileJobs />
    </div>
    <AppFooter />
  </div>
</template>
<script setup lang="ts">
definePageMeta({
  layout: "public",
});

const { setLoading } = useLoadingStore();
const { getOrgInfoPublic } = useOrgApi();
// const { getOrgAddresses } = useOrgAddressApi();

const orgInfo = ref<any>(null);
const route = useRoute();
const router = useRouter();

onBeforeMount(async () => {
  fetchInfo();
});

const location = computed(() => {
  return orgInfo.value?.addresses;
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

async function fetchInfo() {
  setLoading(true);
  const orgId = route.params.id;
  if (!orgId) {
    router.push({ path: "/404" });
    return;
  }
  const infoRes = await getOrgInfoPublic(orgId);
  orgInfo.value = infoRes.data;
  setLoading(false);
}
</script>
<style lang="scss" scoped>
.wrapper {
  overflow: auto;
  background-color: white;
}

.org-info {
  padding: 24px 0px 128px 0px;
  max-width: 85%;
  margin: 0px auto;
  @media (max-width: 1186px) {
    max-width: 95%;
  }
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
  }

  .org-logo {
    display: flex;
    flex-direction: row;
    margin-top: -64px;
    margin-left: 32px;

    max-width: 100%;
    gap: 12px;
    .company-info-misc {
      display: flex;
      flex-direction: column;
      gap: 4px;
      margin-top: 72px;

      .info-row {
        display: flex;
        flex-direction: row;
        gap: 24px;
        align-items: center;

        .info-row-block {
          font-size: 14px;
          display: flex;
          flex-direction: row;
          gap: 4px;
          align-items: center;

          .iconify {
            display: block;
            font-size: 20px;
            height: 20px;
            width: 20px;
            min-width: 20px;
          }
        }
      }

      .name {
        font-size: 20px;
        font-weight: 600;
      }
    }
    .logo-wrapper {
      width: 128px;
      height: 128px;
      min-width: 128px;
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
        min-width: 100%;
      }
    }
  }

  .address {
    font-size: 14px;
    font-weight: 400;
    display: flex;
    align-items: center;
    gap: 8px;
    .iconify {
      display: block;
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
  .addresses {
    margin: 124px auto 24px auto;
    display: flex;
    flex-direction: row;
    justify-content: space-between;

    .label {
      display: flex;
      flex-direction: row;
      gap: 4px;
      font-size: 14px;
      color: $text-light;
      .iconify {
        display: block;
        font-size: 18px;
        color: $text-light;
      }
    }

    @media (max-width: 1330px) {
      margin-top: 156px;
    }
  }
  .info-content {
    display: flex;
    flex-direction: row;
    gap: 12px;
    margin: 24px 0px;

    @media (max-width: 1186px) {
      flex-direction: column;

      .left,
      .right {
        max-width: 80% !important;
        min-width: 80% !important;
        margin: 0px auto;
      }
    }
  }

  .info-block {
    border-radius: 12px;
    overflow: hidden;
    max-height: fit-content;

    &.left {
      max-width: calc((100% - 12px) * 0.6);
      min-width: calc((100% - 12px) * 0.6);
    }
    &.right {
      max-width: calc((100% - 12px) * 0.4);
      min-width: calc((100% - 12px) * 0.4);
    }

    .title {
      background-color: $color-primary-500;
      color: $text-dark;
      padding: 8px 12px;
    }
    @include box-shadow;
    .block-content {
      background-color: white;
      padding: 16px;
      display: flex;
      flex-direction: column;
      gap: 6px;

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
        :deep(.content) {
          font-size: 14px;
          word-break: break-all;
        }
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
