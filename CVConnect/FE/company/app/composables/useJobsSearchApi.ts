export const useJobsSearchApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getFilter = async () => {
    try {
      const res = await $axios.get(`/_api/core/job-ad/outside/data-filter`);
      // toast.add({
      //   title: res.data.message,
      //   color: "success",
      // });
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data) {
        toast.add({
          title: err.response.data.message || "Có lỗi xảy ra",
          color: "error",
        });
      }
      console.error(err);
      return null;
    }
  };

  const getJobAds = async (params: any, abortController?: AbortController) => {
    const _abortController = abortController;

    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/core/job-ad/outside/filter?${queryString}`,
        {
          signal: _abortController ? _abortController.signal : undefined,
          // skipAuth: true,
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

  const getFeaturedJobAds = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/core/job-ad/outside/filter-featured?${queryString}`,
        {
          signal: _abortController ? _abortController.signal : undefined,
          skipAuth: true,
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

  const getRecommendedJobAds = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/core/job-ad/outside/filter-suitable?${queryString}`,
        {
          signal: _abortController ? _abortController.signal : undefined,
          // skipAuth: true,
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

  const getFeaturedOrgs = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/core/org/outside/org-featured?${queryString}`,
        {
          signal: _abortController ? _abortController.signal : undefined,
          skipAuth: true,
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

  const getJobAdPreview = async (
    id: any,
    keyCodeInternal: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      let url = `/_api/core/job-ad/outside/detail/${id}`;
      if (keyCodeInternal) {
        url += `?keyCodeInternal=${keyCodeInternal}`;
      }
      const res = await $axios.get(url, {
        signal: _abortController ? _abortController.signal : undefined,
        skipAuth: true,
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

  const getRelevantJobAds = async (jobAdId: any) => {
    try {
      const res = await $axios.get(
        `/_api/core/job-ad/outside/relate/${jobAdId}`,
        {
          skipAuth: true,
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
    getFilter,
    getJobAds,
    getFeaturedJobAds,
    getRecommendedJobAds,
    getFeaturedOrgs,
    getJobAdPreview,
    getRelevantJobAds,
  };
};
