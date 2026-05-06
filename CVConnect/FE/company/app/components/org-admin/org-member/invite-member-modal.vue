<template>
  <div class="create-modal">
    <UModal
      v-model:open="isOpen"
      title="Gửi lời mời"
      :ui="{ content: 'w-[600px] max-w-[600px]' }"
    >
      <template #body>
        <div class="create-department">
          <form class="form-block">
            <div class="line">
              <AppInputSearchSelect
                :label="'Người dùng'"
                :required="true"
                :options="memberList"
                :value="formInput.member"
                :error="formError.member"
                :placeholder="'Mời chọn người dùng'"
                :search-placeholder="'Tìm kiếm email'"
                :remote-filter="true"
                :multiple="false"
                :fetch-fn="fetchNotOrgMembers"
                @open-update="handleMemberOpenUpdate"
                @input="handleInput('member', $event)"
                @clear-value="handleClearMember"
                @search-filter="
                  () => {
                    memberList = [];
                  }
                "
              />
            </div>
            <div class="line">
              <AppInputSearchSelect
                :label="'Tham gia với vai trò'"
                :required="true"
                :options="roleList"
                :value="formInput.role"
                :error="formError.role"
                :placeholder="'Mời chọn vai trò'"
                :remote-filter="false"
                :multiple="false"
                :fetch-fn="fetchRoles"
                @open-update="handleRoleOpenUpdate"
                @input="handleInput('role', $event)"
                @clear-value="handleClearRole"
                @search-filter="
                  () => {
                    roleList = [];
                  }
                "
              />
            </div>
          </form>
        </div>
      </template>
      <template #footer>
        <div class="footer">
          <div class="buttons">
            <AppButton
              :text="'Hủy bỏ'"
              class="cancel-button"
              @click.prevent="handleCancelClick($event)"
            />
            <AppButton
              :is-disabled="!isFormValid"
              :text="'Gửi'"
              :is-loading="isSubmiting"
              class="submit-button"
              @click="handleSubmit"
            />
          </div>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import type { TSubIndustry } from "~/types/subIndustry";

type TProps = {
  modelValue: boolean;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
  (e: "submit"): void;
}>();

type TCreateForm = {
  member: Record<string, any> | undefined;
  role: Record<string, any> | undefined;
};

const roleList = ref<Record<string, any>[]>([]);
const memberList = ref<Record<string, any>[]>([]);
const formInput = ref<TCreateForm>({
  member: undefined,
  role: undefined,
});
const formError = ref<Record<string, any>>({
  member: "",
  role: "",
});

const formRules = {
  member: [
    (input: string) => {
      if (!input) {
        formError.value.code = "Mời chọn thành viên";
        return false;
      }
      return true;
    },
  ],
  role: [
    (input: string) => {
      if (!input) {
        formError.value.name = "Mời chọn vai trò";
        return false;
      }
      return true;
    },
  ],
};

const { findNotOrgMembers, getRoleFilterOption, inviteToOrg } =
  useOrgMemberApi();

const isSubmiting = ref<boolean>(false);

// computed getter/setter to bind v-model
const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const isFormValid = computed(() => {
  console.log(formInput.value);
  if (!formInput.value.member || !formInput.value.role) {
    return false;
  }

  return true;
});

async function fetchNotOrgMembers(params: any, controller?: AbortController) {
  const newParams = {
    email: params.name,
  };
  console.log(newParams);
  const res = await findNotOrgMembers(newParams, controller);
  if (!res) {
    return null;
  }
  const nextPage = res.data.data
    .filter((member: any) => member.isActive)
    .map((member: any) => ({
      label: `${member.email} • ${member.fullName}`,
      value: member.id,
    }));
  memberList.value = [...memberList.value, ...nextPage];
  return res.data.data;
}

async function fetchRoles(params: any, controller?: AbortController) {
  const res = await getRoleFilterOption();
  if (!res) {
    return null;
  }
  console.log(res.data);
  const nextPage = res.data.map((role: any) => ({
    label: role.name,
    value: role.id,
  }));
  roleList.value = [...roleList.value, ...nextPage];
  return res.data;
}

const handleInput = <K extends keyof TCreateForm>(
  key: K,
  value: TCreateForm[K],
) => {
  formInput.value[key] = value;
  formError.value[key] = "";
};

const handleCancelClick = (event: any) => {
  event.preventDefault();
  emits("update:modelValue", false);
};

const handleSubmit = async () => {
  validateForm();
  if (!isFormValid.value) {
    return;
  }

  const payload = {
    userId: formInput.value.member?.value,
    roleId: formInput.value.role?.value,
  };

  isSubmiting.value = true;
  const res = await inviteToOrg(payload);
  if (res) {
    formInput.value = {
      member: undefined,
      role: undefined,
    };
    formError.value = {
      code: "",
      name: "",
    };
    emits("submit");
  }
  isSubmiting.value = false;
};

function handleMemberOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("member");
  }
}

function handleRoleOpenUpdate(value: boolean) {
  if (!value) {
    validateKey("role");
  }
}

function handleClearMember() {
  handleInput("member", undefined);
}

function handleClearRole() {
  handleInput("role", undefined);
}

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
</script>
<style lang="scss" scoped>
.create-department {
  @include custom-scrollbar;
  max-height: 100%;
  .form-block {
    display: flex;
    flex-direction: column;
    gap: 4px;
    .line {
      display: flex;
      flex-direction: row;
      gap: 8px;
      justify-content: space-between;
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
  }
}
</style>
