export const orgMemberTableHeaders = [
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
    accessorKey: "username",
    header: "Tên đăng nhập",
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
    accessorKey: "fullName",
    header: "Tên đầy đủ",
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
    accessorKey: "phoneNumber",
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
    accessorKey: "dateOfBirth",
    header: "Ngày sinh",
    allowFilter: true,
    filterType: "date",
    isSortable: true,
    meta: {
      class: {
        th: "min-w-[200px] pl-[32px] max-w-[280px] truncate",
        td: "pl-[32px] max-w-[280px] truncate",
      },
    },
  },
  {
    accessorKey: "isEmailVerified",
    header: "Xác thực email",
    allowFilter: true,
    filterType: "select",
    isSortable: true,
    meta: {
      class: {
        th: "min-w-[150px] pl-[32px] max-w-[200px] truncate",
        td: "pl-[32px] max-w-[200px] truncate",
      },
    },
  },
  {
    accessorKey: "isActive",
    header: "Hoạt động",
    allowFilter: true,
    filterType: "select",
    isSortable: true,
    meta: {
      class: {
        th: "min-w-[240px] pl-[32px] max-w-[280px] truncate",
        td: "pl-[32px] max-w-[280px] truncate",
      },
    },
  },
  {
    accessorKey: "roleIds",
    header: "Vai trò",
    allowFilter: true,
    filterType: "select",
    isSortable: false,
    meta: {
      class: {
        th: "min-w-[300px] pl-[32px] truncate max-w-[360px]",
        td: "pl-[32px] max-w-[360px] truncate",
      },
    },
  },
  {
    accessorKey: "createdAt",
    header: "Ngày tham gia",
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
  {
    accessorKey: "inviter",
    header: "Người mời tham gia",
    isSortable: true,
    allowFilter: true,
    filterType: "text",
    meta: {
      class: {
        th: "min-w-[204px] max-w-[232px] truncate",
        td: "max-w-[232px] truncate",
      },
    },
  },
  {
    accessorKey: "updatedAt",
    header: "Ngày cập nhật",
    isSortable: true,
    filterType: "date",
    allowFilter: true,
    meta: {
      class: {
        th: "min-w-[248px] max-w-[248px] truncate",
        td: "max-w-[248px] truncate",
      },
    },
  },
  {
    accessorKey: "updatedBy",
    header: "Người cập nhật",
    filterType: "text",
    isSortable: true,
    allowFilter: true,
    meta: {
      class: {
        th: "min-w-[168px] max-w-[168px] truncate",
        td: "max-w-[168px] truncate",
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
