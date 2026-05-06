<template>
  <UModal
    v-model:open="isOpen"
    title="Xem trước email"
    :ui="{ content: 'w-[900px] max-w-[900px] max-h-[90vh]' }"
  >
    <template #body>
      <div v-if="isLoading" class="spinner">
        <AppSpinnerHalfCircle />
      </div>
      <div v-else class="content">
        <div class="header">
          <div class="notice">
            <Icon name="material-symbols:info-outline-rounded" />
            <span>Dữ liệu dưới đây là dữ liệu mẫu</span>
          </div>
          <div class="mode-switcher">
            <div
              class="button website"
              :class="{ active: currentMode == 'website' }"
              @click="currentMode = 'website'"
            >
              <Icon name="material-symbols:computer-outline-rounded" />
              <span class="text">Website</span>
            </div>
            <div
              class="button mobile"
              :class="{ active: currentMode == 'mobile' }"
              @click="currentMode = 'mobile'"
            >
              <Icon name="material-symbols:phone-android-outline-rounded" />
              <span class="text">Mobile</span>
            </div>
          </div>
        </div>
        <div
          class="mail-content"
          :class="{ 'is-mobile': currentMode == 'mobile' }"
        >
          <div class="mail-subject">
            {{ mailDetail?.subject || "Tiêu đề" }}
          </div>
          <div class="content">
            <div class="avatar-col">
              <div class="avatar">
                <img src="/blankuser.jpg" />
              </div>
            </div>
            <div class="content-col">
              <div class="title">
                <div class="company-name">
                  {{ orgInfo?.name || "Tên công ty" }}
                </div>
                <div class="recipient">Đến: Nguyễn Minh Quân</div>
              </div>
              <div
                class="detail-content"
                v-html="mailDetail?.bodyPreview || ''"
              ></div>
            </div>
          </div>
        </div>
      </div>
    </template>
    <template #footer>
      <div class="footer">
        <div class="buttons">
          <AppButton :text="'OK'" class="submit-button" @click="handleClose" />
        </div>
      </div>
    </template>
  </UModal>
</template>

<script setup lang="ts">
type TProps = {
  modelValue: boolean;
  data: Record<string, any>;
  templateId: number | null | undefined;
};

const userStore = useUserStore();
const { userInfo } = storeToRefs(userStore);
const { getMailTemplatePreviewNoTemplate, getMailTemplatePreviewDefault } =
  useMailTemplateApi();

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "update:modelValue", value: boolean): void;
}>();

const isLoading = ref<boolean>(false);
const currentMode = ref<string>("website");
const mailDetail = ref<Record<string, any>>({});

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emits("update:modelValue", value),
});

const orgInfo = computed(() => {
  for (const detail of userInfo.value?.userDetails ?? []) {
    if (detail.detailInfo.org) {
      return detail.detailInfo.org;
    }
  }
  return null;
});

function handleClose() {
  emits("update:modelValue", false);
}

watch(
  () => props.modelValue,
  async (newVal) => {
    if (newVal) {
      isLoading.value = true;
      if (props.templateId != null && props.templateId != undefined) {
        const res = await getMailTemplatePreviewDefault(
          props.templateId,
          props.data.dataReplacePlaceholder,
        );
        mailDetail.value = res.data;
        isLoading.value = false;
        return;
      }
      const res = await getMailTemplatePreviewNoTemplate(
        props.data.subject,
        props.data.body,
        props.data.placeholderCodes,
        props.data.dataReplacePlaceholder,
      );
      mailDetail.value = res.data;
      isLoading.value = false;
    }
  },
);
</script>
<style lang="scss" scoped>
.create-department {
  @include custom-scrollbar;
  max-height: 100%;
}

.spinner {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 120px;
}

.content {
  max-height: calc(90vh - 176px);
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 16px;

  .header {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    .notice {
      font-size: 13px;
      line-height: 20px;
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 8px;

      .iconify {
        display: block;
        font-size: 20px;
        height: 20px;
        color: $color-danger;
      }
    }
    .mode-switcher {
      border: 1px solid $color-gray-400;
      border-radius: 6px;
      overflow: hidden;
      display: flex;
      flex-direction: row;

      .button {
        padding: 4px 6px;
        display: flex;
        flex-direction: row;
        gap: 4px;
        align-items: center;
        justify-content: center;
        font-size: 13px;
        line-height: 20px;
        color: $text-light;
        cursor: pointer;
        min-width: 102px;

        .iconify {
          font-size: 20px;
          display: block;
          height: 20px;
        }

        &.active {
          background-color: $color-primary-50;
          color: $color-primary-400;
        }

        &.mobile {
          border-left: 1px solid $color-gray-400;
        }
      }
    }
  }

  .mail-content {
    @include custom-scrollbar;
    border: 1px solid $color-gray-300;
    border-radius: 8px;
    padding: 12px;
    display: flex;
    flex-direction: column;
    margin: auto;
    max-height: 100%;
    width: 100%;
    overflow: auto;

    &.is-mobile {
      width: 375px;
    }

    .mail-subject {
      font-size: 18px;
      text-transform: uppercase;
      font-weight: 600;
      margin-left: 80px;
    }

    .content {
      max-height: 100%;
      overflow-y: auto;
      display: flex;
      flex-direction: row;
      gap: 16px;

      .avatar-col {
        .avatar {
          height: 64px;
          width: 64px;
          img {
            height: 64px;
            width: 64px;
          }
        }
      }
      .content-col {
        display: flex;
        flex-direction: column;
        gap: 8px;

        .title {
          display: flex;
          flex-direction: column;
          font-size: 18px;
          line-height: 20px;
          min-height: 64px;
          justify-content: center;
          font-weight: 600;
          color: $text-light;

          .company-name {
            font-size: 16px;
            font-weight: 500;
          }

          .mail-subject {
            margin-bottom: 12px;
            text-transform: uppercase;
          }

          .recipient {
            font-size: 13px;
            font-weight: 400;
          }
        }

        :deep(.detail-content) {
          font-size: 13px;
        }
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

    .submit-button {
      padding: 4px 14px 4px 14px;

      :deep(.button-text) {
        font-size: 14px;
      }
    }

    .submit-button {
      background-color: $color-primary-400;
      color: $text-dark;
    }
  }
}
</style>
