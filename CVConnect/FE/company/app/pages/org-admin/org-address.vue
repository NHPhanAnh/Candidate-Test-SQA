<template>
  <div class="process-type">
    <div class="title">Địa điểm làm việc</div>
    <div class="content">
      <AppNoData v-if="isNoData" />
      <OrgRegisterAddressPicker
        v-for="(address, index) of addressList"
        :key="index"
        :city-info="cityInfo ?? []"
        :value="address"
        :address-index="index + 1"
        :is-view-only="!canEdit"
        @input="handleAddressInput(index, $event)"
        @remove="handleAddressRemove(index)"
      />
      <div v-if="canEdit" class="add-address-button" @click="handleAddNewAddress">
        <span class="text"> Thêm mới địa chỉ </span>
      </div>
    </div>
    <div v-if="!isNoData && canEdit" class="buttons">
      <AppButton
        class="reset-button"
        :text="'Hủy bỏ'"
        :is-disabled="isResetDisabled"
        @click="handleReset"
      />
      <AppButton
        class="submit-button"
        :text="'Cập nhật'"
        :is-disabled="isSubmitDisabled"
        @click="handleSubmit"
      />
    </div>
  </div>
</template>
<script setup lang="ts">
import axios from "axios";
import { cloneDeep, isEqual } from "lodash";

definePageMeta({
  layout: "org",
});

const cityInfo = ref<Record<string, any>[] | null>(null);
const addressList = ref<any[]>([]);
const snapshot = ref<any[]>([]);
const isNoData = ref<boolean>(false);

const { getOrgAddresses, updateOrgAddresses } = useOrgAddressApi();
const { getMenuItem } = useSidebarStore();
const { setLoading } = useLoadingStore();
const route = useRoute();

onBeforeMount(async () => {
  await initList();
  const res = await axios.get(`https://provinces.open-api.vn/api/v2/?depth=2`);
  cityInfo.value = res.data;
});

const allowActions = computed(() => {
  const url = route.path;
  const menuItem = getMenuItem(url);
  const permissions = Array.from(menuItem?.permissions || []);
  return permissions;
});

const canEdit = computed(() => {
  return allowActions.value.includes('UPDATE');
})

const isResetDisabled = computed(() => {
  return isEqual(addressList.value, snapshot.value);
});

const isSubmitDisabled = computed(() => {
  if (!addressList.value.length) {
    return true;
  }

  for (const address of addressList.value) {
    if (!address.province || !address.detailAddress.trim()) {
      return true;
    }
  }

  return isEqual(addressList.value, snapshot.value);
});

const initList = async () => {
  setLoading(true);
  const res = await getOrgAddresses();
  setLoading(false);
  addressList.value = res.data.map((address: any) => {
    const mapped = {
      id: address.id,
      province: address.province,
      ward: address.ward,
      district: address.district,
      detailAddress: address.detailAddress,
      headquarter: address.isHeadquarter,
    };

    return mapped;
  });
  if (res.data.length == 0) {
    isNoData.value = true;
  }
  snapshot.value = cloneDeep(addressList.value);
};

const handleReset = () => {
  addressList.value = cloneDeep(snapshot.value);
};

const handleSubmit = async () => {
  console.log("submit");
  if (!addressList.value.length) {
    return;
  }
  setLoading(true);
  const isSuccess = await updateOrgAddresses(addressList.value);
  setLoading(false);
  if (isSuccess) {
    await initList();
  }
};

const handleAddressInput = (index: number, value: any) => {
  if (value.headquarter) {
    addressList.value = addressList.value.map((address) => ({
      ...address,
      headquarter: false,
    }));
  }
  addressList.value[index] = value;
};

const handleAddressRemove = (index: number) => {
  addressList.value.splice(index, 1);
};

const handleAddNewAddress = () => {
  addressList.value.push({
    province: "",
    ward: "",
    district: "",
    detailAddress: "",
    headquarter: false,
  });
};
</script>
<style lang="scss" scoped>
.process-type {
  @include box-shadow;
  @include custom-scrollbar;
  background-color: white;
  border-radius: 8px;
  margin-top: 8px;
  min-height: calc(100% - 48px - 8px);
  color: $text-light;
  padding: 20px;
  display: flex;
  flex-direction: column;

  .title {
    font-weight: 700;
    font-size: 16px;
    line-height: 20px;
    margin-bottom: 12px;
  }

  .content {
    @include custom-scrollbar;
    padding: 8px;
    display: flex;
    flex: 1;
    min-height: 0;
    overflow-y: auto;
    flex-direction: column;
    gap: 12px;

    :deep(.text-input) {
      .input-wrapper {
        .input {
          padding: 6px 8px;
          input {
            font-size: 14px;
          }
        }
      }
    }

    .add-address-button {
      cursor: pointer;
      padding: 8px 18px;
      border: 1px dashed rgba($color-danger, 0.3);
      border-radius: 10px;
      display: flex;
      justify-content: center;
      align-items: center;
      transition: background-color 200ms;
      &:hover {
        background-color: rgba($color-primary-50, 0.3);
      }
      .text {
        font-size: 14px;
        line-height: 20px;
        color: $color-danger;
      }
    }
  }

  .buttons {
    display: flex;
    flex-direction: row;
    justify-content: center;
    gap: 18px;
    margin-top: 24px;

    .submit-button {
      background-color: $color-primary-500;
      padding: 6px 16px;
      color: $text-dark;

      &.disabled {
        background-color: $color-gray-300;
      }
    }
    .reset-button {
      color: $color-primary-500;
      background-color: #ffffff;
      border: 1px solid $color-primary-500;
      padding: 6px 16px;

      &.disabled {
        border: 1px solid $color-gray-300;
        color: $color-gray-300;
      }
    }
  }
}
</style>
