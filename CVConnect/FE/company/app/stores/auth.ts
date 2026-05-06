import { defineStore } from "pinia";

export type TRole =
  | "CANDIDATE"
  | "SYSTEM_ADMIN"
  | "ORG_ADMIN"
  | "HR"
  | "INTERVIEWER";

export type TAccountRole = {
  id: number;
  code: TRole;
  name: string;
  memberType?: any;
  isDefault?: boolean;
};

export const useAuthStore = defineStore(
  "auth",
  () => {
    const token = ref<string | null>(null);
    const roles = ref<TAccountRole[]>([]);
    const currentRole = ref<TAccountRole | null | undefined>(undefined);

    const setToken = (_token: string) => {
      token.value = _token;
    };

    const setRoles = (_roles: TAccountRole[]) => {
      roles.value = _roles;
    };

    const setCurrentRole = (_role: TAccountRole | null) => {
      currentRole.value = _role;
      if (_role) {
        setLocalCurrentRole(_role);
      } else {
        clearLocalCurrentRole();
      }
    };

    const clearStore = () => {
      token.value = null;
      roles.value = [];
      currentRole.value = undefined;
    };

    const clearToken = () => {
      token.value = null;
      currentRole.value = null;
      roles.value = [];
    };

    return {
      token,
      roles,
      currentRole,
      setToken,
      clearToken,
      setRoles,
      setCurrentRole,
      clearStore,
    };
  },
  {
    persist: {
      storage: localStorage,
      omit: ["currentRole", "roles"],
    },
  },
);
