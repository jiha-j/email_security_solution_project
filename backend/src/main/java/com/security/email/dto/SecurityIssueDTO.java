package com.security.email.dto;

import com.security.email.entity.SecurityIssue;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SecurityIssueDTO {
    private Long id;
    private String title;
    private String description;
    private String category;
    private String type;
    private String status;
    private String severity;
    private LocalDateTime detectedDate;
    private LocalDateTime resolvedDate;
    private Integer affectedEmails;
    private String sourceIp;
    private String targetEmail;

    // Convert Entity to DTO
    public static SecurityIssueDTO fromEntity(SecurityIssue entity) {
        return new SecurityIssueDTO(
            entity.getId(),
            entity.getTitle(),
            entity.getDescription(),
            entity.getCategory(),
            entity.getType(),
            entity.getStatus(),
            entity.getSeverity(),
            entity.getDetectedDate(),
            entity.getResolvedDate(),
            entity.getAffectedEmails(),
            entity.getSourceIp(),
            entity.getTargetEmail()
        );
    }
}
