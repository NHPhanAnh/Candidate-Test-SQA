import type { PERMISSION_CHECK_TYPE } from "~/const/permission";

export type TPermissionCheckType = typeof PERMISSION_CHECK_TYPE[keyof typeof PERMISSION_CHECK_TYPE];
