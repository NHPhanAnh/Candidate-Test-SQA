<template>
  <div class="left">
    <OrgCandidateInfoLeftJobAd
      :job-ad-infos="props.detail.jobAdCandidates"
      :candidate-info="props.detail.candidateInfo"
      @refetch="emits('refetch')"
    />
    <OrgCandidateInfoLeftPersonalInfo :info="props.detail.candidateInfo" />
  </div>
</template>
<script setup lang="ts">
type TProps = {
  detail: Record<string, any>;
};

const props = defineProps<TProps>();
const emits = defineEmits<{
  (e: "refetch"): void;
}>();
</script>
<style lang="scss" scoped>
.left {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
</style>
