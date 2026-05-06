package com.cvconnect.service;

import com.cvconnect.dto.candidateInfoApply.CandidateInfoApplyDto;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class CandidateInfoApplyServiceTest {

    @Mock
    private CandidateInfoApplyRepository applyRepository;

    @Mock
    private CloudinaryService cloudinaryService;

    @InjectMocks
    private CandidateInfoApplyServiceImpl applyService;

    @Test
    public void testCreateApply_DuplicateCV_ThrowsException() {
        // Arrange
        CandidateInfoApplyDto dto = new CandidateInfoApplyDto();
        dto.setJobAdId(1L);
        dto.setEmail("phananh@gmail.com");

        when(applyRepository.existsByJobAdIdAndEmail(1L, "phananh@gmail.com")).thenReturn(true);

        // Act & Assert
        Exception exception = assertThrows(RuntimeException.class, () -> {
            applyService.create(Collections.singletonList(dto));
        });
        assertTrue(exception.getMessage().contains("Duplicate CV for the same Job Ad"));
    }

    @Test
    public void testCreateApply_InvalidFileFormat_ThrowsException() {
        // Arrange
        CandidateInfoApplyDto dto = new CandidateInfoApplyDto();
        dto.setFileName("virus.exe");

        // Act & Assert
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            // Assume validation happens inside create or via a helper
            applyService.create(Collections.singletonList(dto));
        });
        assertTrue(exception.getMessage().contains("Invalid file format. Only PDF/DOCX allowed."));
    }

    @Test
    public void testCreateApply_ExceedFileSize_ThrowsException() {
        // Arrange
        CandidateInfoApplyDto dto = new CandidateInfoApplyDto();
        dto.setFileName("heavy_portfolio.pdf");
        dto.setFileSize(6 * 1024 * 1024); // 6MB

        // Act & Assert
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            applyService.create(Collections.singletonList(dto));
        });
        assertTrue(exception.getMessage().contains("File size exceeds 5MB limit."));
    }
}
