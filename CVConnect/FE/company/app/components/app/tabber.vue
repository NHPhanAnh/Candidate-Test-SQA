<template>
  <div class="tabber">
    <div
      v-for="(tab, index) of props.tabs"
      :key="index"
      class="tab"
      :class="{ active: currentTabIndex === index + 1 }"
      @click="handleTabSwitch(index + 1)"
    >
      {{ tab.label }}
    </div>
  </div>
</template>
<script setup lang="ts">
export type TTabberUnit = {
  label: string;
  index: number;
};
type TProps = {
  tabs: TTabberUnit[];
  currentTabIndex: number;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "tabSwitch", index: number): void;
}>();

const handleTabSwitch = (index: number) => {
  if (index === props.currentTabIndex) {
    return;
  }

  emits("tabSwitch", index);
};
</script>
<style lang="scss" scoped>
.tabber {
  width: 100%;
  border-bottom: 2px solid $color-gray-300;
  display: flex;
  flex-direction: row;

  .tab {
    font-size: 13px;
    font-weight: 500;
    color: $color-gray-500;
    padding: 4px 12px;
    cursor: pointer;
    transition-duration: 200ms;
    border-bottom: 2px solid $color-gray-300;
    margin-bottom: -2px;

    &:hover {
      color: $color-primary-400;
    }

    &.active {
      border-bottom: 2px solid $color-primary-400;
      color: $color-primary-400;
    }
  }
}
</style>
