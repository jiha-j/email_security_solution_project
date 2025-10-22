package com.security.email.controller;

import com.security.email.dto.AuthResponse;
import com.security.email.dto.LoginRequest;
import com.security.email.dto.SignupRequest;
import com.security.email.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest loginRequest) {
        try {
            log.info("Login attempt for user: {}", loginRequest.getUsername());
            AuthResponse response = authService.login(loginRequest);
            log.info("Login successful for user: {}", loginRequest.getUsername());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Login failed for user: {}. Error: {}", loginRequest.getUsername(), e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@RequestBody SignupRequest signupRequest) {
        try {
            log.info("Signup attempt for user: {}", signupRequest.getUsername());
            AuthResponse response = authService.signup(signupRequest);
            log.info("Signup successful for user: {}", signupRequest.getUsername());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            log.error("Signup failed for user: {}. Error: {}", signupRequest.getUsername(), e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }
}
