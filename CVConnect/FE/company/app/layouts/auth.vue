<template>
  <div class="main-layout">
    <div class="main-content">
      <slot />
    </div>
  </div>
</template>
<style lang="scss" scoped>
.main-layout {
  display: flex;
  min-height: 100vh;
  height: 100vh;
  background-color: $color-gray-100;

  .main-content {
    max-height: 100%;
    background-color: $color-gray-100;
    width: 100%;
    overflow-y: auto;
    overflow-x: hidden;
  }
}
</style>
