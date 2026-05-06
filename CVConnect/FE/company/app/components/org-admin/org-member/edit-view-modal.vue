<template>
  <div class="edit-view-modal">
    <UModal v-model:open="isOpen" :ui="{ content: 'max-w-[840px]' }">
      <template #header>
        <div class="flex items-center justify-between w-full">
          <div class="flex items-center gap-2">
            <span class="text-highlighted font-semibold">
              {{ title }}
            </span>
          </div>
          <UButton
            icon="i-heroicons-x-mark"
            variant="ghost"
            class="rounded-md font-medium inline-flex items-center disabled:cursor-not-allowed aria-disabled:cursor-not-allowed disabled:opacity-75 aria-disabled:opacity-75 transition-colors text-sm gap-1.5 text-default hover:bg-elevated active:bg-elevated focus:outline-none focus-visible:bg-elevated hover:disabled:bg-transparent dark:hover:disabled:bg-transparent hover:aria-disabled:bg-transparent dark:hover:aria-disabled:bg-transparent p-1.5 absolute top-4 end-4"
            @click="isOpen = false"
          />
        </div>
      </template>
      <template #body>
        <div class="edit-view-org-member">
          <div v-if="isLoading" class="loading-overlay">
            <AppSpinnerHalfCircle class="spinner" />
          </div>
          <template v-if="!isLoading && detail">
            <div class="info">
              <div v-if="detail?.avatarUrl" class="avatar">
                <img :src="detail?.avatarUrl" />
              </div>
              <div v-else :style="{'background-color': getMonogram(detail?.userId, detail?.fullName).color}" class="avatar monogram">
                {{ getMonogram(detail?.userId, detail?.fullName).text }} 
              </div>
              <div class="information">
                <div class="name">{{ detail?.fullName }}</div>
                <div class="job-pos">
                  {{ detail?.roles?.map((role: any) => role.name)?.join(", ") }}
                </div>
              </div>
            </div>
            <div class="divider"></div>
            <div class="form-block">
              <div class="column">
                <div class="info-unit">
                  <div class="label">Email:</div>
                  <div class="info">{{ detail?.email }}</div>
                </div>
                <div class="info-unit">
                  <div class="label">SĐT:</div>
                  <div class="info">{{ detail?.phoneNumber }}</div>
                </div>
                <div class="info-unit">
                  <div class="label">Xác thực email:</div>
                  <AppChip
                    :type="
                      detail?.isEmailVerified
                        ? CHIP_TYPE.SUCCESS
                        : CHIP_TYPE.ERROR
                    "
                    :text="
                      detail?.isEmailVerified ? 'Đã xác thực' : 'Chưa xác thực'
                    "
                  />
                </div>
                <div class="info-unit">
                  <div class="label">Trạng thái hoạt động:</div>
                  <AppChip
                    :type="
                      detail?.isActive ? CHIP_TYPE.SUCCESS : CHIP_TYPE.ERROR
                    "
                    :text="
                      detail?.isActive ? 'Đang hoạt động' : 'Ngừng hoạt động'
                    "
                  />
                </div>
              </div>
              <div class="column">
                <div class="column">
                  <div class="info-unit">
                    <div class="label">Ngày tham gia:</div>
                    <div class="info">
                      {{
                        formatDateTime(detail?.createdAt, "DD/MM/YYYY - HH:mm")
                      }}
                    </div>
                  </div>
                  <div class="info-unit">
                    <div class="label">Người mời:</div>
                    <div class="info">{{ detail?.inviter }}</div>
                  </div>
                </div>
                <div class="column">
                  <div class="info-unit">
                    <div class="label">Ngày cập nhật:</div>
                    <div class="info">
                      {{
                        formatDateTime(detail?.updatedAt, "DD/MM/YYYY - HH:mm")
                      }}
                    </div>
                  </div>
                  <div class="info-unit">
                    <div class="label">Người cập nhật</div>
                    <div class="info">{{ detail?.updatedBy }}</div>
                  </div>
                </div>
              </div>
            </div>
            <div v-if="currentMode == 'edit'" class="form-block">
              <AppInputSearchSelect
                :label="'Vai trò'"
                :required="true"
                :options="rolesOptions"
                :value="formInput.role"
                :error="formError.role"
                :placeholder="'Mời chọn vai trò'"
                :remote-filter="false"
                :search-placeholder="'Tìm kiếm email'"
                :multiple="true"
                :fetch-fn="null"
                @open-update="handleRoleOpenUpdate"
                @input="handleInput('role', $event)"
                @clear-value="handleClearRole"
                @search-filter="
                  () => {
                    rolesOptions = [];
                  }
                "
              />
            </div>
          </template>
        </div>
      </template>
      <template #footer>
        <div class="footer">
          <div class="buttons">
            <template v-if="currentMode == 'view'">
              <AppButton
                :text="'Đóng'"
                class="cancel-button"
                @click.prevent="handleCancelClick($event)"
              />
              <AppButton
                v-if="props.allowEdit"
                :text="'Cấp quyền'"
                class="submit-button"
                @click="handleSwitchMode('edit')"
              />
            </template>
            <template v-else>
              <AppButton
                :text="'Hủy bỏ'"
                class="cancel-button"
                @click.prevent="
                  props.initialMode == 'view'
                    ? handleSwitchMode('view')
                    : handleCancelClick($event)
                "
              />
              <AppButton
                v-if="detail && detail.isActive"
                :text="'Ngừng hoạt động'"
                :is-loading="isChangingStatus"
                class="active-btn deactive"
                @click="handleChangeStatus(false)"
              />
              <AppButton
                v-if="detail && !detail.isActive"
                :text="'Hoạt động'"
                :is-loading="isChangingStatus"
                class="active-btn active"
                @click="handleChangeStatus(true)"
              />
              <AppButton
                :is-disabled="!isFormValid"
                :text="'Lưu'"
                :is-loading="isSubmiting"
                class="submit-button"
                @click="handleSubmit"
              />
            </template>
          </div>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import type { TSubIndustry } from "~/types/subIndustry";
