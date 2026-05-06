<template>
  <div class="org-admin-layout">
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

const permittedRole: TRole = "ORG_ADMIN";
const permissionType: TPermissionCheckType = PERMISSION_CHECK_TYPE.ROLE;

useLayoutPermission(permissionType, permittedRole);
</script>
<style lang="scss" scoped>
.org-admin-layout {
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
