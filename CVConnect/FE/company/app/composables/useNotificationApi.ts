export const useNotificationApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getMyNotification = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;
    try {

      const queryString = objectToQuery(params);
      const res = await $axios.get(`/_api/notify/notification/my-notifications?${queryString}`, {
        signal: _abortController ? _abortController.signal : undefined,
      });
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

  const getUnreadQuantity = async () => {
    try {
      const res = await $axios.get(`/_api/notify/notification/quantity-unread`);
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

  const markAllRead = async () => {
    try {
      const res = await $axios.put(`/_api/notify/notification/mark-all-as-read`);
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

  const markRead = async (id: string) => {
    try {
      const res = await $axios.put(`/_api/notify/notification/mark-as-read/${id}`);
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

  return {
    getMyNotification,
    getUnreadQuantity,
    markRead,
    markAllRead,
  };
};