import { cloneDeep } from "lodash";
import { CHIP_TYPE } from "~/const/common";

type TProps = {
  modelValue: boolean;
  initialMode?: string;
  allowEdit?: boolean;
  targetId: number;
};

const props = withDefaults(defineProps<TProps>(), {
  initialMode: "view",
  allowEdit: false,
});
const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "modeChange", value: string): void;
  (e: "submit"): void;
}>();

const currentMode = ref<string>("view");
const detail = ref<any>(null);
const detailSnapshot = ref<any>(null);
const isLoading = ref<boolean>(false);
const formInput = ref<Record<string, any>>({
  role: [],
});
const formError = ref<Record<string, any>>({
  role: "",
});

const formRules = {
  role: [
    (input: any[]) => {
      if (!input.length) {
        formError.value.role = "Mời chọn vai trò";
        return false;
      }
      return true;
    },
  ],
};

const {
  getOrgMemberDetail,
  getRoleFilterOption,
  changeOrgMemberStatus,
  assignRole,
} = useOrgMemberApi();
const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);
const { logout } = useAuth();

const isSubmiting = ref<boolean>(false);
const isChangingStatus = ref<boolean>(false);
const rolesOptions = ref<Record<string, any>[]>([]);

onBeforeMount(async () => {
  const res = await getRoleFilterOption();
  rolesOptions.value = res.data.map((role: any) => ({
    label: role.name,
    value: role.id,
  }));
});

// computed getter/setter to bind v-model
const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const title = computed(() => {
  if (currentMode.value == "view") {
    return "Thông tin thành viên";
  }

  if (currentMode.value == "edit") {
    return "Cập nhật quyền thành viên";
  }

  return "";
});

const isFormValid = computed(() => {
  for (const key of Object.keys(
    formError.value,
  ) as (keyof typeof formError.value)[]) {
    if (formError.value[key]) {
      return false;
    }
  }

  if (formInput.value.role.length == 0) {
    return false;
  }

  return true;
});

const handleInput = (key: string, value: any) => {
  formInput.value[key] = value;
  formError.value[key] = "";
};

const handleSwitchMode = (mode: string) => {
  currentMode.value = mode;
};

function handleClearRole() {
  handleInput("role", []);
}

function handleRoleOpenUpdate(value: boolean) {
  console.log(value);
  if (!value) {
    console.log("hehe");
    validateKey("role");
  }
}

const handleCancelClick = (event: any) => {
  event.preventDefault();
  emits("update:modelValue", false);
};

const handleChangeStatus = async (status: boolean) => {
  const payload = {
    ids: [detail.value.userId],
    active: status,
  };
  isChangingStatus.value = true;
  const res = await changeOrgMemberStatus(payload);
  if (res) {
    detail.value.isActive = status;
    if (detail.value.userId == userInfo.value?.id) {
      await logout();
    }
  }
  isChangingStatus.value = false;
};

const handleSubmit = async () => {
  validateForm();
  if (!isFormValid.value) {
    return;
  }

  const payload = {
    userId: detail.value.userId,
    roleIds: formInput.value.role.map((role: any) => role.value),
  };

  isSubmiting.value = true;
  const res = await assignRole(payload);
  if (res) {
    if (detail.value.userId == userInfo.value?.id) {
      await logout();
      return;
    }
    if (props.initialMode == "edit") {
      emits("submit");
    } else {
      currentMode.value = "view";
      await fetchDetail(detail.value.userId);
    }
  }
  isSubmiting.value = false;
  isSubmiting.value = false;
};

const fetchDetail = async (id: number) => {
  isLoading.value = true;
  const res = await getOrgMemberDetail(id);
  console.log(res);
  detail.value = res.data;
  formInput.value = {
    role: detail.value.roles.map((role: any) => ({
      label: role.name,
      value: role.id,
    })),
  };
  // formInput.value = {
  //   name: res.data.name,
  //   code: res.data.code,
  // };
  detailSnapshot.value = cloneDeep(formInput.value);
  isLoading.value = false;
};

