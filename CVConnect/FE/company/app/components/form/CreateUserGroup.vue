<template>
  <div class="create-user-group">
    <form class="form-block">
      <div class="line">
        <AppInputText
          :label="'Mã'"
          :required="true"
          :error="formError.code"
          :placeholder="'Mời nhập mã'"
          :value="formInput.code"
          class="text-input"
          @input="handleInput('code', $event)"
          @blur="validateKey('code')"
        />
        <div class="select-input">
          <div class="title">
            Loại thành viên <span class="required">Bắt buộc</span>
          </div>
          <USelect
            variant="none"
            :items="memberTypeOptions"
            placeholder="Mời chọn loại thành viên"
            :class="{ error: formError.memberType }"
            class="select"
            :model-value="
              formInput.memberType ? formInput.memberType : undefined
            "
            @update:model-value="handleMemberTypeChange($event)"
            @update:open="
              ($event) => {
                if (!$event) validateKey('memberType');
              }
            "
          />
          <div class="error">{{ formError.memberType }}</div>
        </div>
      </div>
      <div>
        <AppInputText
          :label="'Tên'"
          :required="true"
          :error="formError.name"
          :placeholder="'Mời nhập tên'"
          :value="formInput.name"
          class="text-input"
          @input="handleInput('name', $event)"
          @blur="validateKey('name')"
        />
      </div>
      <FormRoleMenuSelect
        v-if="formInput.memberType && menus"
        class="menu-select"
        :menus="menus"
        @perm-change="handlePermChange($event)"
      />
    </form>
    <FormCreateUserGroupFooter>
      <div class="buttons">
        <AppButton
          :text="'Hủy bỏ'"
          class="cancel-button"
          @click.prevent="handleCancelClick($event)"
        />
        <AppButton
          :is-disabled="!isFormValid"
          :text="'Tạo mới'"
          :is-loading="isSubmiting"
          class="submit-button"
          @click="handleSubmit"
        />
      </div>
    </FormCreateUserGroupFooter>
  </div>
</template>
<script setup lang="ts">
type TCreateForm = {
  code: string;
  name: string;
  memberType: string;
};
const formInput = ref<TCreateForm>({
  code: "",
  name: "",
  memberType: "",
});
const formError = ref<TCreateForm>({
  code: "",
  name: "",
  memberType: "",
});

const permValue = ref<any>({});

const formRules = {
  code: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.code = "Mời nhập mã";
        return false;
      }
      return true;
    },
  ],
  name: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.name = "Mời nhập tên";
        return false;
      }
      return true;
    },
  ],
  memberType: [
    (input: string) => {
      if (!input.trim()) {
        formError.value.memberType = "Mời chọn loại thành viên";
        return false;
      }
      return true;
    },
  ],
};

const memberTypes = ref<TAccountRole[]>([]);
const menus = ref<TSidebarItem[]>([]);
const isSubmiting = ref<boolean>(false);

const { getMemberTypes, createUserGroup } = useRoleApi();
const { getAllMenus } = useMenuApi();

const emit = defineEmits<{
  (e: "closeModal"): void;
  (e: "submit"): void;
}>();

onBeforeMount(async () => {
  const res = await getMemberTypes();
  memberTypes.value = res.data;
});

const handlePermChange = (event: any) => {
  permValue.value = event;
};

const handleCancelClick = (event: any) => {
  event.preventDefault();
  emit("closeModal");
};

