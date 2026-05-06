export const useCalendarApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getSchedulesGeneral = async (params: any) => {
    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/core/calendar/filter-view-general?${queryString}`,
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

  const getScheduleDetail = async (id: any, candidateInfoId: any) => {
    try {
      const res = await $axios.post(
        `/_api/core/calendar/detail-in-view-general`,
        {
          calendarId: id,
          candidateInfoId: candidateInfoId,
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

  return {
    getSchedulesGeneral,
    getScheduleDetail,
  };
};
