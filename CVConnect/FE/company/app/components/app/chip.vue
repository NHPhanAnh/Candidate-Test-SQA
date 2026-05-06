<template>
  <div class="chip" :class="[props.type]">
    {{ props.text }}
  </div>
</template>
<script setup lang="ts">
import type { TChipType } from "~/types/common";

type TProps = {
  text: string;
  type: TChipType;
};

const props = defineProps<TProps>();
</script>
<style lang="scss" scoped>
.chip {
  padding: 4px 8px;
  border: 1px solid black;
  font-size: 12px;
  font-weight: 400;
  display: flex;
  justify-content: center;
  align-items: center;
  width: fit-content;
  border-radius: 999px;
  background-color: white;
  display: inline-block;

  &.success {
    color: $color-success;
    border-color: $color-success;
    background-color: rgba($color-success, 0.1);
  }
  &.error {
    color: $color-danger;
    border-color: $color-danger;
    background-color: rgba($color-danger, 0.1);
  }
}
</style>
