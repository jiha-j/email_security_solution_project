package com.security.email.repository;

import com.security.email.entity.SecurityIssue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SecurityIssueRepository extends JpaRepository<SecurityIssue, Long> {

    // Find top 3 by custom priority: CRITICAL first, then by affected emails, then by severity
    @Query("SELECT s FROM SecurityIssue s WHERE s.status != 'RESOLVED' ORDER BY " +
           "CASE WHEN s.severity = 'CRITICAL' THEN 0 ELSE 1 END, " +
           "s.affectedEmails DESC, " +
           "CASE s.severity " +
           "WHEN 'HIGH' THEN 1 " +
           "WHEN 'MEDIUM' THEN 2 " +
           "WHEN 'LOW' THEN 3 " +
           "ELSE 4 END, s.detectedDate DESC")
    List<SecurityIssue> findTop3BySeverity();

}
