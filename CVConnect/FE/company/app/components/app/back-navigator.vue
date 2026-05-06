<template>
  <div class="top">
    <div class="back-button" @click="handleGoBack">
      <Icon name="material-symbols:arrow-back-ios-new-rounded" />
    </div>
    <div class="title">{{ props.title }}</div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  title: string;
  fallbackRoute: string;
};

const props = defineProps<TProps>();
const router = useRouter();

const handleGoBack = () => {
  if (window.history.state?.back) {
    router.back();
  } else {
    router.push(props.fallbackRoute);
  }
};
</script>
<style lang="scss" scoped>
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
</style>
