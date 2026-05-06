export const useSearchHistoryApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getHistory = async (controller?: AbortController) => {
    const _abortController = controller;

    try {
      const res = await $axios.get(
        `/_api/core/search-history-outside/my-search-history`,
        {
          signal: _abortController ? _abortController.signal : undefined,
        },
      );
      // toast.add({
      //   title: res.data.message,
      //   color: "success",
      // });
      return res.data;
    } catch (err: any) {
      // if (err.response && err.response.data) {
      //   toast.add({
      //     title: err.response.data.message || "Có lỗi xảy ra",
      //     color: "error",
      //   });
      // }
      console.error(err);
      return null;
    }
  };

  const deleteHistory = async (id: any) => {
    try {
      const res = await $axios.delete(`/_api/core/search-history-outside/delete`, {
        data: [id]
      });
      return true;
    } catch (err: any) {
      console.error(err);
      return false;
    }
  }

  const deleteAllHistory = async () => {
    try {
      const res = await $axios.delete(`/_api/core/search-history-outside/delete-all`);
      return true;
    } catch (err: any) {
      console.error(err);
      return false;
    }
  }

  return {
    getHistory,
    deleteHistory,
    deleteAllHistory,
  };
};
