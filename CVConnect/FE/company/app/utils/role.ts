import { DEFAULT_ROLE_VIEW } from "~/const/role"

export const getDefaultRoute = (role: TAccountRole) => {
  const roleCode: TRole = role.code
  return DEFAULT_ROLE_VIEW[roleCode]
}
