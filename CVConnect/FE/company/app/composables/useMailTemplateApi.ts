export const useMailTemplateApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getMailTemplates = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/notify/email-template/filter?${queryString}`,
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

  const getMailTemplatePreviewDefault = async (
    id: number,
    body: Record<string, any>,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const res = await $axios.post(
        `/_api/notify/email-template/preview-email/${id}`,
        {
          ...body,
        },
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

  const getMailTemplatePreviewNoTemplate = async (
    subject: string,
    body: string,
    placeholderCodes: string[],
    dataReplacePlaceholder: Record<string, any>,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const res = await $axios.post(
        `/_api/notify/email-template/preview-email-without-template`,
        {
          subject,
          body,
          placeholderCodes,
          dataReplacePlaceholder,
        },
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

  const getMailTemplateDetail = async (
    id: number,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(`/_api/notify/email-template/detail/${id}`, {
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

  const getMailTemplateConfig = async (abortController?: AbortController) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(`/_api/notify/email-config/get-by-org`, {
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

  const changeMailTemplateStatus = async (payload: any) => {
    try {
      const res = await $axios.put(
        `/_api/notify/email-template/change-status-active`,
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

  const deleteMailTemplate = async (payload: any) => {
    try {
      const res = await $axios.delete(`/_api/notify/email-template/delete`, {
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

  const deleteMailTemplateConfig = async () => {
    try {
      const res = await $axios.delete(`/_api/notify/email-config/delete`);
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

  const getPlaceholders = async () => {
    try {
      const res = await $axios.get(`/_api/notify/placeholder/filter`);
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

  const createMailTemplate = async (payload: any) => {
    try {
      const res = await $axios.post(
        `/_api/notify/email-template/create`,
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

  const createMailTemplateWithId = async (payload: any) => {
    try {
      const res = await $axios.post(
        `/_api/notify/email-template/create`,
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
      return false;
    }
  };

  const createMailTemplateConfig = async (payload: any) => {
    try {
      const res = await $axios.post(
        `/_api/notify/email-config/create`,
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

  const updateMailTemplate = async (id: number, payload: any) => {
    try {
      const res = await $axios.put(
        `/_api/notify/email-template/update/${id}`,
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

  const updateMailTemplateConfig = async (payload: any) => {
    try {
      const res = await $axios.put(`/_api/notify/email-config/update`, payload);
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
    getMailTemplates,
    getMailTemplatePreviewDefault,
    getMailTemplateDetail,
    getMailTemplateConfig,
    changeMailTemplateStatus,
    deleteMailTemplate,
    getPlaceholders,
    createMailTemplate,
    updateMailTemplate,
    createMailTemplateConfig,
    updateMailTemplateConfig,
    deleteMailTemplateConfig,
    createMailTemplateWithId,
    getMailTemplatePreviewNoTemplate,
  };
};
