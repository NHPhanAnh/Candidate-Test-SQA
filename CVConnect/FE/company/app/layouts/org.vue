<template>
  <div class="org-layout">
    <AppSidebar />
    <div class="main-content">
      <AppHeader />
      <slot />
    </div>
  </div>
</template>
<script setup lang="ts">
import { PERMISSION_CHECK_TYPE } from "~/const/permission";
import type { TPermissionCheckType } from "~/types/permision";

const permittedRole: string = "ORGANIZATION";
const permissionType: TPermissionCheckType = PERMISSION_CHECK_TYPE.MEMBER_TYPE;

useLayoutPermission(permissionType, permittedRole);
</script>
<style lang="scss" scoped>
.org-layout {
  display: flex;
  min-height: 100vh;
  height: 100vh;
  background-color: $color-gray-100;

  .main-content {
    max-height: 100%;
    display: flex;
    flex-direction: column;
    overflow-x: hidden;
    padding: 16px 16px 16px 8px;
    flex: 1;
  }
}
</style>
