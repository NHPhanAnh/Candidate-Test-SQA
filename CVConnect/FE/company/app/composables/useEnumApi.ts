export const useEnumApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getJobTypes = async (abortController?: AbortController) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(`/_api/core/type/Job`, {
        signal: _abortController ? _abortController.signal : undefined,
      });
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

  const getSalaryType = async (abortController?: AbortController) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(`/_api/core/type/salary`, {
        signal: _abortController ? _abortController.signal : undefined,
      });
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

  const getCurrency = async (abortController?: AbortController) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(`/_api/core/type/currency`, {
        signal: _abortController ? _abortController.signal : undefined,
      });
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

  const getEliminateReason = async (abortController?: AbortController) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(`/_api/core/type/eliminate-reason`, {
        signal: _abortController ? _abortController.signal : undefined,
      });
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

  const getScheduleType = async (abortController?: AbortController) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(`/_api/core/type/calendar-type`, {
        signal: _abortController ? _abortController.signal : undefined,
      });
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

  const getJobAdStatus = async (abortController?: AbortController) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(`/_api/core/type/job-ad-status`, {
        signal: _abortController ? _abortController.signal : undefined,
      });
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
    getJobTypes,
    getCurrency,
    getSalaryType,
    getEliminateReason,
    getScheduleType,
    getJobAdStatus,
  };
};
