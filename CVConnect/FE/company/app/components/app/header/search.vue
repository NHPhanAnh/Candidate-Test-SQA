<template>
  <div class="wrapper">
    <div class="search" @click="handleSearchClick">
      <Icon class="icon" name="mdi:magnify" />
      <input ref="input" placeholder="Tìm kiếm" />
    </div>
  </div>
</template>
<script setup lang="ts">
const inputRef = useTemplateRef("input");

const handleSearchClick = () => {
  if (inputRef.value) {
    inputRef.value.focus();
  }
};
</script>
<style lang="scss" scoped>
.wrapper {
  .search {
    cursor: pointer;
    display: flex;
    gap: 8px;
    flex-direction: row;
    align-items: center;
    padding: 6px 12px;
    border-radius: 999px;
    box-shadow: rgba(0, 0, 0, 0.24) 0px 3px 8px;
    transition: border 200ms;
    background-color: white;

    &:focus-within {
      border: 1px solid $color-gray-400;
    }

    input {
      flex: 1;
      outline: none;
      font-size: 13px;
      line-height: 20px;

      color: $text-light;

      &::placeholder {
        color: $color-gray-400;
      }
    }

    .icon {
      display: block;
      color: $color-gray-400;
      font-size: 20px;
    }
  }
}
</style>
