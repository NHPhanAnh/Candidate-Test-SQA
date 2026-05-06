package com.cvconnect.service;

import com.cvconnect.dto.jobAd.JobAdOutsideFilterRequest;
import com.cvconnect.dto.jobAd.JobAdOutsideFilterResponse;
import com.cvconnect.dto.jobAd.JobAdOutsideDetailResponse;
import com.cvconnect.dto.jobAdCandidate.ApplyRequest;
import com.cvconnect.repository.CandidateInfoApplyRepository;
import nmquan.commonlib.exception.AppException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
public class CandidateInfoApplyServiceTest {

    static {
        java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("UTC"));
    }

    @Autowired
    private JobAdCandidateService jobAdCandidateService;
    
    @Autowired
    private JobAdService jobAdService;

    private void mockLogin(long userId) {
        Map<String, Object> principal = new HashMap<>();
        principal.put("id", userId);
        SecurityContextHolder.getContext().setAuthentication(
            new UsernamePasswordAuthenticationToken(principal, null, Collections.emptyList())
        );
    }

    private Long getActiveJobId() {
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(new JobAdOutsideFilterRequest());
        return res.getData().getData().isEmpty() ? null : res.getData().getData().get(0).getId();
    }

    /**
     * Group 5: Block Duplicate CV Submission
     */
    @Test
    public void testApply_PreventDuplicate() {
        mockLogin(27L);
        Long jobId = getActiveJobId();
        if (jobId == null) return;

        ApplyRequest req = ApplyRequest.builder().jobAdId(jobId).fullName("T").email("unit-dup@sqa.com").phone("1").build();
        MockMultipartFile file = new MockMultipartFile("cv", "cv.pdf", "application/pdf", "c".getBytes());

        // First apply
        jobAdCandidateService.apply(req, file);

        // Second apply - should fail
        assertThrows(AppException.class, () -> jobAdCandidateService.apply(req, file), "Duplicate apply must be blocked at Service layer");
    }

    /**
     * Group 6: CV File Validation (Size & Extension)
     */
    @Test
    public void testApply_FileValidation() {
        mockLogin(27L);
        Long jobId = getActiveJobId();
        if (jobId == null) return;
        
        ApplyRequest req = ApplyRequest.builder().jobAdId(jobId).fullName("T").email("unit-file@sqa.com").phone("1").build();

        // 1. Test large file (>10MB)
        MockMultipartFile largeFile = new MockMultipartFile("cv", "big.pdf", "pdf", new byte[11 * 1024 * 1024]);
        assertThrows(Exception.class, () -> jobAdCandidateService.apply(req, largeFile), "Service must reject oversized files");

        // 2. Test invalid extension (.exe)
        MockMultipartFile exeFile = new MockMultipartFile("cv", "virus.exe", "application/octet-stream", "c".getBytes());
        assertThrows(Exception.class, () -> jobAdCandidateService.apply(req, exeFile), "Service must reject dangerous file extensions");
    }
}
