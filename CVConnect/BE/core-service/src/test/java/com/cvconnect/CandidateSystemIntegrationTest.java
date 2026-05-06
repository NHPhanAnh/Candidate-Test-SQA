package com.cvconnect;

import com.cvconnect.dto.jobAd.JobAdOutsideFilterRequest;
import com.cvconnect.dto.jobAd.JobAdOutsideFilterResponse;
import com.cvconnect.dto.jobAd.JobAdOutsideDetailResponse;
import com.cvconnect.dto.jobAdCandidate.ApplyRequest;
import com.cvconnect.repository.CandidateInfoApplyRepository;
import com.cvconnect.service.JobAdService;
import com.cvconnect.service.JobAdCandidateService;
import nmquan.commonlib.exception.AppException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.Instant;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
public class CandidateSystemIntegrationTest {

    static {
        java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("UTC"));
    }

    @Autowired
    private JobAdService jobAdService;

    @Autowired
    private JobAdCandidateService jobAdCandidateService;

    @Autowired
    private CandidateInfoApplyRepository applyRepository;

    private void mockLogin(long userId) {
        Map<String, Object> principal = new HashMap<>();
        principal.put("id", userId);
        SecurityContextHolder.getContext().setAuthentication(
            new UsernamePasswordAuthenticationToken(principal, null, Collections.emptyList())
        );
    }

    private Long getActiveJobId() {
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(new JobAdOutsideFilterRequest());
        if (res.getData().getData().isEmpty()) return null;
        return res.getData().getData().get(0).getId();
    }

    // ==========================================
    // GROUP 1: MULTI-FILTER SEARCH
    // ==========================================
    @Test
    public void test_TC_SYS_001_A_KeywordSearchOnly() {
        JobAdOutsideFilterRequest req = new JobAdOutsideFilterRequest();
        req.setKeyword("Java");
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(req);
        assertNotNull(res);
        res.getData().getData().forEach(job -> assertTrue(job.getTitle().toLowerCase().contains("java")));
    }

    @Test
    public void test_TC_SYS_001_B_CombinedFilter() {
        JobAdOutsideFilterRequest req = new JobAdOutsideFilterRequest();
        req.setKeyword("Java");
        req.setJobAdLocation("Hà Nội");
        req.setCareerIds(List.of(1L));
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(req);
        assertNotNull(res);
    }

    @Test
    public void test_TC_SYS_001_C_NoResults() {
        JobAdOutsideFilterRequest req = new JobAdOutsideFilterRequest();
        req.setKeyword("NonExistentJob123456789");
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(req);
        assertTrue(res.getData().getData().isEmpty());
    }

    // ==========================================
    // GROUP 2: SUITABLE SUGGESTIONS
    // ==========================================
    @Test
    public void test_TC_SYS_002_A_SuggestionsForProfile() {
        mockLogin(27L);
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(new JobAdOutsideFilterRequest());
        assertNotNull(res);
    }

    // ==========================================
    // GROUP 3: PRIVATE ACCESS
    // ==========================================
    @Test
    public void test_TC_SYS_003_A_PrivateAccess_MissingKey() {
        assertThrows(Exception.class, () -> jobAdService.detailOutside(999L, null));
    }

    // ==========================================
    // GROUP 4: DUPLICATE CHECK
    // ==========================================
    @Test
    public void test_TC_SYS_004_A_SuccessFirstTime() {
        mockLogin(27L);
        Long jobId = getActiveJobId();
        if (jobId == null) return;
        
        ApplyRequest req = ApplyRequest.builder().jobAdId(jobId).fullName("T").email("t1@sqa.com").phone("1").build();
        MockMultipartFile file = new MockMultipartFile("cv", "cv.pdf", "application/pdf", "c".getBytes());
        assertDoesNotThrow(() -> jobAdCandidateService.apply(req, file));
    }

    @Test
    public void test_TC_SYS_004_B_BlockSecondTime() {
        mockLogin(27L);
        Long jobId = getActiveJobId();
        if (jobId == null) return;
        
        ApplyRequest req = ApplyRequest.builder().jobAdId(jobId).fullName("T").email("t2@sqa.com").phone("1").build();
        MockMultipartFile file = new MockMultipartFile("cv", "cv.pdf", "application/pdf", "c".getBytes());
        
        jobAdCandidateService.apply(req, file);
        assertThrows(AppException.class, () -> jobAdCandidateService.apply(req, file));
    }

    // ==========================================
    // GROUP 5: FILE VALIDATION
    // ==========================================
    @Test
    public void test_TC_SYS_005_A_ValidPDF() {
        mockLogin(27L);
        Long jobId = getActiveJobId();
        if (jobId == null) return;

        ApplyRequest req = ApplyRequest.builder().jobAdId(jobId).fullName("T").email("pdf@sqa.com").phone("1").build();
        MockMultipartFile file = new MockMultipartFile("cv", "cv.pdf", "application/pdf", "c".getBytes());
        assertDoesNotThrow(() -> jobAdCandidateService.apply(req, file));
    }

    @Test
    public void test_TC_SYS_005_B_LargeFileBlock() {
        mockLogin(27L);
        Long jobId = getActiveJobId();
        if (jobId == null) return;

        ApplyRequest req = ApplyRequest.builder().jobAdId(jobId).fullName("T").email("big@sqa.com").phone("1").build();
        MockMultipartFile file = new MockMultipartFile("cv", "big.pdf", "pdf", new byte[11 * 1024 * 1024]);
        assertThrows(Exception.class, () -> jobAdCandidateService.apply(req, file));
    }

    @Test
    public void test_TC_SYS_005_C_InvalidExtensionBlock() {
        mockLogin(27L);
        Long jobId = getActiveJobId();
        if (jobId == null) return;

        ApplyRequest req = ApplyRequest.builder().jobAdId(jobId).fullName("T").email("exe@sqa.com").phone("1").build();
        MockMultipartFile file = new MockMultipartFile("cv", "virus.exe", "application/octet-stream", "c".getBytes());
        assertThrows(Exception.class, () -> jobAdCandidateService.apply(req, file));
    }

    // ==========================================
    // GROUP 6: EXPIRED JOBS
    // ==========================================
    @Test
    public void test_TC_SYS_006_A_ExclusionFromGlobalSearch() {
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(new JobAdOutsideFilterRequest());
        Instant now = Instant.now();
        long expired = res.getData().getData().stream()
                .filter(job -> job.getDueDate() != null && job.getDueDate().isBefore(now)).count();
        assertEquals(0, expired);
    }
}
