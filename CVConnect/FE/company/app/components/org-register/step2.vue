<template>
  <div class="step2">
    <div class="form-body">
      <div class="logo-wrapper">
        <div class="label">Logo <span class="required">Bắt buộc</span></div>
        <UFileUpload
          accept="image/*"
          highlight
          :model-value="props.data.logo"
          class="w-48 min-h-48 aspect-auto file-input"
          @update:model-value="handlePhotoInput('logo', $event)"
        />
      </div>
      <div class="cover-wrapper">
        <div class="label">Ảnh bìa</div>
        <UFileUpload
          accept="image/*"
          highlight
          :model-value="props.data.coverPhoto"
          class="w-full min-h-48 file-input"
          @update:model-value="handlePhotoInput('coverPhoto', $event)"
        />
      </div>
      <div class="address-wrapper">
        <div class="label">Địa chỉ doanh nghiệp</div>
        <!-- <div class="description">Hãy nhập đầy đủ thành phố/tỉnh thành và địa chỉ chi tiết</div> -->
        <div class="address-picker-list">
          <OrgRegisterAddressPicker
            v-for="(address, index) of props.data.addresses"
            :key="index"
            :city-info="cityInfo ?? []"
            :value="address"
            :address-index="index + 1"
            @input="handleAddressInput(index, $event)"
            @remove="handleAddressRemove(index)"
          />
          <div class="add-address-button" @click="handleAddNewAddress">
            <span class="text"> Thêm mới địa chỉ </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import axios from "axios";
import { cloneDeep } from "lodash";

type TProps = {
  data: Record<string, any>;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "input", event: Record<string, any>): void;
}>();

const cityInfo = ref<Record<string, any>[] | null>(null);
const formError = ref<Record<string, any>>({
  address: "",
});

onBeforeMount(async () => {
  const res = await axios.get(`https://provinces.open-api.vn/api/v2/?depth=2`);
  cityInfo.value = res.data;
});

const handleAddNewAddress = () => {
  emits("input", {
    key: "addresses",
    value: [
      ...props.data.addresses,
      {
        province: "",
        ward: "",
        detailAddress: "",
        headquarter: false,
      },
    ],
  });
};
const handleAddressInput = (index: number, value: any) => {
  let newValue = cloneDeep(props.data.addresses);
  if (value.headquarter) {
    newValue = newValue.map((value: any) => {
      const mapped = {
        ...value,
        headquarter: false,
      };
      return mapped;
    });
  }
  newValue[index] = value;
  emits("input", {
    key: "addresses",
    value: newValue,
  });
};
const handlePhotoInput = (key: string, value: unknown) => {
  emits("input", {
    key,
    value: value ?? null,
  });
};
const handleAddressRemove = (index: number) => {
  const newValue = cloneDeep(props.data.addresses);
  newValue.splice(index, 1);
  emits("input", {
    key: "addresses",
    value: newValue,
  });
};
</script>

<style lang="scss" scoped>
.step2 {
  display: flex;
  flex-direction: column;
  width: 100%;

  .form-body {
    display: flex;
    flex-direction: column;
    gap: 24px;

    .cover-wrapper,
    .logo-wrapper {
      :deep(div[role="button"]),
      :deep(.iconify) {
        cursor: pointer;
      }

      .required {
        font-size: 12px;
        line-height: 21px;
        font-style: italic;
        color: $color-danger;
        margin-left: 4px;
      }
    }

    .address-wrapper {
      .remote-toggler {
        cursor: pointer;
        display: flex;
        flex-direction: row;
        gap: 8px;
        align-items: center;
        font-size: 13px;
        margin-bottom: 4px;
      }
    }

    .label,
    span {
      font-size: 14px;
      line-height: 21px;
      color: $text-light;
    }

    .description {
      margin-bottom: 4px;
      font-size: 13px;
      line-height: 21px;
      color: $color-gray-500;
      font-style: italic;
    }

    .label {
      margin-bottom: 4px;
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
}
</style>
