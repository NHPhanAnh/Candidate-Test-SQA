import { PERMISSION_CHECK_TYPE } from "~/const/permission";
import type { TPermissionCheckType } from "~/types/permision";

export const usePermission = () => {
  const authStore = useAuthStore();
  const userStore = useUserStore();
  const { userInfo } = storeToRefs(userStore);
  const { currentRole, roles } = storeToRefs(authStore);
  const { setCurrentRole } = authStore;
  const sidebarStore = useSidebarStore();
  const { sidebarData } = storeToRefs(sidebarStore);
  const { logout } = useAuth();
  const router = useRouter();

  function handleSetRole() {
    if (roles.value.length == 0) {
      router.push({ path: "/403" });
      return;
    }
    const localRole = getLocalCurrentRole();
    if (localRole) {
      setCurrentRole(localRole);
      return;
    }
    const defaultRole = roles.value.find((role) => role.isDefault);
    if (defaultRole) {
      setCurrentRole(defaultRole);
      return;
    }
    if (roles.value.length == 1 && roles.value[0]) {
      setCurrentRole(roles.value[0]);
      return;
    }
    router.push({ path: "/role-select" });
  }

  async function getInitialRoute() {
    if (sidebarData.value.length == 0) {
      // No menus => return to public (in this case, to login)
      return "/";
    }

    if (!sidebarData.value[0]?.children?.length) {
      return sidebarData.value[0]?.menuUrl;
    }
    let currentNode = sidebarData.value[0].children[0];
    while (currentNode?.children?.length) {
      currentNode = currentNode.children[0];
    }

    return currentNode?.menuUrl;
  }

  async function checkPermission(type: TPermissionCheckType, value: string) {
    if (type == PERMISSION_CHECK_TYPE.MEMBER_TYPE) {
      console.log(userInfo.value);
      const matchedDetail = userInfo.value?.userDetails.find(
        (detail: any) => detail.role.id == currentRole.value?.id,
      );
      if (matchedDetail && matchedDetail.role.memberType == value) {
        return;
      }
    }
    if (type == PERMISSION_CHECK_TYPE.ROLE) {
      if (currentRole.value?.code == value) {
        return;
      }
    }

    const initialRoute = await getInitialRoute();
    router.push({ path: initialRoute });
    return;
  }

  return { handleSetRole, getInitialRoute, checkPermission };
};
