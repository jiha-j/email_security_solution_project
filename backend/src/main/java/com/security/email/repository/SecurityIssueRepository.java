package com.security.email.repository;

import com.security.email.entity.SecurityIssue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SecurityIssueRepository extends JpaRepository<SecurityIssue, Long> {

    // Find by status
    List<SecurityIssue> findByStatus(String status);

    // Find by type (INBOUND/OUTBOUND)
    List<SecurityIssue> findByType(String type);

    // Find by severity
    List<SecurityIssue> findBySeverity(String severity);

    // Find top 3 by severity and affected emails (CRITICAL first, then by affected emails)
    @Query("SELECT s FROM SecurityIssue s WHERE s.status != 'RESOLVED' ORDER BY " +
           "CASE s.severity " +
           "WHEN 'CRITICAL' THEN 1 " +
           "WHEN 'HIGH' THEN 2 " +
           "WHEN 'MEDIUM' THEN 3 " +
           "WHEN 'LOW' THEN 4 " +
           "END, s.affectedEmails DESC, s.detectedDate DESC")
    List<SecurityIssue> findTop3BySeverity();

    // Count by status
    long countByStatus(String status);

    // Count by type
    long countByType(String type);
}
