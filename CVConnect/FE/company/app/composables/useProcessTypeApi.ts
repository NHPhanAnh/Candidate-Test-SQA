import type { TProcessTypeItem } from "~/types/processType";

export const useProcessTypeApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getAll = async () => {
    try {
      const res = await $axios.get(`/_api/core/process-type/get-all`);
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

  const updateList = async (payload: TProcessTypeItem[]) => {
    try {
      const res = await $axios.post(`/_api/core/process-type/update`, payload);
      if (res.data.message) {
        toast.add({
          title: res.data.message,
          color: "success",
        });
      }
      return true
    } catch (err: any) {
      if (err.response && err.response.data) {
        toast.add({
          title: err.response.data.message,
          color: "error",
        });
      }
      console.error(err);
      return false;
    }
  };

  return { getAll, updateList };
};
