export const SALARY_FILTER = [
  {
    label: "Tất cả",
    value: "ALL",
  },
  {
    label: "Dưới 10 triệu",
    value: "0,10000000",
  },
  {
    label: "10 - 15 triệu",
    value: "10000000,15000000",
  },
  {
    label: "15 - 20 triệu",
    value: "15000000,20000000",
  },
  {
    label: "20 - 25 triệu",
    value: "20000000,25000000",
  },
  {
    label: "25 - 30 triệu",
    value: "25000000,30000000",
  },
  {
    label: "30 - 50 triệu",
    value: "30000000,50000000",
  },
  {
    label: "Trên 50 triệu",
    value: "50000000,",
  },
  {
    label: "Thỏa thuận",
    value: "negotiable",
  },
];

export const JOBS_SORTER = [
  {
    label: "Việc làm nổi bật",
    value: {
      sortBy: "viewCount",
      sortDirection: "DESC",
    },
  },
  {
    label: "Tin mới nhất",
    value: {
      sortBy: "createdAt",
      sortDirection: "DESC",
    },
  },
  {
    label: "Lương cao đến thấp",
    value: {
      sortBy: "salaryTo",
      sortDirection: "DESC",
    },
  },
  {
    label: "Lương thấp đến cao",
    value: {
      sortBy: "salaryTo",
      sortDirection: "ASC",
    },
  },
  {
    label: "Hạn ứng tuyển",
    value: {
      sortBy: "dueDate",
      sortDirection: "DESC",
    },
  },
];
