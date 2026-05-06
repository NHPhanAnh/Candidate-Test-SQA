<template>
  <div class="invite-join-org">
    <img src="/logo-horizontal.svg" class="logo" />
    <div class="icon-wrapper" :class="[statusClass]">
      <Icon :name="outerRingIcon" class="outer-ring" />
      <Icon :name="iconName" class="inner-ring" />
    </div>
    <div class="message" :class="[statusClass]">{{ message }}</div>
    <div class="desc-message">
      {{ descMessage }}
      <div v-if="status === 'success'">
        {{ `Bạn sẽ được chuyển về trang đăng nhập trong ${counter} giây.` }}
      </div>
      <NuxtLink v-if="status === 'success'" to="/auth/login" class="to-login"
        >Đến trang đăng nhập</NuxtLink
      >
    </div>
    <footer class="site-footer">
      <div class="footer-content">
        <h2>CVConnect</h2>
        <p>Connecting candidates & recruiters</p>
        <small>© 2025 CVConnect. All rights reserved.</small>
      </div>
    </footer>
  </div>
</template>
<script setup lang="ts">
definePageMeta({ layout: false });
type TStatus = "pending" | "success" | "error";
const status = ref<TStatus>("pending");
const tempStatus = ref<TStatus>("pending");
const counter = ref(5);
const stage = ref(0);
const redirectInterval = ref<number | null>(null);
const minimumTimeout = ref<number | null>(null);
const route = useRoute();
const router = useRouter();
const { replyInvitation } = useOrgMemberApi();

onMounted(async () => {
  const token = route.query.token;
  const action = route.query.action;
  if (!token || !action) {
    tempStatus.value = "error";
    stage.value = 2;
    return;
  }
  // call api verify

  minimumTimeout.value = window.setTimeout(() => {
    stage.value += 1;
  }, 2000);
  const res = await replyInvitation(token as string, action as string);
  stage.value += 1;

  console.log('response?', res)

  if (res) {
    tempStatus.value = "success";
  } else {
    tempStatus.value = "error";
  }
});

onBeforeUnmount(() => {
  if (redirectInterval.value != null) {
    clearInterval(redirectInterval.value);
  }

  if (minimumTimeout.value != null) {
    clearTimeout(minimumTimeout.value);
  }
});

watch(stage, (newVal) => {
  if (newVal == 2) {
    status.value = tempStatus.value;
    if (tempStatus.value === "success") {
      counter.value = 2;
      redirectInterval.value = window.setInterval(() => {
        counter.value -= 1;
      }, 1000);
    }
  }
});

watch(counter, (newVal) => {
  if (newVal == 0 && redirectInterval.value != null) {
    clearInterval(redirectInterval.value);
    router.push({ path: "/auth/login" });
  }
});

const iconName = computed(() => {
  const iconMap: Record<TStatus, string> = {
    pending: "mdi:email-sync",
    success: "mdi:email-check",
    error: "mdi:email-remove",
  };
  const icon = iconMap[status.value];
  return icon;
});
const outerRingIcon = computed(() => {
  const icon =
    status.value === "pending" ? "svg-spinners:pulse" : "icon-park-solid:round";
  return icon;
});
const message = computed(() => {
  const action = route.query.action as string;
  const messageMap: Record<TStatus, string> = {
    pending: action == "a" ? "Tham gia doanh nghiệp" : "Từ chối lời mời",
    success:
      action == "a"
        ? "Bạn đã chấp nhận lời mời từ doanh nghiệp"
        : "Bạn đã từ chối lời mời từ doanh nghiệp",
    error: "Có lỗi xảy ra",
  };
  const message = messageMap[status.value];
  return message;
});
const descMessage = computed(() => {
  const action = route.query.action as string;
  const messageMap: Record<TStatus, string> = {
    pending: "Hệ thống đang xử lí yêu cầu của bạn, vui lòng đợi...",
    success:
      action == "a"
        ? "Bạn đã được thêm vào doanh nghiệp"
        : "Yêu cầu từ chối lời mời vào doanh nghiệp của bạn đã được xử lí",
    error:
      "Có lỗi xảy ra trong quá trình xử lí yêu cầu, vui lòng kiểm tra kĩ lại email",
  };
  const message = messageMap[status.value];
  return message;
});
const statusClass = computed(() => {
  return status.value;
});
</script>
<style lang="scss" scoped>
.invite-join-org {
  height: 100vh;
  width: 100vw;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 104px;

  .logo {
    height: 72px;
    margin-bottom: 32px;
  }

  .icon-wrapper {
    height: 72px;
    width: 72px;
    aspect-ratio: 1/1;
    border-radius: 999px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 20px;
    color: white;
    position: relative;

    &.pending {
      background-color: $color-warning;
      .outer-ring {
        color: rgba($color-warning, 1);
        font-size: 108px;
      }
    }
    &.success {
      background-color: $color-success;
      .outer-ring {
        color: rgba($color-success, 0.3);
      }
    }
    &.error {
      background-color: $color-danger;
      .outer-ring {
        color: rgba($color-danger, 0.3);
      }
      .inner-ring {
        margin-left: 3px;
      }
    }

    .outer-ring {
      position: absolute;
      font-size: 96px;
    }
    .inner-ring {
      font-size: 36px;
      margin-left: 4px;
    }
  }
  .message {
    font-size: 20px;
    font-weight: 600;
    margin-bottom: 12px;

    &.pending {
      color: $color-warning;
    }
    &.success {
      color: $color-success;
    }
    &.error {
      color: $color-danger;
    }
  }
  .desc-message {
    font-size: 14px;
    color: $text-light;
    white-space: pre-line;
    text-align: center;
    flex: 1;

    .to-login {
      margin-top: 12px;
      color: $color-success;
      font-size: 14px;
      display: block;
    }
  }
  .site-footer {
    background: #1a1a1a;
    color: #ccc;
    padding: 2rem 1rem;
    margin-top: 4rem;
    text-align: center;
    width: 100%;

    h2 {
      color: #fff;
      margin: 0 0 0.25rem;
      font-size: 1.25rem;
    }

    p {
      margin: 0 0 1rem;
      font-size: 0.9rem;
    }

    small {
      font-size: 0.75rem;
      color: #777;
    }
  }
}
</style>
