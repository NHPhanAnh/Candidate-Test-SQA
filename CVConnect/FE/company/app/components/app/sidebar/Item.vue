<template>
  <div
    class="item"
    :title="
      !props.isSidebarExpanded && props.isFirstLevel ? props.item.menuLabel : ''
    "
    :class="{ expanded: props.item.isExpanded }"
  >
    <NuxtLink v-if="props.item.menuUrl" class="name" :to="props.item.menuUrl">
      <div class="item-icon">
        <Icon v-if="props.item.menuIcon" :name="props.item.menuIcon" />
      </div>
      <div v-if="isSidebarExpanded" class="item-name">
        {{ props.item.menuLabel }}
      </div>
    </NuxtLink>
    <div
      v-else
      class="name"
      :class="{ 'child-active': hasChildActive }"
      @click="
        handleExpand({ id: props.item.id, state: !props.item.isExpanded })
      "
    >
      <div class="item-icon">
        <Icon v-if="props.item.menuIcon" :name="props.item.menuIcon" />
      </div>
      <div v-if="isSidebarExpanded" class="item-name">
        {{ props.item.menuLabel }}
      </div>
      <div v-if="isSidebarExpanded" class="item-expand-icon">
        <Icon
          v-if="!isFloat"
          :name="props.item.isExpanded ? 'mdi:chevron-up' : 'mdi:chevron-down'"
        />
        <Icon v-else name="mdi:chevron-right" />
      </div>
    </div>
    <div
      v-show="props.item.isExpanded"
      v-if="isSidebarExpanded && props.item.children?.length"
      class="children"
    >
      <AppSidebarItem
        v-for="(menu, index) in props.item.children"
        :key="index"
        :item="menu"
        :is-sidebar-expanded="props.isSidebarExpanded"
        @expand="handleExpand"
      />
    </div>
    <div
      v-if="
        (!isSidebarExpanded || props.isFloat) && props.item.children?.length
      "
      class="float-children"
      :class="{ 'first-level': props.isFirstLevel }"
    >
      <div class="bridge"></div>
      <div class="child-wrapper">
        <AppSidebarItem
          v-for="(menu, index) in props.item.children"
          :key="index"
          :item="menu"
          :is-sidebar-expanded="true"
          :is-float="true"
          :is-first-level="false"
        />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import type { TSidebarItem } from "~/stores/sidebar";

type TProps = {
  item: TSidebarItem;
  isSidebarExpanded: boolean;
  isFloat?: boolean;
  isFirstLevel?: boolean;
};

export type TSidebarItemExpandPayload = {
  id: number;
  state: boolean;
};

const props = withDefaults(defineProps<TProps>(), {
  isFloat: false,
  isFirstLevel: false,
});
const emit = defineEmits<{
  (e: "expand", payload: TSidebarItemExpandPayload): void;
}>();

const handleExpand = (payload: TSidebarItemExpandPayload) => {
  emit("expand", { id: payload.id, state: payload.state });
};

const route = useRoute();
const hasActiveChild = (children?: TSidebarItem[]): boolean => {
  if (!children) return false;

  return children.some((child) => {
    if (child.menuUrl && route.path === child.menuUrl) {
      return true;
    }
    return hasActiveChild(child.children);
  });
};
const hasChildActive = computed(() => hasActiveChild(props.item.children));
</script>
<style lang="scss" scoped>
.item {
  font-size: 14px;
  line-height: 20px;
  border-radius: 8px;
  position: relative;

  &:hover > .float-children,
  > .float-children:hover {
    display: flex;
  }

  .float-children {
    display: none;
    flex-direction: row;
    background-color: transparent;
    position: fixed;
    z-index: 4;
    margin-left: 216px;
    margin-top: -40px;

    .bridge {
      display: block;
      background-color: transparent;
      width: 8px;
    }
    .child-wrapper {
      display: block;
      padding: 4px;
      background-color: white;
      border-radius: 12px;
      @include box-shadow;
      width: 224px;
    }

    &.first-level {
      margin-left: 36px;
      margin-top: -38px;

      > .bridge {
        width: 12px;
      }
    }
  }

  .name {
    padding: 8px;
    cursor: pointer;
    border-radius: 8px;
    display: flex;
    flex-direction: row;
    gap: 12px;
    align-items: center;
    justify-content: center;
    text-decoration: none;
    color: $text-light;
    font-weight: 600;
    transition: background-color 200ms;
    &.child-active {
      background-color: rgba($color-primary-50, 0.5);
      color: $color-primary-400;
    }

    .item-icon,
    .item-name,
    .item-expand-icon {
      display: flex;
      align-items: center;
    }

    .item-icon {
      font-size: 20px;
    }

    .item-name {
      flex: 1;
    }

    &:hover,
    &.router-link-exact-active {
      background-color: rgba($color-primary-100, 0.6);
      color: $color-primary-400;
      font-weight: 600;
    }
  }

  .children {
    margin-top: 4px;
    padding-left: 12px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
}
</style>
