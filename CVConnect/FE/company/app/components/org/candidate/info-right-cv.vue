<template>
  <iframe
    class="cv-preview"
    :src="`${cvLink}`"
    width="100%"
    height="100%"
    style="border: none"
  />
</template>
<script setup lang="ts">
type TProps = {
  cvLink: string;
};

const props = defineProps<TProps>();
onBeforeMount(() => {
  console.log("cv link", props.cvLink);
});
</script>
