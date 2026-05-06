import type { CHIP_TYPE } from "~/const/common";

export type TSortType = "ASC" | "DESC" | undefined;
export type TSort = {
  key: string | undefined;
  type: TSortType;
};

export type TChipType = (typeof CHIP_TYPE)[keyof typeof CHIP_TYPE];
