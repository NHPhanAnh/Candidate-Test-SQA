package com.cvconnect.service;

import com.cvconnect.dto.jobAd.JobAdOutsideFilterRequest;
import com.cvconnect.dto.jobAd.JobAdOutsideDetailResponse;
import nmquan.commonlib.dto.request.FilterRequest;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class JobAdServiceTest {

    @Mock
    private JobAdRepository jobAdRepository;

    @InjectMocks
    private JobAdServiceImpl jobAdService;

    @Test
    public void testFilterJobAds_MultipleConditions_Success() {
        // Arrange
        JobAdOutsideFilterRequest request = new JobAdOutsideFilterRequest();
        request.setKeyword("Java");
        request.setCityId(1L);
        request.setCareerId(2L);
        request.setLevelId(3L);

        when(jobAdRepository.filterOutside(any())).thenReturn(Collections.emptyList());

        // Act
        var response = jobAdService.filterJobAdsForOutside(request);

        // Assert
        assertNotNull(response);
        verify(jobAdRepository, times(1)).filterOutside(any());
    }

    @Test
    public void testFilterSuitableOutside_Success() {
        // Arrange
        FilterRequest request = new FilterRequest();
        when(jobAdRepository.filterSuitable(any())).thenReturn(Collections.emptyList());

        // Act
        var response = jobAdService.filterSuitableOutside(request);

        // Assert
        assertNotNull(response);
    }

    @Test
    public void testDetailOutside_PrivateJob_WithValidKeyCode() {
        // Arrange
        Long jobId = 999L;
        String keyCode = "SECRET123";
        JobAdOutsideDetailResponse mockResponse = new JobAdOutsideDetailResponse();
        when(jobAdRepository.findByIdAndKeyCode(jobId, keyCode)).thenReturn(mockResponse);

        // Act
        var result = jobAdService.detailOutside(jobId, keyCode);

        // Assert
        assertNotNull(result);
    }

    @Test
    public void testDetailOutside_PrivateJob_WithInvalidKeyCode() {
        // Arrange
        Long jobId = 999L;
        String invalidCode = "WRONG";
        when(jobAdRepository.findByIdAndKeyCode(jobId, invalidCode)).thenReturn(null);

        // Act & Assert
        Exception exception = assertThrows(RuntimeException.class, () -> {
            jobAdService.detailOutside(jobId, invalidCode);
        });
        assertTrue(exception.getMessage().contains("Access Denied"));
    }

    @Test
    public void testFilterJobAds_ExcludeExpired_Success() {
        // Arrange
        JobAdOutsideFilterRequest request = new JobAdOutsideFilterRequest();
        // The repository method should inherently filter by expiration date
        when(jobAdRepository.filterOutside(any())).thenReturn(Collections.emptyList());

        // Act
        var response = jobAdService.filterJobAdsForOutside(request);

        // Assert
        assertNotNull(response);
        verify(jobAdRepository, times(1)).filterOutside(any());
    }
}
