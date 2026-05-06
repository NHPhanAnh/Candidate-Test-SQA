export type TCandidateSummaryOrg = {
  level: {
    levelName: string;
  };
};

export type TJobAdCandidateJobAd = {
  id: number;
  title: string;
  hrContactName: string;
};

export type TJobAdCandidateCurrentRound = {
  id: number;
  code: string;
  name: string;
};

export type TJobAdCandidateApplied = {
  applyDate: number;
  candidateStatus: string;
  jobAd: TJobAdCandidateJobAd;
  currentRound: TJobAdCandidateCurrentRound;
};

export type TJobAdCandidateInfo = {
  id: number;
  fullName: string;
  email: string;
  phone: string;
  candidateSummaryOrg: TCandidateSummaryOrg;
};

export type TJobAdCandidate = {
  candidateInfo: TJobAdCandidateInfo;
  numOfApply: number;
  jobAdCandidates: TJobAdCandidateApplied[];
};

export type TCandidateFilter = {
  sortBy?: string;
  sortDirection?: string;
  pageIndex?: number;
  pageSize?: number;
  fullName?: string;
  email?: string;
  phone?: string;
  levelIds?: string;
  levels?: Record<string, number>[];
  numOfApplyStart?: number;
  numOfApplyEnd?: number;
  jobAdTitle?: string;
  candidateStatuses?: string;
  candidateStatusesOpt?: Record<string, string>[];
  processTypes?: string;
  processTypesOpt?: Record<string, number>[];
  applyDateStart?: string;
  applyDateEnd?: string;
  hrContactId?: number;
  hrContact?: Record<string, number>;
};
