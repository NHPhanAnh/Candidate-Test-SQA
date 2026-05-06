export const CREATE_TABS = [
  {
    label: "Thông tin tuyển dụng",
    index: 1,
  },
  {
    label: "Quy trình tuyển dụng",
    index: 2,
  },
];

export const CREATE_BREADCRUMBS: TBreadcumbItem[] = [
  {
    name: "Tin tuyển dụng",
    icon: "hugeicons:job-search",
    url: "/org/job-ad",
  },
  {
    name: "Thêm mới",
    icon: "",
    url: "/org/job-ad/create",
  },
];

export const DETAIL_BREADCRUMBS: TBreadcumbItem[] = [
  {
    name: "Tin tuyển dụng",
    icon: "hugeicons:job-search",
    url: "/org/job-ad",
  },
];

export const candidateTableHeaders = [
  {
    accessorKey: "index",
    header: "STT",
    meta: {
      class: {
        th: "min-w-[56px]",
      },
    },
  },
  {
    accessorKey: "fullName",
    header: "Tên",
    allowFilter: true,
    filterType: "text",
    isSortable: true,
    meta: {
      class: {
        th: "min-w-[200px] pl-[32px] max-w-[280px] truncate",
        td: "pl-[32px] max-w-[280px] truncate",
      },
    },
  },
  {
    accessorKey: "email",
    header: "Email",
    allowFilter: true,
    filterType: "text",
    isSortable: true,
    meta: {
      class: {
        th: "min-w-[200px] pl-[32px] max-w-[280px] truncate",
        td: "pl-[32px] max-w-[280px] truncate",
      },
    },
  },
  {
    accessorKey: "phone",
    header: "SĐT",
    allowFilter: true,
    filterType: "text",
    isSortable: true,
    meta: {
      class: {
        th: "min-w-[200px] pl-[32px] max-w-[280px] truncate",
        td: "pl-[32px] max-w-[280px] truncate",
      },
    },
  },
  {
    accessorKey: "candidateStatus",
    header: "Trạng thái",
    allowFilter: true,
    filterType: "select",
    isSortable: false,
    meta: {
      class: {
        th: "min-w-[100px] pl-[32px] max-w-[200px] truncate",
        td: "pl-[32px] max-w-[200px] truncate",
      },
    },
  },
  {
    accessorKey: "level",
    header: "Cấp bậc",
    isSortable: true,
    allowFilter: true,
    filterType: "select",
    meta: {
      class: {
        th: "min-w-[100px] pl-[32px] max-w-[200px] truncate",
        td: "pl-[32px] max-w-[200px] truncate",
      },
    },
  },
  {
    accessorKey: "applyDate",
    header: "Ngày ứng tuyển",
    isSortable: true,
    allowFilter: true,
    filterType: "date",
    meta: {
      class: {
        th: "min-w-[248px] max-w-[248px] truncate",
        td: "max-w-[248px] truncate",
      },
    },
  },
];

export const pageSizeOptions = [
  {
    label: "10",
    value: 10,
  },
  {
    label: "20",
    value: 20,
  },
  {
    label: "50",
    value: 50,
  },
];
