# 🔒 이메일 보안 모니터링 시스템

회사 면접 포트폴리오용 이메일 보안 이슈 모니터링 대시보드 웹 애플리케이션

## 📋 프로젝트 개요

송수신 이메일의 보안 이슈를 실시간으로 모니터링하고 관리할 수 있는 웹 기반 대시보드 시스템입니다.

### 주요 기능

- ✅ **JWT 인증/인가**: 토큰 기반 보안 인증 시스템 (로그인/회원가입)
- ✅ **역할 기반 접근 제어**: ADMIN/MANAGER/USER 권한 관리
- ✅ **실시간 대시보드**: 전체/수신/발신 이슈 통계 및 시각화
- ✅ **차트 시각화**: 유형별/심각도별 막대 그래프로 데이터 한눈에 파악
- ✅ **Top 3 긴급 이슈**: 심각도 기준 상위 3개 이슈 강조
- ✅ **이슈 목록 관리**: 상태별/심각도별 필터링 및 분류
- ✅ **페이징 처리**: 이슈 목록을 5개 단위로 나눠서 효율적으로 표시
- ✅ **보안 이슈 등록**: 새로운 보안 이슈 직접 등록 기능
- ✅ **상태 변경 기능**: 대기/검토중/해결/긴급 상태 전환
- ✅ **상세 페이지**: 이슈별 상세 정보 및 권장 조치 안내
- ✅ **최적화된 레이아웃**: 첫 화면에서 스크롤 없이 모든 정보 확인 가능
- ✅ **반응형 디자인**: 모바일/태블릿/데스크톱 대응

## 🛠 기술 스택

### Frontend
- **React 18** - Hooks 기반 컴포넌트
- **React Router v6** - 페이지 라우팅
- **Axios** - REST API 통신 (async/await)
- **Vite** - 빌드 도구
- **CSS Grid** - 반응형 레이아웃

### Backend
- **Spring Boot 3.1.5** - REST API 서버
- **Spring Security** - 인증/인가 프레임워크
- **JWT (JSON Web Token)** - 토큰 기반 인증 (jjwt 0.11.5)
- **JPA/Hibernate** - ORM
- **Maven** - 의존성 관리
- **MSSQL Server** - 데이터베이스
- **BCrypt** - 비밀번호 암호화

## 📂 프로젝트 구조

```
Email_security_solution_1/
├── backend/                        # Spring Boot Backend
│   ├── src/main/java/com/security/email/
│   │   ├── controller/            # REST Controllers
│   │   │   ├── SecurityIssueController.java
│   │   │   └── AuthController.java           # 🔐 인증 API
│   │   ├── service/               # Business Logic
│   │   │   ├── SecurityIssueService.java
│   │   │   ├── AuthService.java              # 🔐 인증 서비스
│   │   │   └── CustomUserDetailsService.java # 🔐 사용자 로딩
│   │   ├── repository/            # JPA Repositories
│   │   │   ├── SecurityIssueRepository.java
│   │   │   └── UserRepository.java           # 🔐 사용자 DB
│   │   ├── entity/                # JPA Entities
│   │   │   ├── SecurityIssue.java
│   │   │   └── User.java                     # 🔐 사용자 엔티티
│   │   ├── dto/                   # Data Transfer Objects
│   │   │   ├── SecurityIssueDTO.java
│   │   │   ├── DashboardStats.java
│   │   │   ├── StatusUpdateRequest.java
│   │   │   ├── LoginRequest.java             # 🔐 로그인 DTO
│   │   │   ├── SignupRequest.java            # 🔐 회원가입 DTO
│   │   │   └── AuthResponse.java             # 🔐 인증 응답 DTO
│   │   ├── security/              # 🔐 보안 설정
│   │   │   └── JwtAuthenticationFilter.java  # JWT 필터
│   │   ├── util/                  # 🔐 유틸리티
│   │   │   └── JwtTokenProvider.java         # JWT 토큰 처리
│   │   └── config/                # 설정
│   │       ├── CorsConfig.java
│   │       └── SecurityConfig.java           # 🔐 Spring Security 설정
│   ├── src/main/resources/
│   │   └── application.properties # DB 및 JWT 설정
│   ├── init_database.sql          # DB 초기화 스크립트 (최초 1회 실행) ⭐
│   └── pom.xml
│
├── frontend/                       # React Frontend
│   ├── src/
│   │   ├── components/            # React Components
│   │   │   ├── Dashboard.jsx     # 메인 대시보드
│   │   │   ├── IssueDetail.jsx   # 상세 페이지
│   │   │   ├── IssueRegister.jsx # 이슈 등록
│   │   │   ├── Login.jsx         # 🔐 로그인 페이지
│   │   │   ├── Register.jsx      # 🔐 회원가입 페이지
│   │   │   ├── PrivateRoute.jsx  # 🔐 인증 라우트 보호
│   │   │   ├── StatCard.jsx      # 통계 카드
│   │   │   ├── StatusBadge.jsx   # 상태 뱃지
│   │   │   └── ChartSection.jsx  # 차트 컴포넌트
│   │   ├── services/
│   │   │   └── api.js            # Axios API 설정 (JWT interceptor 포함)
│   │   ├── styles/               # CSS 파일
│   │   │   ├── Auth.css          # 🔐 인증 페이지 스타일
│   │   │   └── App.css           # 메인 스타일
│   │   ├── App.jsx               # 라우팅 (인증 통합)
│   │   └── index.jsx
│   ├── package.json
│   └── vite.config.js
│
├── .gitignore                     # Git 제외 파일 목록
├── QUICK_START.md                 # 빠른 시작 가이드 ⭐
└── README.md                      # 본 파일
```

