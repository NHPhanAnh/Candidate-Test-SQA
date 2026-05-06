import { defineStore } from "pinia";

export const useCandidateDetailStore = defineStore("candidateDetail", () => {
  const selectedJobAds = ref<any[]>([]);

  function toggleSelectedJobAds(jobAd: any) {
    const existingAd = selectedJobAds.value.find((ad) => ad.id == jobAd.id);
  }

});
