export const useOrgMemberApi = () => {
  const { $axios } = useNuxtApp();
  const toast = useToast();

  const replyInvitation = async (token: string, action: string) => {
    try {
      const res = await $axios.post(
        "_api/user/org-member/reply-invite-join-org",
        {
          token,
          status: action == "a" ? "ACCEPTED" : "REJECTED",
        },
      );
      return res;
    } catch (err) {
      console.error(err);
      return null;
    }
  };

  const getOrgMembers = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/user/org-member/filter?${queryString}`,
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

  const getRoleFilterOption = async () => {
    try {
      const res = await $axios.get(
        `/_api/user/role/get-member-type-organization`,
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

  const getOrgMemberDetail = async (id: number) => {
    try {
      const res = await $axios.get(
        `/_api/user/org-member/org-member-info/${id}`,
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

  const inviteToOrg = async (payload: any) => {
    try {
      const res = await $axios.post(
        `/_api/user/org-member/invite-join-org`,
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

  const changeOrgMemberStatus = async (payload: any) => {
    try {
      const res = await $axios.put(
        `/_api/user/org-member/change-status-active`,
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

  const assignRole = async (payload: any) => {
    try {
      const res = await $axios.put(
        `/_api/user/org-member/assign-role`,
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

  const deleteDepartment = async (payload: any) => {
    try {
      const res = await $axios.delete(`/_api/core/department/delete`, {
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

  const findNotOrgMembers = async (
    params: any,
    abortController?: AbortController,
  ) => {
    const _abortController = abortController;

    try {
      const queryString = objectToQuery(params);
      const res = await $axios.get(
        `/_api/user/user/find-not-org-member?${queryString}`,
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
    getOrgMembers,
    inviteToOrg,
    deleteDepartment,
    getOrgMemberDetail,
    assignRole,
    changeOrgMemberStatus,
    getRoleFilterOption,
    findNotOrgMembers,
    replyInvitation,
  };
};
