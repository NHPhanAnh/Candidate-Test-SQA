export const useIndustryApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getIndustriesPublic = async (
    params: any,
    abortController?: AbortController,
  ) => {
    try {
      const _abortController = abortController;
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/core/industry/public/filter?${queryString}`,
        {
          signal: _abortController ? _abortController.signal : undefined,
        },
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

  const getIndustriesSub = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/core/industry-sub/filter?${queryString}`,
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

  const getIndustries = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/core/industry/filter?${queryString}`,
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

  const getIndustryDetail = async (id: number) => {
    try {
      const res = await $axios.get(`/_api/core/industry/detail/${id}`);
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

  const createIndustry = async (payload: any) => {
    try {
      const res = await $axios.post(`/_api/core/industry/create`, payload);
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

  const updateIndustry = async (id: number, payload: any) => {
    try {
      const res = await $axios.put(`/_api/core/industry/update/${id}`, payload);
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

  const deleteIndustry = async (payload: any) => {
    try {
      const res = await $axios.delete(`/_api/core/industry/delete`, {
        data: payload.ids,
      });
      if (res.data.message) {
        toast.add({
          title: res.data.message,
          color: "success",
        });
      }
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
    getIndustriesPublic,
    getIndustries,
    getIndustriesSub,
    createIndustry,
    deleteIndustry,
    getIndustryDetail,
    updateIndustry,
  };
};
