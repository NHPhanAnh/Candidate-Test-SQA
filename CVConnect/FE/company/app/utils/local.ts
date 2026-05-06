const defaultRoleKey = "auth-default-role";
const currentRoleKey = "current-role";

const getDefaultRole = (): TAccountRole | null => {
  const role = localStorage.getItem(defaultRoleKey);
  if (role) {
    return JSON.parse(role);
  }
  return null;
};

const setDefaultRole = (role: TAccountRole) => {
  localStorage.setItem(defaultRoleKey, JSON.stringify(role));
};

const clearDefaultRole = () => {
  localStorage.removeItem(defaultRoleKey);
};

const getLocalCurrentRole = (): TAccountRole | null => {
  const role = localStorage.getItem(currentRoleKey);
  if (role) {
    return JSON.parse(role);
  }
  return null;
};

const setLocalCurrentRole = (role: TAccountRole) => {
  localStorage.setItem(currentRoleKey, JSON.stringify(role));
};

const clearLocalCurrentRole = () => {
  localStorage.removeItem(currentRoleKey);
};

export {
  getDefaultRole,
  setDefaultRole,
  clearDefaultRole,
  getLocalCurrentRole,
  setLocalCurrentRole,
  clearLocalCurrentRole,
};
