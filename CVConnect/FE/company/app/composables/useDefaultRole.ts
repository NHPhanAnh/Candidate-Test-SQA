import { PERMISSION_CHECK_TYPE } from "~/const/permission";

export const useDefaultRole = () => {
  const authStore = useAuthStore();
  const { currentRole, roles } = storeToRefs(authStore);
  const { setCurrentRole, setRoles } = authStore;
  const { getMyRoles } = useRoleApi();
  const { getMe, verifyToken, getMenus } = useAuth();
  const { setUser } = useUserStore();
  const sidebarStore = useSidebarStore();
  const { setMenus } = sidebarStore;
  const { sidebarData } = storeToRefs(sidebarStore);
  const router = useRouter();

  /**
   * Ensure a currentRole is selected or redirect via role-select.
   * Called once per layout mount, accepts the current route path.
   */
  function handleRoleValidation(path: string) {
    if (currentRole.value) return;

    if (roles.value.length === 0) {
      router.push({ name: "auth-login", query: { redirect: path } });
      return;
    }

    // Try local storage preference first
    const localRole = getLocalCurrentRole();
    if (localRole) {
      setCurrentRole(localRole);
      return;
    }

    // Then default flag
    const defaultRole = roles.value.find((r) => r.isDefault);
    if (defaultRole) {
      setCurrentRole(defaultRole);
      return;
    }

    // Single role → auto-select
    if (roles.value.length === 1 && roles.value[0]) {
      setCurrentRole(roles.value[0]);
      return;
    }

    // Multiple roles with no preference → let user pick
    router.push({ path: "/role-select", query: { redirect: path } });
  }

  /**
   * Redirect away if the current role does not match the permitted role code.
   */
  async function checkPermission(permittedRole: TRole) {
    if (!currentRole.value) return;

    if (currentRole.value.code !== permittedRole) {
      const route = getDefaultRoute(currentRole.value);
      if (route) {
        router.push({ path: route });
      }
    }
  }

  return { handleRoleValidation, checkPermission };
};
