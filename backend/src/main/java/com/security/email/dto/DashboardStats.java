package com.security.email.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStats {
    private long totalIssues;
    private long inboundIssues;
    private long outboundIssues;
    private long pendingIssues;
    private long reviewIssues;
    private long resolvedIssues;
    private long criticalIssues;
    private Map<String, Long> issuesByCategory;
    private Map<String, Long> issuesBySeverity;
}
