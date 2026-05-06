<template>
  <div class="wrapper">
    <div class="create-content">
      <div class="top">
        <div class="back-button" @click="handleGoBack">
          <Icon name="material-symbols:arrow-back-ios-new-rounded" />
        </div>
        <div class="title">Thêm mới vị trí tuyển dụng</div>
      </div>
      <div class="form-content">
        <div class="block">
          <div class="columns">
            <div class="col">
              <div class="title">Thông tin chung</div>
              <div class="row">
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
                <div class="select-input">
                  <div class="label">
                    <span class="text">Phòng ban</span>
                    <span class="required">Bắt buộc</span>
                  </div>
                  <USelectMenu
                    :model-value="formInput.department"
                    :items="departmentOption"
                    class="selector"
                    :class="{ error: formError.department }"
                    :variant="'none'"
                    autocomplete="autocomplete"
                    placeholder="Mời chọn phòng ban"
                    :title="formInput.department?.label ?? ''"
                    :search-input="{
                      placeholder: 'Tìm kiếm',
                    }"
                    :ui="{
                      trailingIcon:
                        'group-data-[state=open]:rotate-180 transition-transform duration-200',
                    }"
                    @update:model-value="handleInput('department', $event)"
                    @update:open="
                      ($event) =>
                        !$event ? validateKey('department') : () => {}
                    "
                  />
                  <div class="error-message">{{ formError.department }}</div>
                </div>
              </div>
            </div>
            <!-- <div class="col"> -->
            <!--   <div class="title">Thiết lập cấp bậc</div> -->
            <!--   <PositionCreateLevelBlock -->
            <!--     :list="formInput.level" -->
            <!--     @input="handleInput('level', $event)" -->
            <!--   /> -->
            <!-- </div> -->
          </div>
        </div>
        <div class="block">
          <div class="title">Thiết lập quy trình tuyển dụng</div>
          <PositionCreateProcessBlock
            :list="formInput.process"
            :process-list="processList"
            @input="handleInput('process', $event)"
          />
        </div>
      </div>
      <div class="bottom">
        <AppButton
          class="submit-button"
          :text="'Thêm mới'"
          :is-disabled="!isFormValid"
          @click="handleSubmit"
        />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { BREADCRUMB_BASE } from "~/const/views/org-admin/position";

definePageMeta({
  layout: "org-admin",
});

useHead({
  title: "Thêm mới vị trí tuyển dụng",
});

const router = useRouter();
const { getDepartments } = useDepartmentApi();
const { getAll } = useProcessTypeApi();
const { setLoading } = useLoadingStore();
const { createPosition } = usePositionApi();
const breadcrumbStore = useBreadcrumbStore();
const { overrideItems, clearOverrideItems } = breadcrumbStore;

const departmentList = ref<Record<string, any>[]>([]);
const processList = ref<Record<string, any>[]>([]);

const formInput = ref<Record<string, any>>({
  name: "",
  code: "",
  department: null,
  // level: [],
  process: [],
});

const formError = ref<Record<string, any>>({
  name: "",
  code: "",
  department: "",
});

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
  department: [
    (input: any) => {
      if (!input) {
        formError.value.department = "Mời thêm phòng ban";
        return false;
      }
      return true;
    },
  ],
};

onBeforeMount(async () => {
  setLoading(true);
  let deptRes = await getDepartments({ pageIndex: 0, pageSize: 1 });
  deptRes = await getDepartments({
    pageIndex: 0,
    pageSize: deptRes.data.pageInfo.totalElements,
  });
  departmentList.value = deptRes.data.data;
  const res = await getAll();
  processList.value = res.data;
  setLoading(false);
  overrideItems([
    ...BREADCRUMB_BASE,
    {
      name: "Thêm mới",
      icon: "",
      url: "/org-admin/position/create",
    },
  ]);
});

const departmentOption = computed(() => {
  return departmentList.value.map((dept) => ({
    label: dept.name,
    value: dept.id,
  }));
});

const isFormValid = computed(() => {
  const input = formInput.value;
  console.log(input);
  if (!input.name.trim() || !input.code.trim() || !input.department) {
    return false;
  }
  // console.log(input.level);
  // for (const level of input.level) {
  //   console.log(level);
  //   for (const sub of level.sub) {
  //     console.log(sub);
  //     if (!sub.name.trim()) {
  //       return false;
  //     }
  //   }
  // }
  for (const process of input.process) {
    if (!process.name.trim()) {
      return false;
    }
  }
  return true;
});

const handleGoBack = () => {
  if (window.history.state?.back) {
    router.back();
  } else {
    router.push("/org-admin/position");
  }
};

const handleInput = (key: string, value: any) => {
  formInput.value[key] = value;
  formError.value[key] = "";
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
  console.log(input);
  const rules = formRules[key as keyof typeof formRules];
  if (rules) {
    for (const rule of rules) {
      const ok = rule(input);
      if (!ok) {
        break;
      }
    }
  }
};

