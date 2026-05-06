<template>
  <div class="wrapper">
    <div class="detail-content">
      <div class="top">
        <div class="back-button" @click="handleGoBack">
          <Icon name="material-symbols:arrow-back-ios-new-rounded" />
        </div>
        <div v-if="positionDetail" class="title">
          <div class="text">{{ title }}</div>
          <AppChip
            :text="status ? 'Đang hoạt động' : 'Ngừng hoạt động'"
            :type="status ? 'success' : 'error'"
          />
        </div>
      </div>
      <div class="form-content">
        <div v-if="positionDetail" class="misc">
          <div class="created">
            {{
              `Tạo bởi: ${positionDetail?.createdBy} - ${formattedDate(positionDetail?.createdAt)}`
            }}
          </div>
          <div v-if="positionDetail?.updatedBy" class="updated">
            {{
              `Cập nhật lần cuối bởi: ${positionDetail?.updatedBy} - ${formattedDate(positionDetail?.updatedAt)}`
            }}
          </div>
        </div>
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
                  :is-disabled="currentMode == 'view'"
                  class="text-input"
                  @input="handleInput('code', $event)"
                  @blur="validateKey('code')"
                />
                <AppInputText
                  :label="'Tên'"
                  :required="true"
                  :error="formError.name"
                  :placeholder="'Mời nhập tên'"
                  :is-disabled="currentMode == 'view'"
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
                    :disabled="currentMode == 'view'"
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
            <!--     :disabled="currentMode == 'view'" -->
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
            :disabled="currentMode == 'view'"
            @input="handleInput('process', $event)"
          />
        </div>
      </div>
      <div class="bottom">
        <template v-if="currentMode == 'edit'">
          <AppButton
            class="cancel-button"
            :text="'Hủy bỏ'"
            @click="handleCancelUpdate"
          />
          <AppButton
            class="toggle-button"
            :text="toggleButtonText"
            @click="handleToggleStatus"
          />
          <AppButton
            class="submit-button"
            :text="'Cập nhật'"
            :is-disabled="!isFormValid"
            @click="handleSubmitUpdate"
          />
        </template>
        <template v-else>
          <AppButton
            class="submit-button"
            :text="'Cập nhật'"
            @click="handleSwitchMode('edit')"
          />
        </template>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { cloneDeep, isEqual } from "lodash";
import { BREADCRUMB_BASE } from "~/const/views/org-admin/position";

definePageMeta({
  layout: "org-admin",
});

useHead({
  title: "Vị trí tuyển dụng",
});

const router = useRouter();
const { getDepartments } = useDepartmentApi();
const { getAll } = useProcessTypeApi();
const { setLoading } = useLoadingStore();
const { getPositionDetail, changePositionStatus, updatePosition } =
  usePositionApi();
const route = useRoute();
const breadcrumbStore = useBreadcrumbStore();
const { overrideItems, clearOverrideItems } = breadcrumbStore;

const departmentList = ref<Record<string, any>[]>([]);
const processList = ref<Record<string, any>[]>([]);
const positionDetail = ref<Record<string, any> | null>(null);
const currentMode = ref<string>("view");

const snapshotForm = ref<Record<string, any>>({});
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

const fetchDetail = async () => {
  const id = route.params.id;
  if (!id) {
    return;
  }
  const detailRes = await getPositionDetail(+id);
  if (detailRes) {
    positionDetail.value = detailRes.data;
    const department = departmentOption.value.find(
      (dept) => dept.value == positionDetail.value?.departmentId,
    );

    const processes = positionDetail.value?.listProcess
      .slice(1, positionDetail.value?.listProcess.length - 1)
      .map((process: any) => {
        const res = {
          processName: process.processType.name,
          processId: process.processTypeId,
          name: process.name,
          id: process.id,
        };
        return res;
      });

    // const levels: any[] = [];
    // for (const level of positionDetail.value?.listLevel ?? []) {
    //   const index = levels.findIndex(
    //     (lvl) => lvl.levelName == level.level.name,
    //   );
    //   if (index != -1) {
    //     levels[index].sub.push({
    //       name: level.name,
    //       id: level.id,
    //     });
    //   } else {
    //     levels.push({
    //       levelName: level.level.name,
    //       levelId: level.levelId,
    //       sub: [
    //         {
    //           id: level.id,
    //           name: level.name,
    //         },
    //       ],
    //     });
    //   }
    // }

    formInput.value = {
      name: positionDetail.value?.name,
      code: positionDetail.value?.code,
      department: department,
      // level: levels,
      process: processes,
    };
    snapshotForm.value = cloneDeep(formInput.value);
    formError.value = {
      name: "",
      code: "",
      department: "",
    };
  }
};

