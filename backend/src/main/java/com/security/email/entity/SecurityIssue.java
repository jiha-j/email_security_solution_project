package com.security.email.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "security_issues")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SecurityIssue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false, length = 100)
    private String category;

    @Column(nullable = false, length = 20)
    private String type; // INBOUND or OUTBOUND

    @Column(nullable = false, length = 20)
    private String status; // PENDING, REVIEW, RESOLVED, CRITICAL

    @Column(nullable = false, length = 20)
    private String severity; // LOW, MEDIUM, HIGH, CRITICAL

    @Column(name = "detected_date", nullable = false)
    private LocalDateTime detectedDate;

    @Column(name = "resolved_date")
    private LocalDateTime resolvedDate;

    @Column(name = "affected_emails")
    private Integer affectedEmails;

    @Column(name = "source_ip", length = 50)
    private String sourceIp;

    @Column(name = "target_email", length = 200)
    private String targetEmail;

    @PrePersist
    protected void onCreate() {
        if (detectedDate == null) {
            detectedDate = LocalDateTime.now();
        }
    }
}