const validateForm = () => {
  for (const key of Object.keys(
    formInput.value,
  ) as (keyof typeof formInput.value)[]) {
    validateKey(key);
  }
};

const validateKey = (key: keyof typeof formInput.value) => {
  const input = formInput.value[key];
  const rules = formRules[key as keyof typeof formRules];
  if (rules) {
    for (const rule of rules) {
      const ok = rule(input as any);
      if (!ok) {
        break;
      }
    }
  }
};

watch(
  () => props.initialMode,
  (newVal) => {
    currentMode.value = newVal;
  },
  {
    immediate: true,
  },
);

watch(currentMode, (newVal) => {
  emits("modeChange", newVal);
  if (newVal == "view") {
    if (detailSnapshot.value) {
      formInput.value = detailSnapshot.value;
      formError.value = {
        code: "",
        name: "",
      };
    }
  }
});

watch(
  () => props.targetId,
  async (newVal) => {
    if (newVal == -1) {
      detailSnapshot.value = null;
      detail.value = null;
      formInput.value = {
        role: [],
      };
      formError.value = {
        role: "",
      };
      return;
    }
    await fetchDetail(newVal);
  },
  {
    immediate: true,
  },
);
</script>
<style lang="scss" scoped>
.edit-view-org-member {
  position: relative;
  .loading-overlay {
    position: absolute;
    color: $color-primary-400;
    font-size: 20px;
    top: 0px;
    left: 0px;
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1;
  }
  @include custom-scrollbar;
  max-height: 100%;
  .divider {
    height: 1px;
    width: 100%;
    display: block;
    background-color: $color-gray-200;
    margin-top: 24px;
  }
  .info {
    display: flex;
    flex-direction: row;
    gap: 24px;
    align-items: center;
    justify-content: center;

    .avatar {
      height: 116px;
      width: 116px;
      min-width: 116px;
      background-color: $color-gray-400;
      border-radius: 999px;
      overflow: hidden;

      &.monogram {
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 48px;
        font-weight: 600;
        color: $text-dark;
      }

      img {
        height: 116px;
        width: 116px;
        object-fit: cover;
      }
    }

    .information {
      height: 100%;
      display: flex;
      flex-direction: column;
      justify-content: space-around;
      height: 84px;

      .name {
        font-size: 24px;
        font-weight: 600;
      }

      .job-pos {
        font-size: 18px;
        font-weight: 400;
        color: $color-gray-600;
      }
    }
  }
  .info-unit {
    display: flex;
    flex-direction: row;
    gap: 6px;
    height: 28px;
    align-items: center;
    justify-content: space-between;
    .label {
      font-size: 14px;
      font-weight: 600;
    }
    .info {
      font-size: 14px;
      font-weight: 400;
    }
  }
  .form-block {
    margin-top: 12px;
    padding: 12px;
    display: flex;
    flex-direction: row;
    gap: 36px;
    flex-wrap: wrap;

    :deep(.search-select-input) {
      .text {
        font-weight: 600;
      }
    }

    @media (max-width: 720px) {
      flex-direction: column;
      width: 80%;
      padding: 24px;
      margin: auto;
      margin-top: 24px;
      gap: 8px;
      padding-top: 0px;
      padding-bottom: 0px;
    }
    .column {
      display: flex;
      flex-direction: column;
      gap: 8px;
      flex: 1;
    }

    .text-input {
      width: 100%;
      :deep(.input) {
        padding: 6px 8px;
        input {
          font-size: 13px;
        }
      }
    }
    .text-area {
      width: 100%;

      :deep(textarea) {
        font-size: 13px;
      }
    }
    .sub-list {
      display: flex;
      flex-direction: column;
      gap: 4px;
      width: 100%;

      .label {
        font-size: 14px;
        color: $text-light;
      }

      .add-button {
        border: 1px dashed $color-danger;
        border-radius: 10px;
        padding: 8px;
        text-align: center;
        background-color: rgba($color-danger, 0.05);
        color: $color-danger;
        font-size: 13px;
        cursor: pointer;
        margin-top: 4px;
      }
    }
  }
}

.footer {
  width: 100%;
  height: fit-content;
  :deep(.buttons) {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: flex-end;
    gap: 8px;

    .cancel-button,
    .submit-button {
      padding: 4px 14px 4px 14px;

      :deep(.button-text) {
        font-size: 14px;
      }
    }

    .submit-button {
      background-color: $color-primary-400;
      color: $text-dark;

      &.disabled {
        background-color: $color-gray-400;
      }
    }
    .cancel-button {
      padding: 3px 14px 3px 14px;
      background-color: white;
      color: $color-primary-400;
      border: 1px solid $color-primary-400;
    }

    .active-btn {
      background-color: white;
      padding: 3px 14px 3px 14px;

      :deep(.button-text) {
        font-size: 14px;
      }

      &.disabled {
        border: 1px solid $color-gray-400;
        color: $color-gray-400;
      }
    }

    .active {
      color: $color-success;
      border: 1px solid $color-success;
    }

    .deactive {
      color: $color-primary-400;
      border: 1px solid $color-primary-400;
    }
  }
}
</style>
