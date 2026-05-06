import axios from "axios";
import createAuthRefreshInterceptor from "axios-auth-refresh";

export type TApiOption = {
  isSilent: boolean;
};

export default defineNuxtPlugin(() => {
  const axiosInstance = axios.create({
    withCredentials: true,
  });

  const { setToken, clearToken, setRoles, setCurrentRole } = useAuthStore();
  const { clearUser } = useUserStore();
  const { logout } = useAuth();
  const authStore = useAuthStore();
  const { token } = storeToRefs(authStore);
  const route = useRoute();
  const router = useRouter();

  const refreshAuthLogic = (failedRequest: any) =>
    axios
      .post(`/_api/user/auth/refresh`, {}, { withCredentials: true })
      .then((tokenRefreshResponse) => {
        setToken(tokenRefreshResponse.data.data.token);
        // setRoles(tokenRefreshResponse.data.data.roles);
        // if (tokenRefreshResponse.data.data.roles.length == 1) {
        //   setCurrentRole(tokenRefreshResponse.data.data.roles[0]);
        // }
        failedRequest.response.config.headers["Authorization"] =
          "Bearer " + token.value;
        return Promise.resolve();
      })
      .catch((err) => {
        console.error(err);
        console.log("refresh fail, logout!");
        logout();
      });

  createAuthRefreshInterceptor(axiosInstance, refreshAuthLogic, {
    statusCodes: [401],
  });

  axiosInstance.interceptors.request.use(
    (config) => {
      if (token.value && !config.skipAuth) {
        config.headers.Authorization = `Bearer ${token.value}`;
      }
      return config;
    },
    (error) => {
      console.log("catch in axios plugin with error", error);
      if (error.response && error.response.status === 403) {
        router.push({ path: "/403" });
      }
      return Promise.reject(error);
    },
  );
  axiosInstance.interceptors.response.use(
    (response) => {
      return response;
    },
    (error) => {
      const status = error.response?.status;

      if (status === 403) {
        if (router.currentRoute.value.path !== "/403") {
          router.push({ path: "/403" });
        }
      }
      console.error("axios response error", status, error.message);

      return Promise.reject(error);
    },
  );

  return {
    provide: { axios: axiosInstance },
  };
});
