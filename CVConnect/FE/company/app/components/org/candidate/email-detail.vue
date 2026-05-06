<template>
  <div class="email-detail">
    <div class="wrapper" @click="() => (isExpanded = !isExpanded)">
      <div class="subject">{{ props.emailInfo.subject }}</div>
      <div class="right">
        <AppButton
          v-if="mailStatus === 'FAILURE'"
          :text="'Gửi lại'"
          class="resend-button"
          :is-loading="isSubmitting"
          @click="resendMail"
        />
        <div class="send-at">
          {{ formatDateTime(props.emailInfo.sentAt, "DD/MM/YYYY - HH:mm") }}
        </div>
        <div
          class="status chip"
          :style="{
            borderColor: EMAIL_LOG_STATUS[mailStatus].color,
            color: EMAIL_LOG_STATUS[mailStatus].color,
            backgroundColor: EMAIL_LOG_STATUS[mailStatus].background,
          }"
        >
          {{ EMAIL_LOG_STATUS[mailStatus].label }}
        </div>
      </div>
    </div>
    <div v-show="isExpanded" class="content">
      <div class="avatar-col">
        <div class="avatar">
          <img src="/blankuser.jpg" />
        </div>
      </div>
      <div class="content-col">
        <div class="title">
          <div class="company-name">
            {{ props.emailInfo.sender }}
          </div>
          <div class="recipient">
            {{ `Đến: ${props.emailInfo.recipients}` }}
          </div>
        </div>
        <div class="detail-content" v-html="props.emailInfo.body || ''"></div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { EMAIL_LOG_STATUS } from "~/const/views/org/candidates";

type TProps = {
  emailInfo: any;
};

const { resendEmail } = useCandidateApi();

const props = defineProps<TProps>();

const isExpanded = ref<boolean>(false);
const localStatus = ref<any>(null);
const isSubmitting = ref<boolean>(false);

const mailStatus = computed(() => {
  if (localStatus.value) {
    return localStatus.value;
  }

  return props.emailInfo.status;
});

async function resendMail() {
  isSubmitting.value = true;
  const res = await resendEmail(props.emailInfo.id);
  isSubmitting.value = false;
  if (res) {
    localStatus.value = "SENDING";
  }
}
</script>
<style lang="scss" scoped>
.email-detail {
  font-size: 14px;
  display: flex;
  flex-direction: column;
  border: 1px solid $color-gray-300;
  border-radius: 6px;
  overflow: hidden;
  min-height: fit-content;

  .wrapper {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    flex-wrap: wrap;
    padding: 8px;
    cursor: pointer;

    .resend-button {
      padding: 7px 12px;
      font-size: 14px;
      line-height: 20px;
      background-color: $color-primary-500;
      color: $text-dark;
    }

    .subject {
      font-weight: 600;
    }

    .right {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 8px;

      .chip {
        border-radius: 4px;
        padding: 4px;
        font-size: 12px;
        border: 1px solid $color-gray-300;
        font-weight: 500;
      }
    }
  }

  .content {
    border-top: 1px solid $color-gray-300;
    max-height: 450px;
    overflow: auto;
    display: flex;
    flex-direction: row;
    gap: 16px;
    padding: 12px;

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
</style>