## 🚀 실행 방법

### 사전 요구사항

- **Java 17** 이상
- **Node.js 18** 이상
- **Maven 3.6** 이상
- **MSSQL Server**

### 1. 데이터베이스 초기화 (중요!)

**방법 1: SQL 스크립트 실행 (권장)**

제공된 SQL 파일로 데이터베이스, 테이블, 샘플 데이터를 한 번에 생성:

```bash
# SQL Server Management Studio (SSMS)에서:
# 1. backend/init_database.sql 파일 열기
# 2. F5 또는 실행 버튼 클릭

# 또는 커맨드라인에서:
sqlcmd -S localhost -U sa -P 1234 -i backend/init_database.sql
```

**방법 2: 수동 설정**

MSSQL Server에서 데이터베이스만 생성 (JPA가 테이블 자동 생성):

```sql
CREATE DATABASE EmailSecurityDB;
```

그런 다음 `backend/src/main/resources/application.properties`에서 DB 정보 확인:

```properties
spring.datasource.username=sa
spring.datasource.password=1234
```

비밀번호를 변경했다면 수정하세요.

### 2. 백엔드 실행

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

백엔드 서버가 `http://localhost:8080`에서 실행됩니다.

### 3. 프론트엔드 실행

새 터미널을 열고:

```bash
cd frontend
npm install
npm run dev
```

프론트엔드가 `http://localhost:3000`에서 실행됩니다.

### 4. 확인

브라우저에서 `http://localhost:3000` 접속하면 로그인 페이지로 자동 이동합니다.

**테스트 계정으로 로그인**:

| 역할 | 사용자명 | 비밀번호 | 권한 |
|------|----------|----------|------|
| 관리자 | `admin` | `admin123` | 모든 기능 접근 가능 |
| 매니저 | `manager` | `manager123` | 이슈 상태 변경 가능 |
| 사용자 | `user` | `user123` | 조회만 가능 |

로그인하면 대시보드로 이동합니다.

**참고**: `backend/init_database.sql`을 최초 1회 실행하면 다음이 생성됩니다:
- security_issues 테이블 (샘플 데이터 14건)
- users 테이블 (테스트 계정 3개: admin, manager, user)

데이터는 서버 재시작 후에도 유지됩니다 (`spring.jpa.hibernate.ddl-auto=update` 설정).

## 📊 API 엔드포인트

### AuthController (인증 API)

| Method | Endpoint | 인증 필요 | Description |
|--------|----------|----------|-------------|
| POST | `/api/auth/login` | ❌ | 로그인 (JWT 토큰 발급) |
| POST | `/api/auth/signup` | ❌ | 회원가입 |

### SecurityIssueController (보안 이슈 API)

