# 📘 이메일 보안 모니터링 시스템 - 로직 흐름 완전 분석

## 목차
1. [전체 아키텍처 개요](#1-전체-아키텍처-개요)
2. [데이터베이스 스키마](#2-데이터베이스-스키마)
3. [로그인 프로세스 완전 분석](#3-로그인-프로세스-완전-분석)
4. [대시보드 로딩 프로세스](#4-대시보드-로딩-프로세스)
5. [이슈 조회 프로세스](#5-이슈-조회-프로세스)
6. [이슈 등록 프로세스](#6-이슈-등록-프로세스)
7. [이슈 상태 변경 프로세스](#7-이슈-상태-변경-프로세스)
8. [JWT 토큰 처리 메커니즘](#8-jwt-토큰-처리-메커니즘)
9. [에러 핸들링 흐름](#9-에러-핸들링-흐름)
10. [Protected Route 동작 원리](#10-protected-route-동작-원리)

---

## 1. 전체 아키텍처 개요

### 계층 구조
```
┌─────────────────────────────────────────────────┐
│              Browser (User)                      │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│         Frontend (React + Vite)                  │
│  - Components (JSX)                              │
│  - Services (api.js - Axios)                     │
│  - State (localStorage + React State)            │
└────────────────┬────────────────────────────────┘
                 │ HTTP Requests (REST API)
                 │ Authorization: Bearer {JWT}
                 ▼
┌─────────────────────────────────────────────────┐
│         Backend (Spring Boot)                    │
│                                                  │
│  ┌─────────────────────────────────────┐        │
│  │  Controller Layer                   │        │
│  │  - @RestController                  │        │
│  │  - @RequestMapping                  │        │
│  │  - Request/Response 처리             │        │
│  └──────────────┬──────────────────────┘        │
│                 │                                │
│                 ▼                                │
│  ┌─────────────────────────────────────┐        │
│  │  Security Layer                     │        │
│  │  - JwtAuthenticationFilter          │        │
│  │  - SecurityConfig                   │        │
│  │  - JWT 검증 및 인증 처리             │        │
│  └──────────────┬──────────────────────┘        │
│                 │                                │
│                 ▼                                │
│  ┌─────────────────────────────────────┐        │
│  │  Service Layer                      │        │
│  │  - @Service                         │        │
│  │  - 비즈니스 로직 처리                │        │
│  │  - DTO ↔ Entity 변환                │        │
│  └──────────────┬──────────────────────┘        │
│                 │                                │
│                 ▼                                │
│  ┌─────────────────────────────────────┐        │
│  │  Repository Layer                   │        │
│  │  - @Repository                      │        │
│  │  - JpaRepository 상속                │        │
│  │  - CRUD 메서드 제공                  │        │
│  └──────────────┬──────────────────────┘        │
│                 │                                │
└─────────────────┼────────────────────────────────┘
                  │ JDBC
                  ▼
┌─────────────────────────────────────────────────┐
│         Database (MSSQL Server)                  │
│  - users 테이블                                  │
│  - security_issues 테이블                        │
└─────────────────────────────────────────────────┘
```

---

## 2. 데이터베이스 스키마

### 2.1 users 테이블

```sql
CREATE TABLE users (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    password NVARCHAR(100) NOT NULL,  -- BCrypt 해시
    email NVARCHAR(100) NOT NULL UNIQUE,
    role NVARCHAR(20) NOT NULL,       -- ROLE_USER, ROLE_MANAGER, ROLE_ADMIN
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);
```

**샘플 데이터:**
```
id | username | password                                           | email                | role         | created_at          | updated_at
---|----------|----------------------------------------------------|--------------------- |--------------|---------------------|---------------------
1  | admin    | $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68... | admin@company.com    | ROLE_ADMIN   | 2025-01-22 10:00:00 | 2025-01-22 10:00:00
2  | manager  | $2a$10$YJKPmWLOickgx2ZMRZoMyeLbR3qj8NsHLK0d1fLb2H... | manager@company.com  | ROLE_MANAGER | 2025-01-22 10:00:00 | 2025-01-22 10:00:00
3  | user     | $2a$10$xn3LI/AJqicNat2R6zgx5.ExvZrLI5e5mHnTWZLdL1... | user@company.com     | ROLE_USER    | 2025-01-22 10:00:00 | 2025-01-22 10:00:00
```

**비밀번호 암호화:**
- 원본: `admin123`
- BCrypt 해시: `$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy`
- 알고리즘: BCrypt (Salt 포함, 10 rounds)

### 2.2 security_issues 테이블

```sql
CREATE TABLE security_issues (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(1000),
    category NVARCHAR(100) NOT NULL,
    type NVARCHAR(20) NOT NULL,           -- INBOUND, OUTBOUND
    status NVARCHAR(20) NOT NULL,         -- PENDING, REVIEW, RESOLVED, CRITICAL
    severity NVARCHAR(20) NOT NULL,       -- LOW, MEDIUM, HIGH, CRITICAL
    detected_date DATETIME2 NOT NULL,
    resolved_date DATETIME2,
    affected_emails INT,
    source_ip NVARCHAR(50),
    target_email NVARCHAR(200)
);

-- 인덱스
CREATE INDEX IDX_SecurityIssue_Status ON security_issues(status);
CREATE INDEX IDX_SecurityIssue_Type ON security_issues(type);
CREATE INDEX IDX_SecurityIssue_Severity ON security_issues(severity);
CREATE INDEX IDX_SecurityIssue_DetectedDate ON security_issues(detected_date DESC);
```

**샘플 데이터 예시:**
```
id | title                          | category                      | type     | status   | severity | detected_date       | affected_emails | source_ip      | target_email
---|--------------------------------|-------------------------------|----------|----------|----------|---------------------|-----------------|----------------|---------------------
1  | 대량 스팸 메일 탐지 (1,250건) | 대량 스팸 메일 공격           | INBOUND  | CRITICAL | CRITICAL | 2025-01-22 08:00:00 | 1250            | 203.142.78.91  | admin@company.com
2  | 피싱 사이트 링크 포함 메일    | 개인정보 탈취 피싱 사이트 공격 | INBOUND  | PENDING  | HIGH     | 2025-01-22 05:00:00 | 15              | 185.220.101.45 | hr@company.com
3  | 고객 정보 포함 메일 외부 발송 | 기업 내부 정보 유출           | OUTBOUND | CRITICAL | CRITICAL | 2025-01-22 07:00:00 | 500             | 192.168.1.105  | external@gmail.com
```

---

## 3. 로그인 프로세스 완전 분석

### 3.1 Frontend: 로그인 버튼 클릭

**파일: `frontend/src/components/Login.jsx`**

```javascript
const handleLogin = async (e) => {
  e.preventDefault();
  setError('');
  setLoading(true);

  try {
    // 1. authApi.login 호출
    const response = await authApi.login({
      username: formData.username,  // "admin"
      password: formData.password   // "admin123"
    });

    // 2. 응답 데이터 구조
    // response = {
    //   token: "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwNjA...",
    //   type: "Bearer",
    //   username: "admin",
    //   email: "admin@company.com",
    //   role: "ROLE_ADMIN"
    // }

    // 3. localStorage에 저장
    localStorage.setItem('token', response.token);
    localStorage.setItem('user', JSON.stringify({
      username: response.username,
      email: response.email,
      role: response.role
    }));

    // 4. 대시보드로 이동
    navigate('/');
  } catch (err) {
    setError('로그인 실패: 사용자명 또는 비밀번호를 확인하세요');
  } finally {
    setLoading(false);
  }
};
```

**전송되는 데이터:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

### 3.2 Frontend: API 호출

**파일: `frontend/src/services/api.js`**

```javascript
export const authApi = {
  login: async (loginData) => {
    // 1. POST 요청 전송
    const response = await api.post('/auth/login', loginData);
    // api.post는 내부적으로:
    // - URL: http://localhost:8080/api/auth/login
    // - Method: POST
    // - Headers: { 'Content-Type': 'application/json' }
    // - Body: JSON.stringify(loginData)

    // 2. 응답 데이터 반환
    return response.data;
  }
};
```

**HTTP 요청:**
```
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

### 3.3 Backend: Controller 진입점

**파일: `backend/src/main/java/com/security/email/controller/AuthController.java`**

```java
@PostMapping("/login")
public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest loginRequest) {
    // 1. 로그 출력
    log.info("Login attempt for user: {}", loginRequest.getUsername());
    // 출력: "Login attempt for user: admin"

    // 2. loginRequest 객체 데이터
    // loginRequest.getUsername() = "admin"
    // loginRequest.getPassword() = "admin123" (평문)

    try {
        // 3. AuthService.login 호출
        AuthResponse response = authService.login(loginRequest);

        // 4. 성공 로그
        log.info("Login successful for user: {}", loginRequest.getUsername());

        // 5. 200 OK + AuthResponse 반환
        return ResponseEntity.ok(response);
    } catch (Exception e) {
        // 실패 시 로그 및 400 Bad Request
        log.error("Login failed for user: {}. Error: {}",
                  loginRequest.getUsername(), e.getMessage(), e);
        return ResponseEntity.badRequest().build();
    }
}
```

**LoginRequest DTO 구조:**
```java
@Data
public class LoginRequest {
    private String username;  // "admin"
    private String password;  // "admin123"
}
```

### 3.4 Backend: Service 비즈니스 로직

**파일: `backend/src/main/java/com/security/email/service/AuthService.java`**

```java
public AuthResponse login(LoginRequest request) {
    // 1. Spring Security AuthenticationManager를 통한 인증
    Authentication authentication = authenticationManager.authenticate(
        new UsernamePasswordAuthenticationToken(
            request.getUsername(),  // "admin"
            request.getPassword()   // "admin123"
        )
    );

    // 인증 과정 (내부):
    // a. CustomUserDetailsService.loadUserByUsername("admin") 호출
    // b. DB에서 username="admin"인 User 엔티티 조회
    // c. User 엔티티의 password 필드 (BCrypt 해시) 가져옴
    // d. BCrypt로 입력된 "admin123"과 DB의 해시 비교
    // e. 일치하면 Authentication 객체 생성, 불일치하면 예외 발생

    // 2. SecurityContext에 인증 정보 저장
    SecurityContextHolder.getContext().setAuthentication(authentication);

    // 3. JWT 토큰 생성
    String jwt = jwtTokenProvider.generateToken(authentication);
    // jwt = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwNjA3..."

    // 4. UserDetails에서 사용자 정보 추출
    UserDetails userDetails = (UserDetails) authentication.getPrincipal();
    // userDetails.getUsername() = "admin"
    // userDetails.getAuthorities() = [ROLE_ADMIN]

    // 5. DB에서 User 엔티티 조회하여 이메일 가져오기
    User user = userRepository.findByUsername(userDetails.getUsername())
        .orElseThrow(() -> new RuntimeException("User not found"));
    // user.getEmail() = "admin@company.com"
    // user.getRole() = UserRole.ROLE_ADMIN

    // 6. AuthResponse DTO 생성
    return new AuthResponse(
        jwt,                            // "eyJhbGciOiJIUzUxMiJ9..."
        "Bearer",                       // 토큰 타입
        userDetails.getUsername(),      // "admin"
        user.getEmail(),                // "admin@company.com"
        user.getRole().name()           // "ROLE_ADMIN"
    );
}
```

**AuthResponse DTO 구조:**
```java
@Data
@AllArgsConstructor
public class AuthResponse {
    private String token;      // JWT 토큰
    private String type;       // "Bearer"
    private String username;   // "admin"
    private String email;      // "admin@company.com"
    private String role;       // "ROLE_ADMIN"
}
```

### 3.5 Backend: CustomUserDetailsService (인증 시 호출)

**파일: `backend/src/main/java/com/security/email/service/CustomUserDetailsService.java`**

```java
@Override
public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
    // 1. DB에서 username으로 User 엔티티 조회
    User user = userRepository.findByUsername(username)
        .orElseThrow(() ->
            new UsernameNotFoundException("User not found: " + username)
        );

    // 조회된 User 엔티티:
    // user.getId() = 1L
    // user.getUsername() = "admin"
    // user.getPassword() = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"
    // user.getEmail() = "admin@company.com"
    // user.getRole() = UserRole.ROLE_ADMIN

    // 2. Spring Security UserDetails 객체로 변환
    return org.springframework.security.core.userdetails.User.builder()
        .username(user.getUsername())           // "admin"
        .password(user.getPassword())           // BCrypt 해시
        .authorities(user.getRole().name())     // "ROLE_ADMIN"
        .build();

    // 반환되는 UserDetails:
    // username = "admin"
    // password = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"
    // authorities = [ROLE_ADMIN]
}
```

### 3.6 Backend: JWT 토큰 생성

**파일: `backend/src/main/java/com/security/email/util/JwtTokenProvider.java`**

```java
public String generateToken(Authentication authentication) {
    // 1. UserDetails 추출
    UserDetails userDetails = (UserDetails) authentication.getPrincipal();
    // userDetails.getUsername() = "admin"

    return generateTokenFromUsername(userDetails.getUsername());
}

public String generateTokenFromUsername(String username) {
    // 1. 현재 시각
    Date now = new Date();
    // now = "2025-01-22T10:30:00Z"

    // 2. 만료 시각 (24시간 후)
    Date expiryDate = new Date(now.getTime() + jwtExpiration);
    // jwtExpiration = 86400000ms (24시간)
    // expiryDate = "2025-01-23T10:30:00Z"

    // 3. JWT 토큰 생성
    return Jwts.builder()
        .setSubject(username)              // sub: "admin"
        .setIssuedAt(now)                  // iat: 1706086200
        .setExpiration(expiryDate)         // exp: 1706172600
        .signWith(getSigningKey(), SignatureAlgorithm.HS512)  // HS512 서명
        .compact();

    // 생성된 JWT 토큰 구조:
    // Header: { "alg": "HS512" }
    // Payload: {
    //   "sub": "admin",
    //   "iat": 1706086200,
    //   "exp": 1706172600
    // }
    // Signature: HMAC-SHA512(base64(header) + "." + base64(payload), secret)
}

private SecretKey getSigningKey() {
    // 1. application.properties에서 Base64 인코딩된 키 가져옴
    // jwtSecret = "hAW0zfdAxyq7vBAgW9oCgF+zBuOCs3DKhXArmtpe3M3b//VeKmUzI0hWC5DR6NXfUXBvkL6yd4iowkUpp/ZHYg=="

    // 2. Base64 디코딩하여 원본 64바이트 키 복원
    byte[] keyBytes = Base64.getDecoder().decode(jwtSecret);
    // keyBytes.length = 64 (512비트)

    // 3. HMAC-SHA512용 SecretKey 생성
    return Keys.hmacShaKeyFor(keyBytes);
}
```

**생성된 JWT 토큰 예시:**
```
eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwNjA4NjIwMCwiZXhwIjoxNzA2MTcyNjAwfQ.Xk2D3F4G5H6I7J8K9L0M1N2O3P4Q5R6S7T8U9V0W1X2Y3Z4A5B6C7D8E9F0G1H2I3J4K5L6M7N8O9P0Q1R2S3T
```

**JWT 토큰 디코딩:**
```json
// Header
{
  "alg": "HS512"
}

// Payload
{
  "sub": "admin",
  "iat": 1706086200,
  "exp": 1706172600
}

// Signature (검증용)
```

### 3.7 Backend: HTTP 응답 반환

**HTTP 응답:**
```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwNjA4NjIwMCwiZXhwIjoxNzA2MTcyNjAwfQ.Xk2D3F4G5H6I7J8K9L0M1N2O3P4Q5R6S7T8U9V0W1X2Y3Z4A5B6C7D8E9F0G1H2I3J4K5L6M7N8O9P0Q1R2S3T",
  "type": "Bearer",
  "username": "admin",
  "email": "admin@company.com",
  "role": "ROLE_ADMIN"
}
```

### 3.8 Frontend: 응답 처리 및 저장

**localStorage에 저장되는 데이터:**
```javascript
// 1. 토큰 저장
localStorage.setItem('token', 'eyJhbGciOiJIUzUxMiJ9...');

// 2. 사용자 정보 저장
localStorage.setItem('user', JSON.stringify({
  username: 'admin',
  email: 'admin@company.com',
  role: 'ROLE_ADMIN'
}));
```

**브라우저 개발자 도구에서 확인:**
```
Application → Local Storage → http://localhost:3000

Key: token
Value: eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwNjA4NjIwMCwiZXhwIjoxNzA2MTcyNjAwfQ.Xk2D3F4G5H6I7J8K9L0M1N2O3P4Q5R6S7T8U9V0W1X2Y3Z4A5B6C7D8E9F0G1H2I3J4K5L6M7N8O9P0Q1R2S3T

Key: user
Value: {"username":"admin","email":"admin@company.com","role":"ROLE_ADMIN"}
```

---

## 4. 대시보드 로딩 프로세스

### 4.1 Frontend: Dashboard 컴포넌트 마운트

**파일: `frontend/src/components/Dashboard.jsx`**

```javascript
useEffect(() => {
  loadDashboard();
}, []);

const loadDashboard = async () => {
  try {
    // 1. 병렬로 3개 API 호출
    const [issuesData, statsData, top3Data] = await Promise.all([
      issueApi.getAllIssues(),      // GET /api/issues
      issueApi.getDashboardStats(), // GET /api/issues/stats
      issueApi.getTop3Issues()      // GET /api/issues/top3
    ]);

    // 2. 상태 업데이트
    setIssues(issuesData);           // 전체 이슈 목록 (배열)
    setStats(statsData);             // 통계 데이터 (객체)
    setTop3Issues(top3Data);         // Top 3 이슈 (배열)

    // 3. 필터링된 이슈 초기화
    setFilteredIssues(issuesData);
  } catch (error) {
    console.error('Failed to load dashboard:', error);
  } finally {
    setLoading(false);
  }
};
```

### 4.2 Frontend: API 호출 (with JWT Token)

**파일: `frontend/src/services/api.js`**

```javascript
// Axios Request Interceptor가 자동으로 JWT 토큰 추가
api.interceptors.request.use(
  (config) => {
    // 1. localStorage에서 토큰 가져오기
    const token = localStorage.getItem('token');
    // token = "eyJhbGciOiJIUzUxMiJ9..."

    // 2. Authorization 헤더에 추가
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // 3. 수정된 config 반환
    return config;
  },
  (error) => Promise.reject(error)
);

// API 호출
export const issueApi = {
  getAllIssues: async () => {
    const response = await api.get('/issues');
    return response.data;
  },

  getDashboardStats: async () => {
    const response = await api.get('/issues/stats');
    return response.data;
  },

  getTop3Issues: async () => {
    const response = await api.get('/issues/top3');
    return response.data;
  }
};
```

**HTTP 요청 예시 (getAllIssues):**
```
GET http://localhost:8080/api/issues
Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwNjA4NjIwMCwiZXhwIjoxNzA2MTcyNjAwfQ.Xk2D3F4G5H6I7J8K9L0M1N2O3P4Q5R6S7T8U9V0W1X2Y3Z4A5B6C7D8E9F0G1H2I3J4K5L6M7N8O9P0Q1R2S3T
Content-Type: application/json
```

### 4.3 Backend: Security Filter (JWT 검증)

**파일: `backend/src/main/java/com/security/email/security/JwtAuthenticationFilter.java`**

```java
@Override
protected void doFilterInternal(HttpServletRequest request,
                                 HttpServletResponse response,
                                 FilterChain filterChain) {
    try {
        // 1. Authorization 헤더에서 JWT 토큰 추출
        String jwt = getJwtFromRequest(request);
        // jwt = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwNjA4NjIwMCwiZXhwIjoxNzA2MTcyNjAwfQ..."

        // 2. 토큰이 있고 유효한지 검증
        if (jwt != null && jwtTokenProvider.validateToken(jwt)) {
            // 3. 토큰에서 사용자명 추출
            String username = jwtTokenProvider.getUsernameFromToken(jwt);
            // username = "admin"

            // 4. DB에서 UserDetails 로드
            UserDetails userDetails = customUserDetailsService.loadUserByUsername(username);
            // userDetails.getUsername() = "admin"
            // userDetails.getAuthorities() = [ROLE_ADMIN]

            // 5. Authentication 객체 생성
            UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                    userDetails,
                    null,
                    userDetails.getAuthorities()
                );

            // 6. SecurityContext에 인증 정보 저장
            SecurityContextHolder.getContext().setAuthentication(authentication);
            // 이제 Controller에서 SecurityContextHolder.getContext().getAuthentication()으로 접근 가능
        }
    } catch (Exception ex) {
        logger.error("Could not set user authentication", ex);
    }

    // 7. 다음 필터로 진행
    filterChain.doFilter(request, response);
}

private String getJwtFromRequest(HttpServletRequest request) {
    // Authorization 헤더 가져오기
    String bearerToken = request.getHeader("Authorization");
    // bearerToken = "Bearer eyJhbGciOiJIUzUxMiJ9..."

    // "Bearer " 접두사 제거
    if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
        return bearerToken.substring(7);
    }

    return null;
}
```

**JWT 토큰 검증:**
```java
public boolean validateToken(String token) {
    try {
        // JWT 파싱 및 서명 검증
        Jwts.parserBuilder()
            .setSigningKey(getSigningKey())  // 동일한 Secret Key로 검증
            .build()
            .parseClaimsJws(token);          // 서명 불일치 시 예외 발생

        return true;
    } catch (SecurityException ex) {
        System.err.println("Invalid JWT signature");
    } catch (MalformedJwtException ex) {
        System.err.println("Invalid JWT token");
    } catch (ExpiredJwtException ex) {
        System.err.println("Expired JWT token");
    } catch (UnsupportedJwtException ex) {
        System.err.println("Unsupported JWT token");
    } catch (IllegalArgumentException ex) {
        System.err.println("JWT claims string is empty");
    }

    return false;
}

public String getUsernameFromToken(String token) {
    // JWT 토큰 파싱
    Claims claims = Jwts.parserBuilder()
        .setSigningKey(getSigningKey())
        .build()
        .parseClaimsJws(token)
        .getBody();

    // claims 내용:
    // {
    //   "sub": "admin",
    //   "iat": 1706086200,
    //   "exp": 1706172600
    // }

    // subject (사용자명) 반환
    return claims.getSubject();  // "admin"
}
```

### 4.4 Backend: Controller - 통계 조회

**파일: `backend/src/main/java/com/security/email/controller/SecurityIssueController.java`**

```java
@GetMapping("/stats")
public ResponseEntity<DashboardStats> getDashboardStats() {
    // 1. Service 호출
    DashboardStats stats = service.getDashboardStats();

    // 2. 200 OK + DashboardStats 반환
    return ResponseEntity.ok(stats);
}
```

### 4.5 Backend: Service - 통계 계산

**파일: `backend/src/main/java/com/security/email/service/SecurityIssueService.java`**

```java
public DashboardStats getDashboardStats() {
    // 1. 전체 이슈 조회 (DB 쿼리)
    List<SecurityIssue> allIssues = repository.findAll();
    // SQL: SELECT * FROM security_issues
    // 결과: 14개 SecurityIssue 엔티티 리스트

    // allIssues[0]:
    // id=1, title="대량 스팸 메일 탐지", type=INBOUND, status=CRITICAL, severity=CRITICAL, ...

    // allIssues[1]:
    // id=2, title="피싱 사이트 링크 포함", type=INBOUND, status=PENDING, severity=HIGH, ...

    // ... (총 14개)

    // 2. 전체 이슈 수
    long total = allIssues.size();  // 14

    // 3. 수신 메일 이슈 수 (type=INBOUND)
    long inbound = allIssues.stream()
        .filter(issue -> issue.getType() == SecurityIssue.IssueType.INBOUND)
        .count();
    // inbound = 8

    // 4. 발신 메일 이슈 수 (type=OUTBOUND)
    long outbound = allIssues.stream()
        .filter(issue -> issue.getType() == SecurityIssue.IssueType.OUTBOUND)
        .count();
    // outbound = 6

    // 5. 긴급 이슈 수 (status=CRITICAL)
    long critical = allIssues.stream()
        .filter(issue -> issue.getStatus() == SecurityIssue.IssueStatus.CRITICAL)
        .count();
    // critical = 3

    // 6. 유형별 통계 계산
    Map<String, Long> typeStats = allIssues.stream()
        .collect(Collectors.groupingBy(
            issue -> issue.getType().name(),
            Collectors.counting()
        ));
    // typeStats = { "INBOUND": 8, "OUTBOUND": 6 }

    // 7. 심각도별 통계 계산
    Map<String, Long> severityStats = allIssues.stream()
        .collect(Collectors.groupingBy(
            issue -> issue.getSeverity().name(),
            Collectors.counting()
        ));
    // severityStats = { "LOW": 1, "MEDIUM": 5, "HIGH": 4, "CRITICAL": 4 }

    // 8. DashboardStats DTO 생성 및 반환
    return DashboardStats.builder()
        .totalIssues(total)              // 14
        .inboundIssues(inbound)          // 8
        .outboundIssues(outbound)        // 6
        .criticalIssues(critical)        // 3
        .typeStats(typeStats)            // {"INBOUND":8, "OUTBOUND":6}
        .severityStats(severityStats)    // {"LOW":1, "MEDIUM":5, "HIGH":4, "CRITICAL":4}
        .build();
}
```

**DashboardStats DTO 구조:**
```java
@Data
@Builder
public class DashboardStats {
    private long totalIssues;           // 14
    private long inboundIssues;         // 8
    private long outboundIssues;        // 6
    private long criticalIssues;        // 3
    private Map<String, Long> typeStats;      // {"INBOUND":8, "OUTBOUND":6}
    private Map<String, Long> severityStats;  // {"LOW":1, "MEDIUM":5, "HIGH":4, "CRITICAL":4}
}
```

### 4.6 Backend: HTTP 응답

**HTTP 응답 (getDashboardStats):**
```json
{
  "totalIssues": 14,
  "inboundIssues": 8,
  "outboundIssues": 6,
  "criticalIssues": 3,
  "typeStats": {
    "INBOUND": 8,
    "OUTBOUND": 6
  },
  "severityStats": {
    "LOW": 1,
    "MEDIUM": 5,
    "HIGH": 4,
    "CRITICAL": 4
  }
}
```

### 4.7 Backend: Controller - Top 3 이슈 조회

```java
@GetMapping("/top3")
public ResponseEntity<List<SecurityIssueDTO>> getTop3Issues() {
    return ResponseEntity.ok(service.getTop3Issues());
}
```

### 4.8 Backend: Service - Top 3 이슈 조회

```java
public List<SecurityIssueDTO> getTop3Issues() {
    // 1. 심각도 순 정렬하여 상위 3개 조회
    List<SecurityIssue> issues = repository.findAll();
    // 총 14개

    // 2. 심각도 순서 정의
    // CRITICAL > HIGH > MEDIUM > LOW

    // 3. 정렬 및 상위 3개 추출
    List<SecurityIssue> top3 = issues.stream()
        .sorted((a, b) -> {
            // 심각도 비교
            int severityCompare = compareSeverity(b.getSeverity(), a.getSeverity());
            if (severityCompare != 0) return severityCompare;

            // 심각도가 같으면 탐지 날짜 내림차순
            return b.getDetectedDate().compareTo(a.getDetectedDate());
        })
        .limit(3)
        .collect(Collectors.toList());

    // top3 결과:
    // [0]: id=1, title="대량 스팸 메일 탐지", severity=CRITICAL, status=CRITICAL
    // [1]: id=3, title="의심스러운 첨부파일 탐지", severity=CRITICAL, status=CRITICAL
    // [2]: id=6, title="고객 정보 포함 메일 외부 발송", severity=CRITICAL, status=CRITICAL

    // 4. Entity → DTO 변환
    return top3.stream()
        .map(this::convertToDTO)
        .collect(Collectors.toList());
}

private int compareSeverity(Severity s1, Severity s2) {
    // 심각도 순서 값
    Map<Severity, Integer> order = Map.of(
        Severity.CRITICAL, 4,
        Severity.HIGH, 3,
        Severity.MEDIUM, 2,
        Severity.LOW, 1
    );

    return order.get(s1).compareTo(order.get(s2));
}
```

**HTTP 응답 (getTop3Issues):**
```json
[
  {
    "id": 1,
    "title": "대량 스팸 메일 탐지 (1,250건)",
    "description": "단일 IP에서 1시간 내 1,250건의 스팸 메일 발송 탐지",
    "category": "대량 스팸 메일 공격",
    "type": "INBOUND",
    "status": "CRITICAL",
    "severity": "CRITICAL",
    "detectedDate": "2025-01-22T08:00:00",
    "affectedEmails": 1250,
    "sourceIp": "203.142.78.91",
    "targetEmail": "admin@company.com"
  },
  {
    "id": 3,
    "title": "의심스러운 첨부파일 탐지",
    "description": "ransomware.exe 파일이 첨부된 메일 차단",
    "category": "바이러스, 랜섬웨어 등 악성코드 공격",
    "type": "INBOUND",
    "status": "CRITICAL",
    "severity": "CRITICAL",
    "detectedDate": "2025-01-22T09:00:00",
    "affectedEmails": 3,
    "sourceIp": "91.203.45.122",
    "targetEmail": "finance@company.com"
  },
  {
    "id": 6,
    "title": "고객 정보 포함 메일 외부 발송",
    "description": "개인정보 500건이 포함된 엑셀 파일 외부 전송",
    "category": "기업 내부 정보 유출 및 오발송 사고",
    "type": "OUTBOUND",
    "status": "CRITICAL",
    "severity": "CRITICAL",
    "detectedDate": "2025-01-22T07:00:00",
    "affectedEmails": 500,
    "sourceIp": "192.168.1.105",
    "targetEmail": "external-partner@gmail.com"
  }
]
```

### 4.9 Backend: Controller - 전체 이슈 조회

```java
@GetMapping
public ResponseEntity<List<SecurityIssueDTO>> getAllIssues() {
    return ResponseEntity.ok(service.getAllIssues());
}
```

### 4.10 Backend: Service - 전체 이슈 조회

```java
public List<SecurityIssueDTO> getAllIssues() {
    // 1. DB에서 전체 이슈 조회
    List<SecurityIssue> issues = repository.findAll();
    // SQL: SELECT * FROM security_issues
    // 결과: 14개 SecurityIssue 엔티티

    // 2. Entity → DTO 변환
    return issues.stream()
        .map(this::convertToDTO)
        .collect(Collectors.toList());
}

private SecurityIssueDTO convertToDTO(SecurityIssue entity) {
    // Entity → DTO 매핑
    return SecurityIssueDTO.builder()
        .id(entity.getId())
        .title(entity.getTitle())
        .description(entity.getDescription())
        .category(entity.getCategory())
        .type(entity.getType().name())           // Enum → String
        .status(entity.getStatus().name())       // Enum → String
        .severity(entity.getSeverity().name())   // Enum → String
        .detectedDate(entity.getDetectedDate())
        .resolvedDate(entity.getResolvedDate())
        .affectedEmails(entity.getAffectedEmails())
        .sourceIp(entity.getSourceIp())
        .targetEmail(entity.getTargetEmail())
        .build();
}
```

**SecurityIssueDTO 구조:**
```java
@Data
@Builder
public class SecurityIssueDTO {
    private Long id;
    private String title;
    private String description;
    private String category;
    private String type;          // "INBOUND" 또는 "OUTBOUND"
    private String status;        // "PENDING", "REVIEW", "RESOLVED", "CRITICAL"
    private String severity;      // "LOW", "MEDIUM", "HIGH", "CRITICAL"
    private LocalDateTime detectedDate;
    private LocalDateTime resolvedDate;
    private Integer affectedEmails;
    private String sourceIp;
    private String targetEmail;
}
```

### 4.11 Frontend: 응답 처리 및 렌더링

```javascript
// Promise.all 결과
const [issuesData, statsData, top3Data] = await Promise.all([...]);

// issuesData = [14개 이슈 객체 배열]
// statsData = { totalIssues: 14, inboundIssues: 8, ... }
// top3Data = [3개 긴급 이슈 배열]

// 상태 업데이트
setIssues(issuesData);
setStats(statsData);
setTop3Issues(top3Data);
setFilteredIssues(issuesData);

// 렌더링
return (
  <>
    {/* 통계 카드 4개 */}
    <StatCard title="전체 이슈" value={stats.totalIssues} />      {/* 14 */}
    <StatCard title="수신 메일" value={stats.inboundIssues} />    {/* 8 */}
    <StatCard title="발신 메일" value={stats.outboundIssues} />   {/* 6 */}
    <StatCard title="긴급 이슈" value={stats.criticalIssues} />   {/* 3 */}

    {/* 차트 */}
    <ChartSection
      typeStats={stats.typeStats}           // {"INBOUND":8, "OUTBOUND":6}
      severityStats={stats.severityStats}   // {"LOW":1, "MEDIUM":5, "HIGH":4, "CRITICAL":4}
    />

    {/* Top 3 긴급 이슈 */}
    {top3Issues.map(issue => (
      <IssueCard key={issue.id} issue={issue} />
    ))}

    {/* 전체 이슈 테이블 */}
    <table>
      {filteredIssues.map(issue => (
        <tr key={issue.id}>
          <td>{issue.title}</td>
          <td><StatusBadge status={issue.status} /></td>
          ...
        </tr>
      ))}
    </table>
  </>
);
```

---

## 5. 이슈 조회 프로세스

### 5.1 Frontend: 이슈 클릭

```javascript
// Dashboard.jsx
<tr onClick={() => navigate(`/issue/${issue.id}`)}>
  <td>{issue.title}</td>
  ...
</tr>
```

**URL 변경:**
```
http://localhost:3000 → http://localhost:3000/issue/1
```

### 5.2 Frontend: IssueDetail 컴포넌트 마운트

**파일: `frontend/src/components/IssueDetail.jsx`**

```javascript
const { id } = useParams();  // id = "1" (문자열)

useEffect(() => {
  loadIssue();
}, [id]);

const loadIssue = async () => {
  try {
    // GET /api/issues/1
    const data = await issueApi.getIssueById(id);
    setIssue(data);
  } catch (error) {
    console.error('Failed to load issue:', error);
  } finally {
    setLoading(false);
  }
};
```

### 5.3 Backend: Controller - 특정 이슈 조회

```java
@GetMapping("/{id}")
public ResponseEntity<SecurityIssueDTO> getIssueById(@PathVariable Long id) {
    // id = 1L
    return ResponseEntity.ok(service.getIssueById(id));
}
```

### 5.4 Backend: Service - 특정 이슈 조회

```java
public SecurityIssueDTO getIssueById(Long id) {
    // 1. DB에서 id로 조회
    SecurityIssue issue = repository.findById(id)
        .orElseThrow(() -> new RuntimeException("Issue not found: " + id));

    // SQL: SELECT * FROM security_issues WHERE id = 1

    // 조회된 Entity:
    // id=1
    // title="대량 스팸 메일 탐지 (1,250건)"
    // description="단일 IP에서 1시간 내 1,250건의 스팸 메일 발송 탐지"
    // category="대량 스팸 메일 공격"
    // type=INBOUND
    // status=CRITICAL
    // severity=CRITICAL
    // detectedDate=2025-01-22T08:00:00
    // affectedEmails=1250
    // sourceIp="203.142.78.91"
    // targetEmail="admin@company.com"

    // 2. Entity → DTO 변환
    return convertToDTO(issue);
}
```

**HTTP 응답:**
```json
{
  "id": 1,
  "title": "대량 스팸 메일 탐지 (1,250건)",
  "description": "단일 IP에서 1시간 내 1,250건의 스팸 메일 발송 탐지",
  "category": "대량 스팸 메일 공격",
  "type": "INBOUND",
  "status": "CRITICAL",
  "severity": "CRITICAL",
  "detectedDate": "2025-01-22T08:00:00",
  "resolvedDate": null,
  "affectedEmails": 1250,
  "sourceIp": "203.142.78.91",
  "targetEmail": "admin@company.com"
}
```

### 5.5 Frontend: 상세 정보 렌더링

```javascript
return (
  <div className="issue-detail">
    <h2>{issue.title}</h2>
    <StatusBadge status={issue.status} />

    <div className="info-grid">
      <div>카테고리: {issue.category}</div>
      <div>유형: {issue.type === 'INBOUND' ? '수신메일' : '발신메일'}</div>
      <div>심각도: {issue.severity}</div>
      <div>탐지 시각: {new Date(issue.detectedDate).toLocaleString()}</div>
      <div>영향받은 이메일: {issue.affectedEmails}건</div>
      <div>출발지 IP: {issue.sourceIp}</div>
      <div>대상 이메일: {issue.targetEmail}</div>
    </div>

    <div className="description">
      <h3>상세 설명</h3>
      <p>{issue.description}</p>
    </div>
  </div>
);
```

---

## 6. 이슈 등록 프로세스

### 6.1 Frontend: IssueRegister 폼 제출

**파일: `frontend/src/components/IssueRegister.jsx`**

```javascript
const [formData, setFormData] = useState({
  title: '',
  description: '',
  category: '',
  type: 'INBOUND',
  severity: 'MEDIUM',
  affectedEmails: 0,
  sourceIp: '',
  targetEmail: ''
});

const handleSubmit = async (e) => {
  e.preventDefault();

  try {
    // 1. 이슈 데이터 생성
    const issueData = {
      ...formData,
      status: 'PENDING',  // 자동으로 PENDING 상태
      detectedDate: new Date().toISOString()
    };

    // issueData 예시:
    // {
    //   title: "새로운 피싱 메일 탐지",
    //   description: "은행 사칭 피싱 링크 포함",
    //   category: "개인정보 탈취 피싱 사이트 공격",
    //   type: "INBOUND",
    //   status: "PENDING",
    //   severity: "HIGH",
    //   detectedDate: "2025-01-22T11:30:00.000Z",
    //   affectedEmails: 10,
    //   sourceIp: "123.45.67.89",
    //   targetEmail: "test@company.com"
    // }

    // 2. POST /api/issues
    await issueApi.createIssue(issueData);

    // 3. 대시보드로 이동
    navigate('/');
  } catch (error) {
    console.error('Failed to create issue:', error);
    setError('이슈 등록에 실패했습니다');
  }
};
```

### 6.2 Frontend: API 호출

```javascript
export const issueApi = {
  createIssue: async (issueData) => {
    const response = await api.post('/issues', issueData);
    return response.data;
  }
};
```

**HTTP 요청:**
```
POST http://localhost:8080/api/issues
Authorization: Bearer eyJhbGciOiJIUzUxMiJ9...
Content-Type: application/json

{
  "title": "새로운 피싱 메일 탐지",
  "description": "은행 사칭 피싱 링크 포함",
  "category": "개인정보 탈취 피싱 사이트 공격",
  "type": "INBOUND",
  "status": "PENDING",
  "severity": "HIGH",
  "detectedDate": "2025-01-22T11:30:00.000Z",
  "affectedEmails": 10,
  "sourceIp": "123.45.67.89",
  "targetEmail": "test@company.com"
}
```

### 6.3 Backend: Controller - 이슈 생성

```java
@PostMapping
public ResponseEntity<SecurityIssueDTO> createIssue(@RequestBody SecurityIssueDTO issueDTO) {
    // issueDTO 데이터:
    // title = "새로운 피싱 메일 탐지"
    // description = "은행 사칭 피싱 링크 포함"
    // category = "개인정보 탈취 피싱 사이트 공격"
    // type = "INBOUND"
    // status = "PENDING"
    // severity = "HIGH"
    // detectedDate = 2025-01-22T11:30:00
    // affectedEmails = 10
    // sourceIp = "123.45.67.89"
    // targetEmail = "test@company.com"

    return ResponseEntity.ok(service.createIssue(issueDTO));
}
```

### 6.4 Backend: Service - 이슈 생성

```java
public SecurityIssueDTO createIssue(SecurityIssueDTO dto) {
    // 1. DTO → Entity 변환
    SecurityIssue issue = SecurityIssue.builder()
        .title(dto.getTitle())
        .description(dto.getDescription())
        .category(dto.getCategory())
        .type(SecurityIssue.IssueType.valueOf(dto.getType()))        // String → Enum
        .status(SecurityIssue.IssueStatus.valueOf(dto.getStatus()))  // String → Enum
        .severity(SecurityIssue.Severity.valueOf(dto.getSeverity())) // String → Enum
        .detectedDate(dto.getDetectedDate())
        .affectedEmails(dto.getAffectedEmails())
        .sourceIp(dto.getSourceIp())
        .targetEmail(dto.getTargetEmail())
        .build();

    // 2. DB에 저장
    SecurityIssue savedIssue = repository.save(issue);

    // SQL: INSERT INTO security_issues
    //      (title, description, category, type, status, severity, detected_date,
    //       affected_emails, source_ip, target_email)
    //      VALUES ('새로운 피싱 메일 탐지', '은행 사칭 피싱 링크 포함', ...)

    // savedIssue:
    // id = 15 (자동 생성)
    // title = "새로운 피싱 메일 탐지"
    // ...

    // 3. Entity → DTO 변환하여 반환
    return convertToDTO(savedIssue);
}
```

**HTTP 응답:**
```json
{
  "id": 15,
  "title": "새로운 피싱 메일 탐지",
  "description": "은행 사칭 피싱 링크 포함",
  "category": "개인정보 탈취 피싱 사이트 공격",
  "type": "INBOUND",
  "status": "PENDING",
  "severity": "HIGH",
  "detectedDate": "2025-01-22T11:30:00",
  "resolvedDate": null,
  "affectedEmails": 10,
  "sourceIp": "123.45.67.89",
  "targetEmail": "test@company.com"
}
```

---

## 7. 이슈 상태 변경 프로세스

### 7.1 Frontend: 드롭다운에서 상태 선택

**파일: `frontend/src/components/Dashboard.jsx`**

```javascript
const handleStatusChange = async (issueId, newStatus) => {
  // issueId = 2
  // newStatus = "REVIEW"

  try {
    // 1. PUT /api/issues/2/status
    await issueApi.updateStatus(issueId, newStatus);

    // 2. 로컬 상태 업데이트 (UI 즉시 반영)
    setIssues(prevIssues =>
      prevIssues.map(issue =>
        issue.id === issueId
          ? { ...issue, status: newStatus }
          : issue
      )
    );

    // 변경 전:
    // issues = [
    //   { id: 1, status: 'CRITICAL', ... },
    //   { id: 2, status: 'PENDING', ... },  <- 여기
    //   { id: 3, status: 'CRITICAL', ... }
    // ]

    // 변경 후:
    // issues = [
    //   { id: 1, status: 'CRITICAL', ... },
    //   { id: 2, status: 'REVIEW', ... },   <- 변경됨
    //   { id: 3, status: 'CRITICAL', ... }
    // ]

    // 3. 필터링된 목록도 업데이트
    setFilteredIssues(prevFiltered =>
      prevFiltered.map(issue =>
        issue.id === issueId
          ? { ...issue, status: newStatus }
          : issue
      )
    );
  } catch (error) {
    console.error('Failed to update status:', error);
  }
};
```

### 7.2 Frontend: API 호출

```javascript
export const issueApi = {
  updateStatus: async (id, status) => {
    const response = await api.put(`/issues/${id}/status`, { status });
    return response.data;
  }
};
```

**HTTP 요청:**
```
PUT http://localhost:8080/api/issues/2/status
Authorization: Bearer eyJhbGciOiJIUzUxMiJ9...
Content-Type: application/json

{
  "status": "REVIEW"
}
```

### 7.3 Backend: Controller - 상태 업데이트

```java
@PutMapping("/{id}/status")
public ResponseEntity<SecurityIssueDTO> updateStatus(
        @PathVariable Long id,
        @RequestBody StatusUpdateRequest request) {

    // id = 2L
    // request.getStatus() = "REVIEW"

    return ResponseEntity.ok(service.updateStatus(id, request.getStatus()));
}
```

**StatusUpdateRequest DTO:**
```java
@Data
public class StatusUpdateRequest {
    private String status;  // "REVIEW"
}
```

### 7.4 Backend: Service - 상태 업데이트

```java
@Transactional
public SecurityIssueDTO updateStatus(Long id, String status) {
    // 1. DB에서 이슈 조회
    SecurityIssue issue = repository.findById(id)
        .orElseThrow(() -> new RuntimeException("Issue not found: " + id));

    // SQL: SELECT * FROM security_issues WHERE id = 2

    // 조회된 Entity (변경 전):
    // id = 2
    // title = "피싱 사이트 링크 포함 메일"
    // status = PENDING
    // ...

    // 2. 상태 업데이트
    issue.setStatus(SecurityIssue.IssueStatus.valueOf(status));
    // status = REVIEW (String → Enum 변환)

    // 3. RESOLVED로 변경되면 해결 시각 자동 설정
    if (status.equals("RESOLVED") && issue.getResolvedDate() == null) {
        issue.setResolvedDate(LocalDateTime.now());
    }

    // 4. DB에 저장 (UPDATE)
    SecurityIssue updatedIssue = repository.save(issue);

    // SQL: UPDATE security_issues
    //      SET status = 'REVIEW', resolved_date = NULL
    //      WHERE id = 2

    // updatedIssue (변경 후):
    // id = 2
    // title = "피싱 사이트 링크 포함 메일"
    // status = REVIEW
    // resolvedDate = null
    // ...

    // 5. Entity → DTO 변환하여 반환
    return convertToDTO(updatedIssue);
}
```

**HTTP 응답:**
```json
{
  "id": 2,
  "title": "피싱 사이트 링크 포함 메일",
  "description": "은행 사칭 피싱 사이트로 유도하는 링크 발견",
  "category": "개인정보 탈취 피싱 사이트 공격",
  "type": "INBOUND",
  "status": "REVIEW",
  "severity": "HIGH",
  "detectedDate": "2025-01-22T05:00:00",
  "resolvedDate": null,
  "affectedEmails": 15,
  "sourceIp": "185.220.101.45",
  "targetEmail": "hr@company.com"
}
```

### 7.5 Frontend: UI 업데이트

```javascript
// 상태가 즉시 반영됨
<StatusBadge status={issue.status} />
// "PENDING" → "REVIEW" 색상 변경
```

---

## 8. JWT 토큰 처리 메커니즘

### 8.1 JWT 토큰 구조

**전체 토큰:**
```
eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwNjA4NjIwMCwiZXhwIjoxNzA2MTcyNjAwfQ.Xk2D3F4G5H6I7J8K9L0M1N2O3P4Q5R6S7T8U9V0W1X2Y3Z4A5B6C7D8E9F0G1H2I3J4K5L6M7N8O9P0Q1R2S3T
```

**3부분으로 구성 (`.`으로 구분):**

1. **Header (헤더):**
```
eyJhbGciOiJIUzUxMiJ9

디코딩:
{
  "alg": "HS512"  // HMAC-SHA512 알고리즘
}
```

2. **Payload (페이로드):**
```
eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwNjA4NjIwMCwiZXhwIjoxNzA2MTcyNjAwfQ

디코딩:
{
  "sub": "admin",           // Subject (사용자명)
  "iat": 1706086200,        // Issued At (발급 시각, Unix timestamp)
  "exp": 1706172600         // Expiration (만료 시각, Unix timestamp)
}
```

3. **Signature (서명):**
```
Xk2D3F4G5H6I7J8K9L0M1N2O3P4Q5R6S7T8U9V0W1X2Y3Z4A5B6C7D8E9F0G1H2I3J4K5L6M7N8O9P0Q1R2S3T

계산 방식:
HMACSHA512(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret  // "hAW0zfdAxyq7vBAgW9oCgF+zBuOCs3DKhXArmtpe3M3b//VeKmUzI0hWC5DR6NXfUXBvkL6yd4iowkUpp/ZHYg=="
)
```

### 8.2 토큰 검증 과정

```java
public boolean validateToken(String token) {
    try {
        // 1. 토큰 파싱
        Jws<Claims> claimsJws = Jwts.parserBuilder()
            .setSigningKey(getSigningKey())  // Secret Key 설정
            .build()
            .parseClaimsJws(token);          // 파싱 및 검증

        // 검증 과정:
        // a. 토큰을 Header, Payload, Signature로 분리
        // b. Header + Payload를 Secret Key로 다시 서명 계산
        // c. 계산한 서명과 토큰의 Signature 비교
        //    - 일치: 토큰이 변조되지 않음
        //    - 불일치: SignatureException 발생
        // d. exp (만료 시각) 확인
        //    - 현재 시각 < exp: 유효
        //    - 현재 시각 >= exp: ExpiredJwtException 발생

        return true;
    } catch (ExpiredJwtException ex) {
        // 토큰 만료
        return false;
    } catch (SignatureException ex) {
        // 서명 불일치 (변조됨)
        return false;
    } catch (MalformedJwtException ex) {
        // 형식 오류
        return false;
    }

    return false;
}
```

### 8.3 Axios Interceptor 동작

**Request Interceptor (요청 전):**
```javascript
api.interceptors.request.use(
  (config) => {
    // 1. localStorage에서 토큰 가져오기
    const token = localStorage.getItem('token');

    // 2. 토큰이 있으면 Authorization 헤더에 추가
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // 변경된 config:
    // {
    //   url: '/issues',
    //   method: 'GET',
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Authorization': 'Bearer eyJhbGciOiJIUzUxMiJ9...'
    //   }
    // }

    return config;
  },
  (error) => Promise.reject(error)
);
```

**Response Interceptor (응답 후):**
```javascript
api.interceptors.response.use(
  (response) => {
    // 정상 응답 (200, 201 등)
    return response;
  },
  (error) => {
    // 에러 응답
    if (error.response?.status === 401) {
      // 1. 401 Unauthorized 감지
      //    원인: 토큰 만료, 토큰 변조, 토큰 없음

      // 2. localStorage 정리
      localStorage.removeItem('token');
      localStorage.removeItem('user');

      // 3. 로그인 페이지로 강제 이동
      window.location.href = '/login';
    }

    return Promise.reject(error);
  }
);
```

---

## 9. 에러 핸들링 흐름

### 9.1 인증 실패 시나리오

**시나리오 1: 잘못된 비밀번호**

```
Frontend:
  authApi.login({ username: 'admin', password: 'wrongpassword' })
    ↓
Backend:
  AuthenticationManager.authenticate()
    ↓
  CustomUserDetailsService.loadUserByUsername("admin")
    → User 조회 성공 (password = BCrypt 해시)
    ↓
  BCrypt.matches("wrongpassword", 해시)
    → false
    ↓
  BadCredentialsException 발생
    ↓
  AuthController catch 블록
    → ResponseEntity.badRequest().build()
    ↓
  HTTP 400 Bad Request
    ↓
Frontend:
  catch (error)
    → setError('로그인 실패: 사용자명 또는 비밀번호를 확인하세요')
```

**시나리오 2: 존재하지 않는 사용자**

```
Frontend:
  authApi.login({ username: 'nonexistent', password: 'password' })
    ↓
Backend:
  CustomUserDetailsService.loadUserByUsername("nonexistent")
    ↓
  userRepository.findByUsername("nonexistent")
    → Optional.empty()
    ↓
  UsernameNotFoundException 발생
    ↓
  HTTP 400 Bad Request
    ↓
Frontend:
  setError('로그인 실패: 사용자명 또는 비밀번호를 확인하세요')
```

### 9.2 토큰 만료 시나리오

```
Frontend:
  issueApi.getAllIssues()
    ↓
  Request Interceptor
    → Authorization: Bearer {만료된_토큰}
    ↓
Backend:
  JwtAuthenticationFilter.doFilterInternal()
    ↓
  jwtTokenProvider.validateToken(만료된_토큰)
    ↓
  Jwts.parserBuilder().parseClaimsJws(토큰)
    → ExpiredJwtException 발생
    ↓
  validateToken() returns false
    ↓
  SecurityContext에 인증 정보 없음
    ↓
  Controller 접근 시 Spring Security 체크
    → 인증 정보 없음
    ↓
  HTTP 401 Unauthorized
    ↓
Frontend:
  Response Interceptor
    → error.response.status === 401 감지
    ↓
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  window.location.href = '/login'
```

### 9.3 네트워크 오류 시나리오

```
Frontend:
  issueApi.getAllIssues()
    ↓
  axios.get('http://localhost:8080/api/issues')
    ↓
  Backend 서버 다운 또는 네트워크 오류
    ↓
  axios catch 블록
    → error.code = 'ERR_NETWORK'
    → error.message = 'Network Error'
    ↓
Component catch 블록:
  console.error('Failed to load issues:', error)
  setError('서버에 연결할 수 없습니다')
```

---

## 10. Protected Route 동작 원리

### 10.1 PrivateRoute 컴포넌트

**파일: `frontend/src/components/PrivateRoute.jsx`**

```javascript
const PrivateRoute = ({ children }) => {
  // 1. localStorage에서 토큰 확인
  const token = localStorage.getItem('token');

  // token이 있는 경우:
  // token = "eyJhbGciOiJIUzUxMiJ9..."

  // token이 없는 경우:
  // token = null

  // 2. 토큰 존재 여부에 따라 렌더링
  if (!token) {
    // 토큰 없음 → 로그인 페이지로 리다이렉트
    return <Navigate to="/login" replace />;
  }

  // 토큰 있음 → children (보호된 컴포넌트) 렌더링
  return children;
};
```

### 10.2 App.jsx 라우팅 구조

```javascript
<Routes>
  {/* Public routes - 인증 불필요 */}
  <Route path="/login" element={<Login />} />
  <Route path="/signup" element={<Register />} />

  {/* Protected routes - 인증 필요 */}
  <Route path="/" element={
    <PrivateRoute>
      <AppHeader />
      <Dashboard />
    </PrivateRoute>
  } />

  <Route path="/issue/:id" element={
    <PrivateRoute>
      <AppHeader />
      <IssueDetail />
    </PrivateRoute>
  } />

  <Route path="/register" element={
    <PrivateRoute>
      <AppHeader />
      <IssueRegister />
    </PrivateRoute>
  } />
</Routes>
```

### 10.3 접근 시나리오

**시나리오 1: 로그인 전 대시보드 접근 시도**

```
1. 사용자가 http://localhost:3000/ 접속
   ↓
2. App.jsx 라우팅
   → path="/" 매칭
   ↓
3. PrivateRoute 렌더링
   ↓
4. localStorage.getItem('token')
   → null
   ↓
5. <Navigate to="/login" replace />
   ↓
6. URL 변경: http://localhost:3000/login
   ↓
7. Login 컴포넌트 렌더링
```

**시나리오 2: 로그인 후 대시보드 접근**

```
1. 사용자가 http://localhost:3000/ 접속
   ↓
2. PrivateRoute 렌더링
   ↓
3. localStorage.getItem('token')
   → "eyJhbGciOiJIUzUxMiJ9..."
   ↓
4. children 렌더링:
   - <AppHeader />
   - <Dashboard />
   ↓
5. Dashboard 마운트
   ↓
6. useEffect → loadDashboard()
   ↓
7. API 호출 (JWT 토큰 자동 포함)
   ↓
8. 데이터 로딩 및 화면 표시
```

---

## 11. 전체 데이터 흐름 요약

### 11.1 로그인부터 대시보드까지

```
[사용자 입력]
username: "admin"
password: "admin123"
  ↓
[Frontend - Login.jsx]
POST /api/auth/login
Body: { username, password }
  ↓
[Backend - AuthController]
AuthService.login(loginRequest)
  ↓
[Backend - AuthService]
1. AuthenticationManager.authenticate()
   → CustomUserDetailsService.loadUserByUsername()
   → DB 조회: SELECT * FROM users WHERE username='admin'
   → BCrypt 비교: matches("admin123", DB해시)
2. JwtTokenProvider.generateToken()
   → JWT 생성 (sub: "admin", exp: 24시간 후)
3. AuthResponse 반환
  ↓
[Frontend - Login.jsx]
1. localStorage.setItem('token', response.token)
2. localStorage.setItem('user', JSON.stringify({...}))
3. navigate('/')
  ↓
[Frontend - App.jsx]
PrivateRoute 체크
→ token 존재 확인
→ Dashboard 렌더링
  ↓
[Frontend - Dashboard.jsx]
useEffect → loadDashboard()
  ↓
Promise.all([
  GET /api/issues              (전체 이슈 14개)
  GET /api/issues/stats        (통계 데이터)
  GET /api/issues/top3         (Top 3 긴급 이슈)
])
  ↓
[Backend - JwtAuthenticationFilter]
1. Authorization 헤더에서 JWT 추출
2. validateToken() → 서명 검증 + 만료 확인
3. getUsernameFromToken() → "admin"
4. loadUserByUsername("admin") → UserDetails
5. SecurityContext에 Authentication 저장
  ↓
[Backend - SecurityIssueController]
GET /api/issues
→ service.getAllIssues()
→ repository.findAll()
→ SQL: SELECT * FROM security_issues
→ 14개 Entity 조회
→ Entity → DTO 변환
→ ResponseEntity.ok(dtoList)
  ↓
[Frontend - Dashboard.jsx]
1. setIssues(issuesData)
2. setStats(statsData)
3. setTop3Issues(top3Data)
4. 화면 렌더링:
   - 통계 카드 4개
   - 차트 2개
   - Top 3 카드 3개
   - 이슈 테이블 14개
```

### 11.2 데이터 구조 변환 흐름

```
[Database (MSSQL)]
security_issues 테이블 (14 rows)
  ↓
[JPA - SecurityIssue Entity]
@Entity
class SecurityIssue {
  Long id;
  String title;
  IssueType type;      // Enum
  IssueStatus status;  // Enum
  Severity severity;   // Enum
  ...
}
  ↓
[Service Layer - DTO 변환]
SecurityIssueDTO dto = SecurityIssueDTO.builder()
  .id(entity.getId())
  .type(entity.getType().name())    // Enum → String
  .status(entity.getStatus().name()) // Enum → String
  .build();
  ↓
[Controller - JSON 직렬화]
Jackson ObjectMapper
→ DTO → JSON
  ↓
[HTTP Response Body]
{
  "id": 1,
  "type": "INBOUND",
  "status": "CRITICAL",
  ...
}
  ↓
[Frontend - axios]
response.data (JavaScript Object)
  ↓
[React State]
const [issues, setIssues] = useState([]);
setIssues(response.data);
  ↓
[JSX Rendering]
{issues.map(issue => (
  <tr key={issue.id}>
    <td>{issue.title}</td>
    <td>{issue.status}</td>
  </tr>
))}
```

---

## 12. 성능 최적화 포인트

### 12.1 Frontend 최적화

```javascript
// 1. Promise.all로 병렬 API 호출
const [issuesData, statsData, top3Data] = await Promise.all([
  issueApi.getAllIssues(),
  issueApi.getDashboardStats(),
  issueApi.getTop3Issues()
]);
// 3개 API를 병렬로 호출하여 대기 시간 최소화

// 2. useMemo로 필터링 최적화
const filteredIssues = useMemo(() => {
  return issues.filter(issue => {
    if (statusFilter !== 'ALL' && issue.status !== statusFilter) return false;
    if (severityFilter !== 'ALL' && issue.severity !== severityFilter) return false;
    return true;
  });
}, [issues, statusFilter, severityFilter]);
// issues, statusFilter, severityFilter가 변경될 때만 재계산

// 3. 페이징으로 렌더링 최적화
const paginatedIssues = filteredIssues.slice(
  (currentPage - 1) * itemsPerPage,
  currentPage * itemsPerPage
);
// 5개씩만 렌더링하여 DOM 노드 수 최소화
```

### 12.2 Backend 최적화

```java
// 1. 인덱스 활용
@Query("SELECT i FROM SecurityIssue i WHERE i.status = :status")
List<SecurityIssue> findByStatus(@Param("status") IssueStatus status);
// IDX_SecurityIssue_Status 인덱스 사용

// 2. DTO Projection (필요한 필드만 조회)
@Query("SELECT new com.security.email.dto.SecurityIssueDTO(" +
       "i.id, i.title, i.status, i.severity) " +
       "FROM SecurityIssue i")
List<SecurityIssueDTO> findAllProjected();
// 모든 필드를 조회하지 않고 필요한 필드만 SELECT

// 3. @Transactional(readOnly = true)
@Transactional(readOnly = true)
public List<SecurityIssueDTO> getAllIssues() {
  // 읽기 전용 트랜잭션으로 성능 향상
}
```

### 12.3 JWT 토큰 최적화

```java
// 1. 토큰에 최소 정보만 포함
Jwts.builder()
  .setSubject(username)  // 사용자명만 포함
  .setIssuedAt(now)
  .setExpiration(expiryDate)
  .signWith(key, HS512)
  .compact();
// 불필요한 claim 제거하여 토큰 크기 최소화

// 2. Secret Key 캐싱
private SecretKey cachedKey;

private SecretKey getSigningKey() {
  if (cachedKey == null) {
    byte[] keyBytes = Base64.getDecoder().decode(jwtSecret);
    cachedKey = Keys.hmacShaKeyFor(keyBytes);
  }
  return cachedKey;
}
// Secret Key를 매번 생성하지 않고 캐싱
```

---

이 문서로 프로젝트의 모든 로직 흐름을 완벽하게 이해하실 수 있을 것입니다! 🚀
