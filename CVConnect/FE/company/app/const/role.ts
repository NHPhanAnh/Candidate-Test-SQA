export const ROLE_ICON_MAP: Record<TRole, string> = {
  CANDIDATE: "mdi:clipboard-account",
  SYSTEM_ADMIN: "mdi:account-cog",
  ORG_ADMIN: "mdi:account-details",
  HR: "mdi:account-file-text",
  INTERVIEWER: "mdi:account-edit",
};
export const ROLE_ICON_DEFAULT = "mdi:account-circle";

export const ROLE_COLORED_ICON_MAP: Record<TRole, string> = {
  CANDIDATE: "fluent-color:patient-32",
  SYSTEM_ADMIN: "fluent-color:lock-shield-32",
  ORG_ADMIN: "fluent-color:lock-shield-32",
  HR: "fluent-color:people-list-32",
  INTERVIEWER: "fluent-color:person-feedback-32",
};
export const ROLE_COLORED_ICON_DEFAULT = "fluent-color:person-32";
export const DEFAULT_ROLE_VIEW: Record<TRole, string> = {
  SYSTEM_ADMIN: "/system-admin/report/candidate",
  CANDIDATE: "/dashboard",
  HR: "",
  ORG_ADMIN: "/org-admin/org-member",
  INTERVIEWER: "",
};

export const DEFAULT_MEMBER_TYPE_VIEW: Record<string, string> = {
  ORG: '/org-info'
};
