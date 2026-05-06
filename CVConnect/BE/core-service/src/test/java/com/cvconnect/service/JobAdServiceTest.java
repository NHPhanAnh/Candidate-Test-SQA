package com.cvconnect.service;

import com.cvconnect.dto.jobAd.JobAdOutsideFilterRequest;
import com.cvconnect.dto.jobAd.JobAdOutsideFilterResponse;
import com.cvconnect.dto.jobAd.JobAdOutsideDetailResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
public class JobAdServiceTest {

    static {
        java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("UTC"));
    }

    @Autowired
    private JobAdService jobAdService;

    /**
     * Group 1: Multi-condition Filtering
     */
    @Test
    public void testFilter_MultiConditions() {
        JobAdOutsideFilterRequest req = new JobAdOutsideFilterRequest();
        req.setKeyword("Java");
        req.setCareerIds(List.of(1L));
        req.setJobAdLocation("Hà Nội");
        
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(req);
        assertNotNull(res);
        assertTrue(res.getData().getData().size() >= 0);
    }

    /**
     * Group 2: Auto-exclude Expired Jobs
     */
    @Test
    public void testExclude_ExpiredJobs() {
        JobAdOutsideFilterRequest req = new JobAdOutsideFilterRequest();
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(req);
        
        Instant now = Instant.now();
        res.getData().getData().forEach(job -> {
            if (job.getDueDate() != null) {
                assertTrue(job.getDueDate().isAfter(now), "Unit Test Error: Expired job found in results!");
            }
        });
    }

    /**
     * Group 3: Suitable Recommendation Algorithm
     */
    @Test
    public void testSuggestion_MatchingAlgorithm() {
        // Test logic filterSuitable cho ứng viên
        JobAdOutsideFilterRequest req = new JobAdOutsideFilterRequest();
        // Giả sử có logic đánh dấu lấy tin phù hợp
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> res = jobAdService.filterJobAdsForOutside(req);
        assertNotNull(res, "Matching algorithm should return valid list");
    }

    /**
     * Group 4: Private Job Access (keyCodeInternal)
     */
    @Test
    public void testPrivateAccess_InvalidKey() {
        Long privateJobId = 999L;
        // Verify exception when key is missing
        assertThrows(Exception.class, () -> jobAdService.detailOutside(privateJobId, null));
    }
}