| Method | Endpoint | 인증 필요 | Description |
|--------|----------|----------|-------------|
| GET | `/api/issues` | ✅ | 전체 이슈 조회 |
| GET | `/api/issues/{id}` | ✅ | 특정 이슈 조회 |
| GET | `/api/issues/top3` | ✅ | Top 3 긴급 이슈 조회 |
| GET | `/api/issues/stats` | ✅ | 대시보드 통계 조회 |
| POST | `/api/issues` | ✅ | 새 이슈 등록 |
| PUT | `/api/issues/{id}/status` | ✅ | 이슈 상태 변경 |
| POST | `/api/issues/init-sample` | ✅ | 샘플 데이터 초기화 |

### 요청/응답 예시

**로그인**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# 응답
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "type": "Bearer",
  "username": "admin",
  "email": "admin@company.com",
  "role": "ROLE_ADMIN"
}
```

**인증이 필요한 API 호출**
```bash
curl -X GET http://localhost:8080/api/issues \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

**이슈 상태 변경**
```bash
curl -X PUT http://localhost:8080/api/issues/1/status \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status":"RESOLVED"}'
```

## 🎨 UI/UX 특징

### 색상 시스템

**상태별 색상**
- 🟠 **PENDING** (대기): `#FFA726`
- 🔵 **REVIEW** (검토중): `#42A5F5`
- 🟢 **RESOLVED** (해결): `#66BB6A`
- 🔴 **CRITICAL** (긴급): `#EF5350`

**심각도 색상**
- 🟢 **LOW**: `#AED581`
- 🟡 **MEDIUM**: `#FFD54F`
- 🟠 **HIGH**: `#FF8A65`
- 🔴 **CRITICAL**: `#E57373`

### 반응형 디자인

- **Desktop** (1024px+): 완전한 테이블 뷰
- **Tablet** (768px-1023px): 간소화된 테이블
- **Mobile** (<768px): 카드 기반 레이아웃

## 🔧 보안 이슈 카테고리

### 수신메일 보안이슈 (INBOUND)
1. 대량 스팸 메일 공격
2. 불법 릴레이 서버 사용
3. 바이러스, 랜섬웨어 등 악성코드 공격
4. 개인정보 탈취 피싱 사이트 공격
5. 헤더 위·변조 및 유사 도메인 사칭 메일

### 발신메일 보안이슈 (OUTBOUND)
1. 악성 메일 회신
2. 바이러스 URL 공유
3. 기업 내부 정보 유출 및 오발송 사고
4. 대용량 파일 사후관리 문제
5. 망분리 환경에서 대용량 첨부파일 발송 문제

## 🌟 주요 기능 시연

### 1. 인증 시스템
- **로그인 페이지**: 사용자명/비밀번호 입력, 에러 메시지 표시
- **회원가입 페이지**: 사용자명/이메일/비밀번호 입력, 중복 검증
- **자동 인증 관리**:
  - JWT 토큰을 localStorage에 저장
  - axios interceptor로 모든 API 요청에 자동으로 토큰 추가
  - 401 에러 발생 시 자동 로그아웃 및 로그인 페이지 이동
- **Protected Routes**: 인증되지 않은 사용자의 대시보드 접근 차단
- **사용자 정보 표시**: 헤더에 사용자명 표시 및 로그아웃 버튼

### 2. 대시보드
- **통계 카드**: 4개의 통계 카드 (전체/수신/발신/긴급 이슈 수)
- **차트 시각화**:
  - 유형별(수신/발신) 막대 그래프
  - 심각도별(낮음/보통/높음/긴급) 막대 그래프
- **Top 3 긴급 이슈**: 최우선 이슈 카드 (클릭 시 상세 페이지 이동)
- **필터링 기능**:
  - 상태별 필터 (전체/대기/검토중/해결/긴급)
  - 심각도별 필터 드롭다운 (전체/낮음/보통/높음/긴급)
- **이슈 목록 테이블**:
  - 제목과 카테고리 가로 배치로 가독성 향상
  - 페이징 처리 (5개씩 표시)
  - 클릭 시 상세 페이지 이동
  - 드롭다운으로 즉시 상태 변경
