package com.security.email.service;

import com.security.email.dto.DashboardStats;
import com.security.email.dto.SecurityIssueDTO;
import com.security.email.entity.SecurityIssue;
import com.security.email.repository.SecurityIssueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SecurityIssueService {

    private final SecurityIssueRepository repository;

    // Get all issues
    public List<SecurityIssueDTO> getAllIssues() {
        return repository.findAll().stream()
                .map(SecurityIssueDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // Get issue by ID
    public SecurityIssueDTO getIssueById(Long id) {
        return repository.findById(id)
                .map(SecurityIssueDTO::fromEntity)
                .orElseThrow(() -> new RuntimeException("Issue not found with id: " + id));
    }

    // Get top 3 critical issues
    public List<SecurityIssueDTO> getTop3Issues() {
        return repository.findTop3BySeverity().stream()
                .limit(3)
                .map(SecurityIssueDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // Create new issue
    @Transactional
    public SecurityIssueDTO createIssue(SecurityIssueDTO dto) {
        SecurityIssue issue = new SecurityIssue();
        issue.setTitle(dto.getTitle());
        issue.setDescription(dto.getDescription());
        issue.setCategory(dto.getCategory());
        issue.setType(dto.getType());
        issue.setStatus(dto.getStatus());
        issue.setSeverity(dto.getSeverity());
        issue.setAffectedEmails(dto.getAffectedEmails());
        issue.setSourceIp(dto.getSourceIp());
        issue.setTargetEmail(dto.getTargetEmail());
        issue.setDetectedDate(LocalDateTime.now());

        SecurityIssue saved = repository.save(issue);
        return SecurityIssueDTO.fromEntity(saved);
    }

    // Update issue status
    @Transactional
    public SecurityIssueDTO updateStatus(Long id, String newStatus) {
        SecurityIssue issue = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Issue not found with id: " + id));

        issue.setStatus(newStatus);

        if ("RESOLVED".equals(newStatus) && issue.getResolvedDate() == null) {
            issue.setResolvedDate(LocalDateTime.now());
        }

        SecurityIssue updated = repository.save(issue);
        return SecurityIssueDTO.fromEntity(updated);
    }

    // Get dashboard statistics
    public DashboardStats getDashboardStats() {
        List<SecurityIssue> allIssues = repository.findAll();

        long total = allIssues.size();
        long inbound = allIssues.stream().filter(i -> "INBOUND".equals(i.getType())).count();
        long outbound = allIssues.stream().filter(i -> "OUTBOUND".equals(i.getType())).count();
        long pending = allIssues.stream().filter(i -> "PENDING".equals(i.getStatus())).count();
        long review = allIssues.stream().filter(i -> "REVIEW".equals(i.getStatus())).count();
        long resolved = allIssues.stream().filter(i -> "RESOLVED".equals(i.getStatus())).count();
        long critical = allIssues.stream().filter(i -> "CRITICAL".equals(i.getStatus())).count();

        Map<String, Long> byCategory = allIssues.stream()
                .collect(Collectors.groupingBy(SecurityIssue::getCategory, Collectors.counting()));

        Map<String, Long> bySeverity = allIssues.stream()
                .collect(Collectors.groupingBy(SecurityIssue::getSeverity, Collectors.counting()));

        return new DashboardStats(
            total, inbound, outbound, pending, review, resolved, critical,
            byCategory, bySeverity
        );
    }

    // Initialize sample data
    @Transactional
    public void initSampleData() {
        if (repository.count() > 0) {
            return; // Data already exists
        }

        List<SecurityIssue> sampleIssues = Arrays.asList(
            createIssue("대량 스팸 메일 탐지 (1,250건)", "단일 IP에서 1시간 내 1,250건의 스팸 메일 발송 탐지",
                "대량 스팸 메일 공격", "INBOUND", "CRITICAL", "CRITICAL", 1250, "203.142.78.91", "admin@company.com"),

            createIssue("피싱 사이트 링크 포함 메일", "은행 사칭 피싱 사이트로 유도하는 링크 발견",
                "개인정보 탈취 피싱 사이트 공격", "INBOUND", "PENDING", "HIGH", 15, "185.220.101.45", "hr@company.com"),

            createIssue("의심스러운 첨부파일 탐지", "ransomware.exe 파일이 첨부된 메일 차단",
                "바이러스, 랜섬웨어 등 악성코드 공격", "INBOUND", "CRITICAL", "CRITICAL", 3, "91.203.45.122", "finance@company.com"),

            createIssue("헤더 위변조 메일 탐지", "CEO 이메일을 사칭한 송금 요청 메일",
                "헤더 위·변조 및 유사 도메인 사칭 메일", "INBOUND", "REVIEW", "HIGH", 8, "172.104.88.29", "accounting@company.com"),

            createIssue("불법 릴레이 서버 사용 탐지", "외부 서버를 통한 스팸 메일 발송 시도",
                "불법 릴레이 서버 사용", "INBOUND", "PENDING", "MEDIUM", 45, "198.51.100.42", "mail-relay@company.com"),

            createIssue("고객 정보 포함 메일 외부 발송", "개인정보 500건이 포함된 엑셀 파일 외부 전송",
                "기업 내부 정보 유출 및 오발송 사고", "OUTBOUND", "CRITICAL", "CRITICAL", 500, "192.168.1.105", "external-partner@gmail.com"),

            createIssue("바이러스 URL 공유 탐지", "악성 URL이 포함된 메일 발송 차단",
                "바이러스 URL 공유", "OUTBOUND", "REVIEW", "HIGH", 12, "192.168.1.87", "client@external.com"),

            createIssue("악성 메일 회신 탐지", "피싱 메일에 대한 직원의 회신 차단",
                "악성 메일 회신", "OUTBOUND", "RESOLVED", "MEDIUM", 1, "192.168.1.54", "phishing@fake-bank.com"),

            createIssue("대용량 파일 무단 발송", "500MB 파일을 승인 없이 외부로 발송",
                "대용량 파일 사후관리 문제", "OUTBOUND", "PENDING", "LOW", 1, "192.168.1.92", "storage@external.com"),

            createIssue("망분리 환경 파일 전송 시도", "내부망에서 외부망으로 첨부파일 전송 시도 탐지",
                "망분리 환경에서 대용량 첨부파일 발송 문제", "OUTBOUND", "REVIEW", "MEDIUM", 1, "10.0.0.55", "external@partner.com")
        );

        repository.saveAll(sampleIssues);
    }

    private SecurityIssue createIssue(String title, String description, String category,
                                     String type, String status, String severity,
                                     int affectedEmails, String sourceIp, String targetEmail) {
        SecurityIssue issue = new SecurityIssue();
        issue.setTitle(title);
        issue.setDescription(description);
        issue.setCategory(category);
        issue.setType(type);
        issue.setStatus(status);
        issue.setSeverity(severity);
        issue.setAffectedEmails(affectedEmails);
        issue.setSourceIp(sourceIp);
        issue.setTargetEmail(targetEmail);
        issue.setDetectedDate(LocalDateTime.now().minusHours(new Random().nextInt(48)));
        return issue;
    }
}
