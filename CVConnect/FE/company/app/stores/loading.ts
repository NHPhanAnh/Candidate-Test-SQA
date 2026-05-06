export const useLoadingStore = defineStore("loading", () => {
  const isLoading = ref<boolean>(false);

  const setLoading = (state: boolean) => {
    isLoading.value = state;
  };

  return {
    isLoading,
    setLoading,
  };
});