onBeforeMount(async () => {
  setLoading(true);
  currentMode.value = route.query.mode ? (route.query.mode as string) : "view";
  let deptRes = await getDepartments({ pageIndex: 0, pageSize: 1 });
  deptRes = await getDepartments({
    pageIndex: 0,
    pageSize: deptRes.data.pageInfo.totalElements,
  });
  departmentList.value = deptRes.data.data;
  const res = await getAll();
  processList.value = res.data;
  await fetchDetail();
  overrideItems([
    ...BREADCRUMB_BASE,
    {
      name: positionDetail.value?.name,
      icon: "",
      url: route.fullPath,
    },
  ]);
  setLoading(false);
});

const departmentOption = computed(() => {
  return departmentList.value.map((dept) => ({
    label: dept.name,
    value: dept.id,
  }));
});

const title = computed(() => {
  return positionDetail.value?.name ?? "";
});

const status = computed(() => {
  return positionDetail.value?.isActive ?? false;
});

const toggleButtonText = computed(() => {
  if (positionDetail.value?.isActive) {
    return "Ngừng hoạt động";
  }
  return "Hoạt động";
});

const isFormValid = computed(() => {
  const input = formInput.value;
  if (isEqual(formInput.value, snapshotForm.value)) {
    return false;
  }
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

const formattedDate = computed(() => {
  return (date: number) => {
    return formatDateTime(date, "DD/MM/YYYY HH:mm");
  };
});

const handleGoBack = () => {
  if (window.history.state?.back) {
    router.back();
  } else {
    router.push("/org-admin/position");
  }
};

const handleToggleStatus = async () => {
  const status = positionDetail.value?.isActive;
  const payload = {
    ids: [positionDetail.value?.id],
    active: !status,
  };
  setLoading(true);
  const res = await changePositionStatus(payload);
  if (res && positionDetail.value) {
    positionDetail.value.isActive = !status;
  }
  setLoading(false);
};

const handleCancelUpdate = () => {
  formInput.value = cloneDeep(snapshotForm.value);
  currentMode.value = "view";
};

const handleSwitchMode = (mode: string) => {
  currentMode.value = mode;
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

const handleSubmitUpdate = async () => {
  validateForm();
  console.log(formInput.value);
  if (!isFormValid.value) {
    return;
  }
  const input = formInput.value;

  // const levels = [];
  // for (const level of input.level) {
  //   for (const sub of level.sub) {
  //     const mappedLevel: Record<string, any> = {
  //       levelId: level.levelId,
  //       name: sub.name,
  //     };
  //     if (sub.id) {
  //       mappedLevel.id = sub.id;
  //     }
  //     levels.push(mappedLevel);
  //   }
  // }

  const processes = [];
  let i = 1;
  for (const process of input.process) {
    const newProcess: Record<string, any> = {
      name: process.name,
      processTypeId: process.processId,
      sortOrder: ++i,
    };
    if (process.id) {
      newProcess.id = process.id;
    }
    processes.push(newProcess);
  }
  if (
    processList.value &&
    processList.value[processList.value.length - 1] &&
    processList.value[0]
  ) {
    const firstProcess = positionDetail.value?.listProcess[0];
    const lastProcess =
      positionDetail.value?.listProcess[
        positionDetail.value?.listProcess.length - 1
      ];

    processes.unshift({
      ...firstProcess,
      sortOrder: 1,
    });
    processes.push({
      ...lastProcess,
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
  const res = await updatePosition(positionDetail.value?.id, payload);
  if (res) {
    await fetchDetail();
    currentMode.value = "view";
  }
  setLoading(false);
};

watch(currentMode, async (newVal) => {
  if (newVal == "view") {
    const { mode, ...rest } = route.query;
    await router.replace({ query: rest });
  } else {
    await router.replace({ query: { ...route.query, mode: "edit" } });
  }
  overrideItems([
    ...BREADCRUMB_BASE,
    {
      name: positionDetail.value?.name,
      icon: "",
      url: route.fullPath,
    },
  ]);
});

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

  .detail-content {
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
        .text {
          height: 21px;
          display: inline-block;
        }
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 8px;
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

      .misc {
        font-size: 13px;
        font-style: italic;
        color: $color-gray-400;
      }

      .block {
        display: flex;
        flex-direction: column;
        gap: 2px;

        .title {
          align-items: center;
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
            cursor: pointer;
            border: 1px solid rgba($color-primary-800, 0.1);

            &:disabled {
              border: 1px solid rgba($color-gray-300, 1);
              cursor: default;
              opacity: 100%;
            }

            &.error {
              border: 1px solid $color-danger;
            }

            border-radius: 10px !important;
            padding: 6px 48px 6px 8px !important;
            font-weight: 500 !important;
            color: $text-light !important;
            height: 38px;
            background-color: white !important;
            width: 100%;
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
      gap: 8px;

      .submit-button {
        padding: 6px 12px;
        color: $text-dark;
        background-color: $color-primary-500;

        &.disabled {
          background-color: $color-gray-400;
        }
      }

      .cancel-button {
        padding: 5px 12px;
        color: $color-primary-500;
        border: 1px solid $color-primary-500;
      }

      .toggle-button {
        padding: 5px 12px;
        color: $color-primary-500;
        border: 1px solid $color-primary-500;
      }
    }
  }
}
</style>
