<template>
  <div class="wrapper">
    <div class="content">
      <AppTabber
        :tabs="tabs"
        :current-tab-index="currentTabIndex"
        @tab-switch="handleTabSwitch($event)"
      />
      <div class="tab-content">
        <EmailTemplateList v-if="currentTabIndex == 1" />
        <EmailTemplateMailConfig v-if="currentTabIndex == 2" />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { TEMPLATE_TABS } from "~/const/views/org-admin/email-template";

definePageMeta({
  layout: "org-admin",
});

const route = useRoute();
const router = useRouter();

const currentTabIndex = ref<number>(0);
const lastUrl = ref<string>("");

onBeforeMount(() => {
  const query = route.query;
  console.log(query);
  const isConfig = query.isConfig as string;
  if (isConfig && isConfig == "1") {
    currentTabIndex.value = 2;
  } else {
    currentTabIndex.value = 1;
  }
});

const tabs = computed(() => {
  return TEMPLATE_TABS;
});

async function handleTabSwitch(index: number) {
  if (index === 2) {
    lastUrl.value = route.fullPath;
    router.replace({
      path: route.path,
      query: { isConfig: "1" },
    });
  } else {
    await router.replace(lastUrl.value);
    lastUrl.value = "";
  }

  currentTabIndex.value = index;
}
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

  :deep(.tabber) {
    margin-bottom: 12px;
    .tab {
      font-size: 14px;
    }
  }

  .tab-content {
    @include custom-scrollbar;
    flex: 1;
    min-height: 0;
    overflow-y: auto;
  }
}
</style>
