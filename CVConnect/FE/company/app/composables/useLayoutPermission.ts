import { onBeforeMount } from "vue";
import { storeToRefs } from "pinia";
import type { TPermissionCheckType } from "~/types/permision";
import { STATUS_CODE } from "~/const/api";

export function useLayoutPermission(
  permissionType: TPermissionCheckType,
  permittedRole: TRole | string,
) {
  const { setLoading } = useLoadingStore();
  const { verifyToken, logout, getMe, getMenus } = useAuth();
  const authStore = useAuthStore();
  const { currentRole, roles } = storeToRefs(authStore);
  const { setRoles } = authStore;
  const { getMyRoles } = useRoleApi();
  const { handleSetRole, checkPermission } = usePermission();
  const userStore = useUserStore();
  const { userInfo } = storeToRefs(userStore);
  const { setUser } = userStore;
  const sidebarStore = useSidebarStore();
  const { setMenus } = sidebarStore;
  const { sidebarData } = storeToRefs(sidebarStore);

  const init = async () => {
    setLoading(true);

    const verifyTokenRes = await verifyToken();
    if (
      !verifyTokenRes.data.isValid &&
      verifyTokenRes.data.code != STATUS_CODE.TOKEN_EXPIRED
    ) {
      await logout();
      setLoading(false);
      return;
    }

    if (!currentRole.value) {
      if (!roles.value.length) {
        const rolesRes = await getMyRoles();
        if (rolesRes) {
          setRoles(rolesRes.data);
        }
      }
      handleSetRole();
    }

    if (!userInfo.value) {
      const infoRes = await getMe(currentRole.value!);
      if (infoRes) {
        setUser(infoRes.data);
      }
    }

    if (!sidebarData.value.length) {
      console.log("no sidebar data, calling menu api", currentRole.value);
      const menuRes = await getMenus(currentRole.value!);
      if (menuRes) {
        setMenus(menuRes);
      }
    }

    await checkPermission(permissionType, permittedRole);
    setLoading(false);
  };

  onBeforeMount(init);
}