const handleSubmit = async () => {
  validateForm();
  if (!isFormValid.value) {
    return;
  }

  const roleMenus = [];
  for (const [key, value] of Object.entries(permValue.value)) {
    const menuId = +key;
    const perm = [];
    for (const key of Object.keys(value as Record<string, any>)) {
      if ((value as Record<string, any>)[key]) {
        perm.push(key);
      }
    }

    if (perm.length) {
      roleMenus.push({
        menuId,
        permissions: perm,
      });
    }
  }

  // NOTE: Recursively loops into menus, grab any menu that has its descendant in the roleMenus array, put those menu id in a set
  const collectAncestors = (
    menuList: TSidebarItem[],
    targetIds: Set<number>,
    collected: Set<number>,
  ) => {
    for (const menu of menuList) {
      // if any child is in targetIds, mark this parent as well
      if (menu.children && menu.children.length) {
        const childIds = new Set(menu.children.map((c) => c.id));
        const hasSelectedChild = [...childIds].some((id) => targetIds.has(id));

        if (hasSelectedChild) {
          collected.add(menu.id);
          targetIds.add(menu.id); // so its ancestors can be picked too
        }

        // recurse deeper
        collectAncestors(menu.children, targetIds, collected);
      }
    }
  };

  const selectedIds = new Set(roleMenus.map((r) => r.menuId));
  const ancestorIds = new Set<number>();
  collectAncestors(menus.value, selectedIds, ancestorIds);
  for (const id of ancestorIds) {
    roleMenus.push({
      menuId: id,
    });
  }

  const payload = {
    code: formInput.value.code,
    name: formInput.value.name,
    memberType: formInput.value.memberType,
    roleMenus: roleMenus,
  };
  console.log(payload);

  isSubmiting.value = true;
  const res = await createUserGroup(payload);
  if (res) {
    emit("submit");
  }
  isSubmiting.value = false;
};

const handleMemberTypeChange = (value: any) => {
  formInput.value.memberType = value;
  formError.value.memberType = "";
};

const handleInput = (key: string, value: string) => {
  formInput.value[key as keyof typeof formInput.value] = value;
  formError.value[key as keyof typeof formError.value] = "";
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
      const ok = rule(input as string);
      if (!ok) {
        break;
      }
    }
  }
};

const memberTypeOptions = computed(() => {
  return memberTypes.value.map((memberType) => ({
    label: memberType.name,
    value: memberType.code,
  }));
});

const isFormValid = computed(() => {
  for (const key of Object.keys(
    formError.value,
  ) as (keyof typeof formError.value)[]) {
    if (formError.value[key]) {
      return false;
    }
  }
  return true;
});
watch(
  () => formInput.value.memberType,
  async (newVal, oldVal) => {
    console.log(newVal, oldVal);
    if (newVal && newVal != oldVal) {
      const menusRes = await getAllMenus(newVal);
      menus.value = menusRes.data;
    }
  },
  { deep: true },
);
</script>
<style lang="scss" scoped>
.create-user-group {
  @include custom-scrollbar;
  max-height: 100%;
  .form-block {
    display: flex;
    flex-direction: column;
    .line {
      display: flex;
      flex-direction: row;
      gap: 8px;
      justify-content: space-between;
      flex: 1;
    }
    .text-input {
      width: 380px;
      :deep(.input) {
        padding: 6px 8px;
        input {
          font-size: 13px;
        }
      }
    }
    .select-input {
      margin: 2px 0px;
      display: flex;
      flex-direction: column;
      gap: 4px;

      .title {
        font-size: 14px;
        display: flex;
        flex-direction: row;
        gap: 8px;
        align-items: center;
        .required {
          font-size: 12px;
          color: $color-danger;
          font-style: italic;
        }
      }

      :deep(.select) {
        padding: 6px 8px;
        background-color: white;
        font-size: 13px;
        height: 35px;
        border-radius: 10px;
        border: 1px solid rgba($color-primary-800, 0.1);
        color: $text-light;
        width: 380px;
        &:hover {
          border: 1px solid rgba($color-primary-400, 1);
        }
        &.error {
          border: 1px solid $color-danger;
        }

        .text-dimmed {
          color: $color-gray-300;
        }
      }

      .error {
        min-height: 16px;
        display: inline-block;
        color: $color-danger;
        font-size: 12px;
        line-height: 16px;
      }
    }
  }
}
</style>
