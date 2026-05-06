<template>
  <div class="address-picker">
    <div class="picker-wrapper">
      <div class="line">
        <!-- <div class="index">{{ `Địa chỉ ${props.addressIndex}` }}</div> -->
        <div class="toggler-wrapper">
          <UCheckbox
            :model-value="props.value.headquarter"
            :disabled="props.isViewOnly"
            @update:model-value="handleInput('headquarter', $event)"
          />
          <span @click="handleLabelClick">Trụ sở chính</span>
        </div>
      </div>
      <div class="line">
        <div class="province-wrapper">
          <div class="label">
            Tỉnh/Thành phố <span class="required">Bắt buộc</span>
          </div>
          <div class="select-input">
            <USelectMenu
              :model-value="props.value.province"
              :items="provinces"
              class="selector"
              :disabled="props.isViewOnly"
              :variant="'none'"
              autocomplete="autocomplete"
              placeholder="Chọn giá trị"
              :search-input="{
                placeholder: 'Tìm kiếm',
              }"
              :ui="{
                trailingIcon:
                  'group-data-[state=open]:rotate-180 transition-transform duration-200',
              }"
              @update:model-value="handleInput('province', $event)"
            />
          </div>
        </div>
        <div class="ward-wrapper">
          <div class="label">Xã/Phường</div>
          <div class="select-input">
            <USelectMenu
              :model-value="props.value.ward"
              :items="wards"
              class="selector"
              :variant="'none'"
              :disabled="props.isViewOnly"
              autocomplete="autocomplete"
              placeholder="Chọn giá trị"
              :search-input="{
                placeholder: 'Tìm kiếm',
              }"
              :ui="{
                trailingIcon:
                  'group-data-[state=open]:rotate-180 transition-transform duration-200',
              }"
              @update:model-value="handleInput('ward', $event)"
            />
          </div>
        </div>
      </div>
      <AppInputText
        :label="'Địa chỉ chi tiết'"
        :required="true"
        :value="props.value.detailAddress as string"
        :is-disabled="props.isViewOnly"
        :error="''"
        :slim-error="true"
        @input="handleInput('detailAddress', $event)"
      />
      <div v-if="!props.isViewOnly" class="remove-button" @click="handleRemove">
        <Icon name="material-symbols:close-rounded" />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
type TAddressValue = {
  province: string;
  ward: string;
  detailAddress: string;
  headquarter: boolean;
};
type TProps = {
  cityInfo: Record<string, any>[];
  value: TAddressValue;
  addressIndex: number;
  isViewOnly?: boolean;
};
const props = withDefaults(
defineProps<TProps>(),
  {
    isViewOnly: false,
  }
)

const emits = defineEmits<{
  (e: "input", value: TAddressValue): void;
  (e: "remove"): void;
}>();

const provinces = computed(() => {
  return props.cityInfo.map((city) => {
    return city.name;
  });
});

const wards = computed(() => {
  if (!props.value.province) {
    return [];
  }

  const province = props.cityInfo.find(
    (city) => city.name === props.value.province,
  );
  if (!province) {
    return [];
  }
  return province.wards.map((ward: any) => {
    return ward.name;
  });
});

const handleInput = (key: string, value: string | boolean) => {
  console.log(key, value);
  if (key == "province") {
    emits("input", {
      ...props.value,
      [key]: value as any,
      ward: "",
    });
  } else {
    emits("input", {
      ...props.value,
      [key]: value as any,
    });
  }
};
const handleRemove = () => {
  emits("remove");
};
const handleLabelClick = () => {
  if (props.isViewOnly){
    return;
  }
  emits("input", {
    ...props.value,
    headquarter: !props.value.headquarter,
  });
};
</script>
<style lang="scss" scoped>
.address-picker {
  margin-bottom: 8px;
  display: flex;
  flex-direction: row;
  gap: 8px;
  padding: 12px;
  border-radius: 4px;
  border: 1px solid $color-gray-200;
  position: relative;

  .remove-button {
    cursor: pointer;
    position: absolute;
    top: 4px;
    right: 4px;
    span {
      display: block;
      font-size: 20px;
      width: 20px;
      min-width: 20px;
      color: $color-gray-500;
    }
  }

  .picker-wrapper {
    display: flex;
    flex-direction: column;
    gap: 8px;
    width: 100%;

    .index {
      font-size: 14px;
      line-height: 21px;
      font-weight: 600;
    }

    .toggler-wrapper {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 8px;
      cursor: pointer;
      // margin-left: 16px;

      :deep(button) {
        cursor: pointer;
      }

      span {
        display: flex;
        flex-direction: row;
        gap: 8px;
        align-items: center;

        .iconify {
          font-size: 20px;
          height: 20px;
          width: 20px;
          min-width: 20px;
        }
      }
    }

    .line {
      display: flex;
      flex-direction: row;
      gap: 12px;
      width: 100%;

      .province-wrapper,
      .ward-wrapper {
        width: calc(50% - 6px);
        max-width: calc(50% - 6px);
      }

      :deep(.select-input) {
        button.selector {
          cursor: pointer;
          border: 1px solid rgba($color-primary-800, 0.1);
          border-radius: 10px !important;
          padding: 4px 48px 4px 6px !important;
          font-weight: 500 !important;
          color: $color-gray-600 !important;
          height: 32px;
          background-color: $color-gray-100 !important;
          min-width: 100%;
          max-width: 100%;

          &:hover:not(:disabled) {
            border: 1px solid rgba($color-primary-400, 1);
          }

          span {
            font-size: 14px;
            line-height: 21px;
            color: $text-light;
            font-weight: 400 !important;
          }
          .text-dimmed {
            font-size: 14px;
            line-height: 21px;
            color: $color-gray-400;
            font-weight: 400 !important;
          }
        }
      }
    }
  }

  .label,
  span {
    font-size: 14px;
    line-height: 21px;
    color: $text-light;

    .required {
      font-size: 12px;
      line-height: 21px;
      font-style: italic;
      color: $color-danger;
      margin-left: 4px;
    }
  }

  .label {
    margin-bottom: 4px;
  }

  span {
    min-width: 32px;
  }
}
</style>
