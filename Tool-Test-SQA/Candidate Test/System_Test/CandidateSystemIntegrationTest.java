package com.cvconnect;

import com.cvconnect.dto.jobAd.JobAdOutsideFilterRequest;
import com.cvconnect.dto.jobAd.JobAdOutsideFilterResponse;
import com.cvconnect.dto.jobAd.JobAdOutsideDetailResponse;
import com.cvconnect.dto.jobAdCandidate.ApplyRequest;
import com.cvconnect.dto.searchHistoryOutside.SearchHistoryOutsideDto;
import com.cvconnect.service.JobAdService;
import com.cvconnect.service.JobAdCandidateService;
import com.cvconnect.service.SearchHistoryOutsideService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Hệ thống kiểm thử tích hợp luồng ứng viên (Candidate Flow)
 * Đồng bộ ID với tài liệu kiểm thử (Excel) và Tool Selenium
 */
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
    private SearchHistoryOutsideService searchHistoryService;

    private void mockLogin(long userId) {
        Map<String, Object> principal = new HashMap<>();
        principal.put("id", userId);
        SecurityContextHolder.getContext().setAuthentication(
            new UsernamePasswordAuthenticationToken(principal, null, Collections.emptyList())
        );
    }

    /**
     * TC-SYS-01: Kiểm tra lọc tin tuyển dụng theo từ khóa
     * File kiểm tra: JobAdServiceImpl.java
     */
    @Test
    public void test_TC_SYS_01_FilterJobAds() {
        mockLogin(27L);

        JobAdOutsideFilterRequest filterReq = new JobAdOutsideFilterRequest();
        filterReq.setKeyword("Java");
        
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> filterRes = jobAdService.filterJobAdsForOutside(filterReq);

        assertNotNull(filterRes, "Lỗi tại JobAdService: Đối tượng FilterResponse trả về null");
        assertNotNull(filterRes.getData(), "Lỗi tại JobAdServiceImpl: Dữ liệu phân trang (PageResponse) bị null khi lọc keyword 'Java'");
    }

    /**
     * TC-SYS-02: Kiểm tra hệ thống chặn nộp đơn trùng lặp
     * File kiểm tra: JobAdCandidateServiceImpl.java (Hàm validateApply)
     */
    @Test
    public void test_TC_SYS_02_ApplyCV_DuplicateBlock() {
        mockLogin(27L);

        JobAdOutsideFilterRequest filterReq = new JobAdOutsideFilterRequest();
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> filterRes = jobAdService.filterJobAdsForOutside(filterReq);

        if (filterRes.getData() != null && !filterRes.getData().getData().isEmpty()) {
            Long jobId = filterRes.getData().getData().get(0).getId();

            ApplyRequest applyReq = ApplyRequest.builder()
                    .jobAdId(jobId)
                    .fullName("Phan Anh Test")
                    .email("test-system@gmail.com")
                    .phone("0123456789")
                    .build();

            MockMultipartFile mockFile = new MockMultipartFile(
                    "cvFile", "test.pdf", "application/pdf", "fake content".getBytes());

            // Bước 1: Nộp lần đầu
            assertDoesNotThrow(() -> {
                jobAdCandidateService.apply(applyReq, mockFile);
            }, "Lỗi tại JobAdCandidateServiceImpl: Nộp đơn lần đầu thất bại");

            // Bước 2: Nộp lại cùng một Job -> Phải báo lỗi duplicate
            Exception ex = assertThrows(Exception.class, () -> {
                jobAdCandidateService.apply(applyReq, mockFile);
            }, "Lỗi tại JobAdCandidateServiceImpl: Hệ thống không ném ra ngoại lệ khi nộp trùng đơn");
            
            assertTrue(ex.getMessage().contains("duplicate") || ex.getClass().getSimpleName().contains("Constraint"), 
                "Lỗi tại JobAdCandidateServiceImpl: Thông báo lỗi nộp trùng đơn không đúng định dạng (candidate.duplicate.apply)");
        }
    }

    /**
     * TC-SYS-03: Kiểm tra lưu lịch sử tìm kiếm
     * File kiểm tra: SearchHistoryOutsideServiceImpl.java
     */
    @Test
    public void test_TC_SYS_03_SaveSearchHistory() {
        mockLogin(27L);

        SearchHistoryOutsideDto historyDto = SearchHistoryOutsideDto.builder()
                .keyword("Backend Developer")
                .build();

        assertDoesNotThrow(() -> {
            searchHistoryService.create(historyDto);
        }, "Lỗi tại SearchHistoryOutsideServiceImpl: Lưu lịch sử tìm kiếm thất bại vào Database");
    }

    /**
     * TC-SYS-04: Kiểm tra xem chi tiết tin tuyển dụng
     * File kiểm tra: JobAdServiceImpl.java (Hàm detailOutside)
     */
    @Test
    public void test_TC_SYS_04_ViewJobDetail() {
        mockLogin(27L);

        JobAdOutsideFilterRequest filterReq = new JobAdOutsideFilterRequest();
        JobAdOutsideFilterResponse<JobAdOutsideDetailResponse> filterRes = jobAdService.filterJobAdsForOutside(filterReq);

        if (filterRes.getData() != null && !filterRes.getData().getData().isEmpty()) {
            Long jobId = filterRes.getData().getData().get(0).getId();

            JobAdOutsideDetailResponse detail = assertDoesNotThrow(() ->
                    jobAdService.detailOutside(jobId, null),
                    "Lỗi tại JobAdServiceImpl: Không thể lấy chi tiết tin tuyển dụng cho ID: " + jobId
            );
            assertNotNull(detail, "Lỗi tại JobAdServiceImpl: Dữ liệu chi tiết tin tuyển dụng trả về null");
        }
    }
}
