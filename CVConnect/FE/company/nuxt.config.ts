// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },
  modules: [
    "@nuxt/eslint",
    "@nuxt/image",
    "@nuxt/ui",
    "@pinia/nuxt",
    "@vueuse/nuxt",
    "pinia-plugin-persistedstate/nuxt",
    "@nuxtjs/color-mode",
  ],
  devServer: {
    host: "0.0.0.0",
    port: 3000,
  },
  app: {
    head: {
      link: [{ rel: "icon", type: "image/svg+xml", href: "/favicon-icon.svg" }],
    },
  },
  colorMode: {
    preference: "light",
    fallback: "light",
    classSuffix: "",
    storageKey: "nuxt-color-mode",
  },
  ssr: false,
  css: ["~/assets/main.css"],
  vite: {
    server: {
      proxy: {
        "/_api": {
          target: "http://localhost:8888",
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/_api/, "/api/v1"),
        },
      },
    },
    css: {
      preprocessorOptions: {
        scss: {
          additionalData:
            '@import "~/assets/colors.scss";@import "~/assets/_mixin.scss";',
        },
      },
    },
  },
  build: {
    transpile: ["@vuepic/vue-datepicker"],
  },
});
