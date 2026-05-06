export const useApplyApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getCandidateInfoApply = async (controller?: AbortController) => {
    const _abortController = controller;

    try {
      const res = await $axios.get(
        `/_api/core/candidate-info-apply/filter`,
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

  const applyJob = async (payload: any) => {
    try {
      const res = await $axios.post(
        `/_api/core/job-ad-candidate/apply`,
        payload,
      );
      toast.add({
        title: res.data.message,
        color: "success",
      });
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
  }

  return {
    getCandidateInfoApply,
    applyJob,
  };
};
