export type TUserDetail = {
  detailInfo: {
    id: number;
    userId: number;
  };
  roles: TAccountRole;
};

export type TUser = Record<string, any>;

export const useUserStore = defineStore("user", () => {
  const userInfo = ref<TUser | null>(null);

  const setUser = (user: TUser) => {
    userInfo.value = user;
  };

  const clearUser = () => {
    userInfo.value = null;
  };

  return { userInfo, setUser, clearUser };
});
