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
    id: "id",
    accessorKey: "id",
  },
  {
    id: "groupId",
    accessorKey: "groupId",
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
    accessorKey: "numOfApply",
    header: "Số tin ứng tuyển",
    allowFilter: true,
    filterType: "text",
    isSortable: true,
    meta: {
      class: {
        th: "min-w-[200px] pl-[32px] max-w-[280px] truncate",
        td: "pl-[32px] max-w-[280px] truncate text-right",
      },
    },
  },
  {
    accessorKey: "applyDate",
    header: "Ngày ứng tuyển",
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
    header: "Trạng thái ứng viên",
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
    accessorKey: "jobAdTitle",
    header: "Tên tin tuyển dụng",
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
    accessorKey: "jobAdContact",
    header: "Thông tin HR",
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
    accessorKey: "currentRound",
    header: "Vòng hiện tại",
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

export const CANDIDATE_STATUS: Record<string, any> = {
  APPLIED: {
    label: "Đã ứng tuyển",
    color: "#5C9DED",
    background: "rgba(92,157,237,0.08)",
  },
  VIEWED_CV: {
    label: "Đã xem hồ sơ",
    color: "#A58FEA",
    background: "rgba(165,143,234,0.08)",
  },
  IN_PROGRESS: {
    label: "Đang xử lý",
    color: "#F2B179",
    background: "rgba(242,177,121,0.08)",
  },
  WAITING_ONBOARDING: {
    label: "Chờ onboard",
    color: "#6CD2D2",
    background: "rgba(108,210,210,0.08)",
  },
  ONBOARDED: {
    label: "Đã onboard",
    color: "#78D6A3",
    background: "rgba(120,214,163,0.08)",
  },
  NOT_ONBOARDED: {
    label: "Không onboard",
    color: "#E8B26E",
    background: "rgba(232,178,110,0.12)",
  },
  REJECTED: {
    label: "Từ chối",
    color: "#F28B82",
    background: "rgba(242,139,130,0.08)",
  },
};

export const EMAIL_LOG_STATUS: Record<string, any> = {
  SENDING: {
    label: "Đang gửi",
    color: "#A58FEA",
    background: "rgba(165,143,234,0.08)", // soft lavender
  },
  SUCCESS: {
    label: "Thành công",
    color: "#78D6A3",
    background: "rgba(120,214,163,0.08)", // mint green
  },
  TEMPORARY_FAILURE: {
    label: "Thất bại tạm thời",
    color: "#F2B179",
    background: "rgba(242,177,121,0.08)", // warm peach
  },
  FAILURE_WAIT_RESEND: {
    label: "Thất bại, chờ gửi lại",
    color: "#E8B26E",
    background: "rgba(232,178,110,0.12)", // amber pastel
  },
  FAILURE: {
    label: "Thất bại",
    color: "#F28B82",
    background: "rgba(242,139,130,0.08)", // coral red
  },
};

export const CANDIDATE_STATUS_OPTIONS = Object.keys(CANDIDATE_STATUS).map(
  (key) => ({
    label: CANDIDATE_STATUS[key].label,
    value: key,
  }),
);

export const CANDIDATE_DETAIL_RIGHT_TABS = [
  {
    label: "Hồ sơ",
    index: 1,
    paramKey: "profile",
  },
  {
    label: "Đánh giá",
    index: 2,
    paramKey: "grade",
  },
  {
    label: "Lịch",
    index: 3,
    paramKey: "schedule",
  },
  {
    label: "Trò chuyện",
    index: 4,
    paramKey: "discussion",
  },
  {
    label: "Email đã gửi",
    index: 5,
    paramKey: "emails",
  },
];


export const DETAIL_BASE_BREADCRUMBS: TBreadcumbItem[] = [
  {
    name: "Ứng viên",
    icon: "material-symbols:person-pin-outline",
    url: "/org/candidate",
  },
];
