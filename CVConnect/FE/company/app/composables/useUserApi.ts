export const useUserApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const getByRoleCode = async (
    roleCode: string,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const res = await $axios.get(
        `/_api/user/user/get-by-role-code-org/${roleCode}`,
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

  return {
    getByRoleCode
  };
};
