<template>
  <div class="avatar">
    <img v-if="props.userInfo.avatarUrl" :src="props.userInfo.avatarUrl" />
    <div
      v-else
      class="monogram"
      :style="{ backgroundColor: getMonogramColor(props.userInfo.id) }"
    >
      {{ getMonogramText(props.userInfo.fullName) }}
    </div>
  </div>
</template>
<script setup lang="ts">
type TProps = {
  userInfo: {
    fullName: string;
    id: number;
    avatarUrl: string;
  };
};

const props = defineProps<TProps>();
</script>
<style lang="scss" scoped>
.avatar {
  height: 36px;
  width: 36px;
  border-radius: 999px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .monogram {
    width: 100%;
    height: 100%;
    color: $text-dark;
    font-size: 16px;
    font-weight: 600;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}
</style>