- **최적화된 UI**: 컴팩트한 디자인으로 스크롤 없이 전체 정보 확인 가능

### 3. 상세 페이지
- 이슈 전체 정보 표시
- 상태 변경 드롭다운
- 기술 정보 (출발지 IP, 대상 이메일)
- 권장 조치 사항
- 액션 버튼 (검토 시작/해결 완료/긴급 표시)

### 4. 보안 이슈 등록
- 새로운 보안 이슈 등록 폼
- 유형(INBOUND/OUTBOUND)에 따른 동적 카테고리 필터링
- 자동으로 PENDING 상태 설정
- 입력 검증 및 에러 처리

## 🔐 확장 가능성

프로젝트는 다음 기능으로 확장 가능하도록 설계되었습니다:

- [x] **JWT 인증/인가 시스템** (토큰 기반 인증, 자동 토큰 갱신 구현 완료)
- [x] **사용자 관리** (역할 기반 접근 제어: ADMIN/MANAGER/USER 구현 완료)
- [x] **차트 및 그래프 시각화** (유형별/심각도별 막대 그래프 구현 완료)
- [ ] 실시간 알림 (WebSocket)
- [ ] 이슈 자동 분류 (AI/ML)
- [ ] 이메일 서버 로그 연동
- [ ] PDF 보고서 생성

## 📝 데이터 모델

### User Entity (사용자)

| 필드 | 타입 | 설명 |
|------|------|------|
| id | Long | 사용자 고유 ID (PK) |
| username | String | 사용자명 (고유) |
| password | String | 비밀번호 (BCrypt 암호화) |
| email | String | 이메일 (고유) |
| role | String | ROLE_USER/ROLE_MANAGER/ROLE_ADMIN |
| createdAt | LocalDateTime | 계정 생성 시각 |
| updatedAt | LocalDateTime | 계정 수정 시각 |

### SecurityIssue Entity (보안 이슈)

| 필드 | 타입 | 설명 |
|------|------|------|
| id | Long | 이슈 고유 ID (PK) |
| title | String | 이슈 제목 |
| description | String | 상세 설명 |
| category | String | 보안 카테고리 |
| type | String | INBOUND/OUTBOUND |
| status | String | PENDING/REVIEW/RESOLVED/CRITICAL |
| severity | String | LOW/MEDIUM/HIGH/CRITICAL |
| detectedDate | LocalDateTime | 탐지 시각 |
| resolvedDate | LocalDateTime | 해결 시각 |
| affectedEmails | Integer | 영향받은 이메일 수 |
| sourceIp | String | 출발지 IP |
| targetEmail | String | 대상 이메일 |

## 🐛 트러블슈팅

### 로그인이 안 될 때
- 데이터베이스 초기화 확인: `backend/init_database.sql` 실행 여부
- 비밀번호가 BCrypt로 해싱되어 있는지 확인
- 테스트 계정: admin/admin123, manager/manager123, user/user123

### 401 Unauthorized 에러
- JWT 토큰이 만료되었을 수 있음 (다시 로그인)
- Authorization 헤더 형식 확인: `Bearer {token}`
- localStorage에 토큰이 저장되어 있는지 확인

### CORS 오류 발생 시
- `backend/src/main/java/com/security/email/config/CorsConfig.java`에서 프론트엔드 URL 확인
- 기본값: `http://localhost:3000`, `http://localhost:5173`
- SecurityConfig에서 CORS 설정 확인

### 데이터베이스 연결 오류
- MSSQL Server 실행 확인
- `application.properties`의 접속 정보 확인
- 방화벽 설정 확인 (포트 1433)
- users 테이블이 생성되어 있는지 확인

### 샘플 데이터가 없을 때
```bash
# 인증이 필요한 엔드포인트이므로 로그인 후 토큰 사용
curl -X POST http://localhost:8080/api/issues/init-sample \
  -H "Authorization: Bearer {JWT_TOKEN}"
```

## 👨‍💻 개발자

이 프로젝트는 면접 포트폴리오용으로 개발되었습니다.

## 📄 라이선스

This project is for portfolio demonstration purposes.

---

**프로젝트 개발 일자**: 2025년
**발표 준비**: 1일 스프린트로 개발
