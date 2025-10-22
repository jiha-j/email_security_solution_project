package com.security.email.service;

import com.security.email.dto.AuthResponse;
import com.security.email.dto.LoginRequest;
import com.security.email.dto.SignupRequest;
import com.security.email.entity.User;
import com.security.email.repository.UserRepository;
import com.security.email.util.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;

    @Transactional
    public AuthResponse login(LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getUsername(),
                        loginRequest.getPassword()
                )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        String token = jwtTokenProvider.generateToken(authentication);

        User user = userRepository.findByUsername(loginRequest.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        return new AuthResponse(token, user.getUsername(), user.getEmail(), user.getRole().name());
    }

    @Transactional
    public AuthResponse signup(SignupRequest signupRequest) {
        // 중복 체크
        if (userRepository.existsByUsername(signupRequest.getUsername())) {
            throw new RuntimeException("Username is already taken");
        }

        if (userRepository.existsByEmail(signupRequest.getEmail())) {
            throw new RuntimeException("Email is already in use");
        }

        // 사용자 생성
        User user = new User();
        user.setUsername(signupRequest.getUsername());
        user.setEmail(signupRequest.getEmail());
        user.setPassword(passwordEncoder.encode(signupRequest.getPassword()));

        // 역할 설정 (기본값은 USER)
        String roleStr = signupRequest.getRole();
        if (roleStr == null || roleStr.isEmpty()) {
            user.setRole(User.UserRole.ROLE_USER);
        } else {
            try {
                user.setRole(User.UserRole.valueOf("ROLE_" + roleStr.toUpperCase()));
            } catch (IllegalArgumentException e) {
                user.setRole(User.UserRole.ROLE_USER);
            }
        }

        userRepository.save(user);

        // 자동 로그인
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        signupRequest.getUsername(),
                        signupRequest.getPassword()
                )
        );

        String token = jwtTokenProvider.generateToken(authentication);

        return new AuthResponse(token, user.getUsername(), user.getEmail(), user.getRole().name());
    }
}
