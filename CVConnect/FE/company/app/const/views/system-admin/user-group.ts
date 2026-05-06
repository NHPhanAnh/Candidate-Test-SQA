export const userGroupTableHeaders = [
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
    accessorKey: "name",
    header: "Tên",
    allowFilter: true,
    filterType: 'text',
    isSortable: true,
    meta: {
      class: {
        th: "min-w-[200px] pl-[32px] max-w-[280px] truncate",
        td: "pl-[32px] max-w-[280px] truncate"
      },
    },
  },
  {
    accessorKey: "code",
    header: "Mã",
    allowFilter: true,
    filterType: 'text',
    isSortable: true,
    meta: {
      class: {
        th: "min-w-[200px] pl-[32px] max-w-[280px] truncate",
        td: "pl-[32px] max-w-[280px] truncate"
      },
    },
  },
  {
    accessorKey: "memberType",
    header: "Loại thành viên",
    isSortable: true,
    allowFilter: true,
    filterType: 'select',
    meta: {
      class: {
        th: "min-w-[200px] max-w-[280px] truncate",
        td: "max-w-[280px] truncate"
      },
    },
  },
  {
    accessorKey: "createdAt",
    header: "Ngày tạo",
    isSortable: true,
    allowFilter: true,
    filterType: 'date',
    meta: {
      class: {
        th: "min-w-[248px] max-w-[248px] truncate",
        td: "max-w-[248px] truncate"
      },
    },
  },
  {
    accessorKey: "createdBy",
    header: "Người tạo",
    isSortable: true,
    allowFilter: true,
    filterType: 'text',
    meta: {
      class: {
        th: "min-w-[168px] max-w-[168px] truncate",
        td: "max-w-[168px] truncate",
      },
    },
  },
  {
    accessorKey: "updatedAt",
    header: "Ngày cập nhật",
    isSortable: true,
    filterType: 'date',
    allowFilter: true,
    meta: {
      class: {
        th: "min-w-[248px] max-w-[248px] truncate",
        td: "max-w-[248px] truncate"
      },
    },
  },
  {
    accessorKey: "updatedBy",
    header: "Người cập nhật",
    filterType: 'text',
    isSortable: true,
    allowFilter: true,
    meta: {
      class: {
        th: "min-w-[168px] max-w-[168px] truncate",
        td: "max-w-[168px] truncate"
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
