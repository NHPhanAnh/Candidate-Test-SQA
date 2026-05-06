export const useOrgApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getOrgInfo = async (
  ) => {
    try {

      const res = await $axios.get(`/_api/core/org/org-info`);
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

  const getOrgInfoPublic = async (id: any) => {
    try {
      const res = await $axios.get(`/_api/core/org/outside/org-info/${id}`);
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
  }

  const updateLogo = async (payload: any) => {
    try {
      const res = await $axios.put(`/_api/core/org/update-logo`, payload);
      // toast.add({
      //   title: res.data.message,
      //   color: "success",
      // });
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

  const updateCover = async (payload: any) => {
    try {
      const res = await $axios.put(`/_api/core/org/update-cover-photo`, payload);
      // toast.add({
      //   title: res.data.message,
      //   color: "success",
      // });
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

  const updateInfo = async (payload: any) => {
    try {
      const res = await $axios.put(`/_api/core/org/update-info`, payload);
      // toast.add({
      //   title: res.data.message,
      //   color: "success",
      // });
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
    getOrgInfo,
    updateLogo,
    updateCover,
    updateInfo,
    getOrgInfoPublic,
  };
};
