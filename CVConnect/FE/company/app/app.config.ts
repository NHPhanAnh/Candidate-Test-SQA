export default defineAppConfig({
  ui: {
    strategy: "override",
    colors: {
      primary: "red",
    },
    checkbox: {
      slots: {
        indicator: "text-white",
      },
    },
    toast: {
      slots: {
        root: "bg-white toaster absolute !right-2 rounded-[2px] shadow-md border-none ring-none ring-0",
        wrapper: "",
        title: "text-white font-normal",
        description: "text-white",
        icon: "",
        close: "p-0 text-white cursor-pointer hover:text-white",
      },
      variants: {
        color: {
          primary: {
            root: "bg-[#10b981]",
          },
          secondary: {
            root: "bg-secondary",
          },
          success: {
            root: "bg-[#10b981]",
          },
          info: {
            root: "bg-[#007bc3]",
          },
          warning: {
            root: "bg-[#f59e0b]",
          },
          error: {
            root: "bg-[#ef4444]",
          },
          neutral: {
            root: "bg-inverted",
          },
        },
        orientation: {
          horizontal: {
            root: "items-center",
            actions: "items-center",
          },
          vertical: {
            root: "items-start",
            actions: "items-start mt-2.5",
          },
        },
        title: {
          true: {
            description: "mt-1",
          },
        },
      },
      defaultVariants: {
        color: "primary",
      },
    },
  },
});
