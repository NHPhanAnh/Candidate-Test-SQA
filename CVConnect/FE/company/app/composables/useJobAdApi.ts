export const useJobAdApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const createJobAd = async (payload: any) => {
    try {
      const res = await $axios.post(`/_api/core/job-ad/create`, payload);
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

  const getJobAdOrg = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;
    const queryString = objectToQuery(params);
    try {
      const res = await $axios.get(
        `/_api/core/job-ad/org/filter?${queryString}`,
        {
          signal: _abortController ? _abortController.signal : undefined,
        },
      );
      return res.data;
    } catch (err: any) {
      if (err.name === "AbortError") {
        return "aborted";
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

  const updateJobAdStatus = async (payload: any) => {
    try {
      const res = await $axios.put(
        `/_api/core/job-ad/update-status/${payload.jobAdId}`,
        payload,
      );
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

  const updateJobAdPublicity = async (payload: any) => {
    try {
      const res = await $axios.put(
        `/_api/core/job-ad/update-public/${payload.jobAdId}`,
        payload,
      );
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

  const updateJobAd = async (id: any, payload: any) => {
    try {
      const res = await $axios.put(
        `/_api/core/job-ad/update/${id}`,
        payload,
      );
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

  const getJobAdDetailOrg = async (id: any) => {
    try {
      const res = await $axios.get(`/_api/core/job-ad/org/detail/${id}`);
      return res.data;
    } catch (err: any) {
      if (err.name === "AbortError") {
        return "aborted";
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

  const getJobAdCandidateByProcess = async (
    jobAdProcessId: any,
    controller: AbortController | null,
    params: any,
  ) => {
    const _abortController = controller;
    const queryString = objectToQuery(params);
    try {
      const res = await $axios.get(
        `/_api/core/candidate-info-apply/filter-by-job-ad-process/${jobAdProcessId}?${queryString}`,
        {
          signal: _abortController ? _abortController.signal : undefined,
        },
      );
      return res.data;
    } catch (err: any) {
      if (err.name === "AbortError") {
        return "aborted";
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
    createJobAd,
    getJobAdOrg,
    updateJobAdStatus,
    updateJobAdPublicity,
    getJobAdDetailOrg,
    getJobAdCandidateByProcess,
    updateJobAd,
  };
};