const handleSubmit = async () => {
  validateForm();
  console.log(formInput.value);
  if (!isFormValid.value) {
    return;
  }
  const input = formInput.value;

  // const levels = [];
  // for (const level of input.level) {
  //   for (const sub of level.sub) {
  //     levels.push({
  //       levelId: level.levelId,
  //       name: sub.name,
  //     });
  //   }
  // }

  const processes = [];
  let i = 1;
  for (const process of input.process) {
    processes.push({
      name: process.name,
      processTypeId: process.processId,
      sortOrder: ++i,
    });
  }
  if (
    processList.value &&
    processList.value[processList.value.length - 1] &&
    processList.value[0]
  ) {
    processes.unshift({
      name: processList.value[0]?.name,
      processTypeId: processList.value[0]?.id,
      sortOrder: 1,
    });
    processes.push({
      name: processList.value[processList.value.length - 1]?.name,
      processTypeId: processList.value[processList.value.length - 1]?.id,
      sortOrder: processes.length + 1,
    });
  }

  const payload = {
    code: input.code,
    name: input.name,
    departmentId: input.department.value,
    // positionLevel: levels,
    positionProcess: processes,
  };

  setLoading(true);
  const res = await createPosition(payload);
  if (res) {
    setLoading(false);
    handleGoBack();
  }
  setLoading(false);
};

onBeforeUnmount(() => {
  clearOverrideItems();
});
</script>
<style lang="scss" scoped>
.wrapper {
  overflow: hidden;
  min-height: 0;
  flex: 1;
  border-radius: 8px;
  margin-top: 8px;
  @include box-shadow;

  .create-content {
    background-color: white;
    min-height: calc(100% - 48px - 8px);
    @include box-shadow;
    color: $text-light;
    padding: 20px 20px 12px 20px;
    display: flex;
    flex-direction: column;
    gap: 12px;
    overflow-y: auto;
    overflow-x: hidden;
    @include custom-scrollbar;
    height: 100%;

    .top {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 12px;
      background-color: white;

      .back-button {
        display: flex;
        flex-direction: row;
        gap: 12px;
        align-items: center;
        background-color: $color-gray-100;
        padding: 8px 9px 8px 7px;
        border-radius: 999px;
        cursor: pointer;

        .iconify {
          display: block;
          font-size: 16px;
          color: $color-primary-500;
        }
      }

      .title {
        font-weight: 700;
        font-size: 16px;
        line-height: 20px;
      }
    }
    .form-content {
      display: flex;
      flex-direction: column;
      gap: 4px;
      flex: 1;
      min-height: 0;
      overflow-y: auto;
      padding-right: 20px;
      margin-right: -20px;

      .block {
        display: flex;
        flex-direction: column;
        gap: 2px;

        .title {
          font-weight: 600;
        }

        .row {
          display: flex;
          flex-direction: row;
          gap: 12px;
          width: 100%;
          flex-wrap: wrap;
        }

        .columns {
          display: flex;
          flex-direction: row;
          gap: 16px;
          row-gap: 4px;
          flex-wrap: wrap;
          .col {
            display: flex;
            flex-direction: column;
            gap: 4px;
            flex: 1;
          }
        }

        :deep(.text-input) {
          flex: 1;
          .input {
            padding: 6px 8px;
            input {
              font-size: 14px;
            }
          }
        }

        .select-input {
          display: flex;
          flex-direction: column;
          gap: 4px;
          flex: 1;

          .label {
            display: flex;
            flex-direction: row;
            gap: 8px;
            align-items: center;
            width: fit-content;

            .text {
              font-size: 14px;
              line-height: 21px;
            }

            .required {
              font-size: 12px;
              font-style: italic;
              color: $color-danger;
            }
          }

          .error-message {
            min-height: 16px;
            display: inline-block;
            color: $color-danger;
            font-size: 12px;
            line-height: 16px;
          }

          :deep(button.selector) {
            margin: 2px 0px;
            cursor: pointer;
            border: 1px solid rgba($color-primary-800, 0.1);

            &.error {
              border: 1px solid $color-danger;
            }

            border-radius: 10px !important;
            padding: 6px 48px 6px 8px !important;
            font-weight: 500 !important;
            color: $text-light !important;
            height: 36px;
            background-color: white !important;
            width: 100%;
            max-width: 100%;

            &:hover {
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
              color: $color-gray-300;
              font-weight: 400 !important;
            }
          }
        }
      }

      .divider {
        width: 100%;
        height: 1px;
        min-height: 1px;
        display: block;
        background-color: $color-gray-300;
      }
    }

    .bottom {
      display: flex;
      justify-content: flex-end;

      .submit-button {
        padding: 6px 12px;
        color: $text-dark;
        background-color: $color-primary-500;

        &.disabled {
          background-color: $color-gray-400;
        }
      }
    }
  }
}
</style>
