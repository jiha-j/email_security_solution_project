package com.security.email.controller;

import com.security.email.dto.DashboardStats;
import com.security.email.dto.SecurityIssueDTO;
import com.security.email.dto.StatusUpdateRequest;
import com.security.email.service.SecurityIssueService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/issues")
@RequiredArgsConstructor
public class SecurityIssueController {

    private final SecurityIssueService service;

    @GetMapping
    public ResponseEntity<List<SecurityIssueDTO>> getAllIssues() {
        return ResponseEntity.ok(service.getAllIssues());
    }

    @GetMapping("/{id}")
    public ResponseEntity<SecurityIssueDTO> getIssueById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getIssueById(id));
    }

    @GetMapping("/top3")
    public ResponseEntity<List<SecurityIssueDTO>> getTop3Issues() {
        return ResponseEntity.ok(service.getTop3Issues());
    }

    @GetMapping("/stats")
    public ResponseEntity<DashboardStats> getDashboardStats() {
        return ResponseEntity.ok(service.getDashboardStats());
    }

    @PostMapping
    public ResponseEntity<SecurityIssueDTO> createIssue(@RequestBody SecurityIssueDTO issueDTO) {
        return ResponseEntity.ok(service.createIssue(issueDTO));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<SecurityIssueDTO> updateStatus(
            @PathVariable Long id,
            @RequestBody StatusUpdateRequest request) {
        return ResponseEntity.ok(service.updateStatus(id, request.getStatus()));
    }

    @PostMapping("/init-sample")
    public ResponseEntity<String> initSampleData() {
        service.initSampleData();
        return ResponseEntity.ok("Sample data initialized successfully");
    }
}
