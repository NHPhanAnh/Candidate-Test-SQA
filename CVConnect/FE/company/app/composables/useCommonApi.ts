export const useCommonApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getIndustry = async (pageSize: number = 10, pageIndex: number = 0) => {
    try {
      const res = await $axios.get(
        `/_api/core/industry/public/filter?pageSize=${pageSize}&pageIndex=${pageIndex}`,
        { skipAuth: true },
      );
      return res.data;
    } catch (err: any) {
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
    getIndustry,
  };
};
