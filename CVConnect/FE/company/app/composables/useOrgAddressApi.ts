export const useOrgAddressApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getOrgAddresses = async () => {
    try {
      const res = await $axios.get(
        `/_api/core/org-address/get-all`,
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

  const updateOrgAddresses = async (payload: any) => {
    try {
      const res = await $axios.post(`/_api/core/org-address/save`, payload);
      toast.add({
        title: res.data.message,
        color: "success",
      });
      return true;
    } catch (err: any) {
      if (err.response && err.response.data) {
        toast.add({
          title: err.response.data.message || "Có lỗi xảy ra",
          color: "error",
        });
      }
      console.error(err);
      return false;
    }
  };

  return {
    getOrgAddresses,
    updateOrgAddresses,
  };
};
