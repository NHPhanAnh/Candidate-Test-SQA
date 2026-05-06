<template>
  <div class="wrapper">
    <div class="content">
      <div class="title">Cấu hình mail service</div>
      <div class="tab-content">
        <EmailTemplateMailConfig @on-update="handleUpdateMailConfig" />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import {
  BROADCAST_CHANNEL,
  BROADCAST_MESSAGE_TYPE,
} from "~/const/views/org-admin/email-template";

definePageMeta({
  layout: "org-admin",
});

const broadcastChannel = ref<BroadcastChannel | null>(null);

onBeforeMount(() => {
  broadcastChannel.value = new BroadcastChannel(BROADCAST_CHANNEL.MAIL_CONFIG);
});

function handleUpdateMailConfig() {
  console.log('send message')
  broadcastChannel.value?.postMessage({
    type: BROADCAST_MESSAGE_TYPE.MAIL_CONFIG_UPDATE,
  });
}

onBeforeUnmount(() => {
  broadcastChannel.value?.close();
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
}
.content {
  background-color: white;
  min-height: calc(100% - 48px - 8px);
  @include box-shadow;
  color: $text-light;
  padding: 20px;
  display: flex;
  flex-direction: column;
  height: 100%;

  .title {
    font-weight: 700;
    font-size: 16px;
    line-height: 20px;
    margin-bottom: 12px;
  }

  .tab-content {
    @include custom-scrollbar;
    flex: 1;
    min-height: 0;
    overflow-y: auto;
  }
}
</style>
