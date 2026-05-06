export const useLocationApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getAllLocations = async (
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(
        `/_api/core/org-address/get-all`,
        {
          signal: _abortController ? _abortController.signal : undefined,
        },
      );
      return res.data;
    } catch (err: any) {
      if (err.name === "AbortError") {
        return null;
      }

      if (err.response && err.response.data) {
        toast.add({
          title: err.response.data.message,
          color: "error",
        });
      }
      console.error(err);
      return null;
    }
  };

  return {
    getAllLocations,
  };
};
