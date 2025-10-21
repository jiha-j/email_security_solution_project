# 🔒 이메일 보안 모니터링 시스템

회사 면접 포트폴리오용 이메일 보안 이슈 모니터링 대시보드 웹 애플리케이션

## 📋 프로젝트 개요

송수신 이메일의 보안 이슈를 실시간으로 모니터링하고 관리할 수 있는 웹 기반 대시보드 시스템입니다.

### 주요 기능

- ✅ **실시간 대시보드**: 전체/수신/발신 이슈 통계 및 시각화
- ✅ **Top 3 긴급 이슈**: 심각도 기준 상위 3개 이슈 강조
- ✅ **이슈 목록 관리**: 상태별 필터링 및 분류
- ✅ **상태 변경 기능**: 대기/검토중/해결/긴급 상태 전환
- ✅ **상세 페이지**: 이슈별 상세 정보 및 권장 조치 안내
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
- **JPA/Hibernate** - ORM
- **Maven** - 의존성 관리
- **MSSQL Server** - 데이터베이스

## 📂 프로젝트 구조

```
Email_security_solution_1/
├── backend/                        # Spring Boot Backend
│   ├── src/main/java/com/security/email/
│   │   ├── controller/            # REST Controllers
│   │   ├── service/               # Business Logic
│   │   ├── repository/            # JPA Repositories
│   │   ├── entity/                # JPA Entities
│   │   ├── dto/                   # Data Transfer Objects
│   │   └── config/                # CORS Configuration
│   ├── src/main/resources/
│   │   └── application.properties
│   ├── init_database.sql          # DB 초기화 스크립트 ⭐
│   └── pom.xml
│
├── frontend/                       # React Frontend
│   ├── src/
│   │   ├── components/            # React Components
│   │   │   ├── Dashboard.jsx     # 메인 대시보드
│   │   │   ├── IssueDetail.jsx   # 상세 페이지
│   │   │   ├── StatCard.jsx      # 통계 카드
│   │   │   └── StatusBadge.jsx   # 상태 뱃지
│   │   ├── services/
│   │   │   └── api.js            # Axios API 설정
│   │   ├── styles/               # CSS 파일
│   │   ├── App.jsx
│   │   └── index.jsx
│   ├── package.json
│   └── vite.config.js
│
├── PROJECT_SPEC.md                # 프로젝트 상세 명세
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

브라우저에서 `http://localhost:3000` 접속하면 대시보드가 나타납니다.

**참고**: `backend/init_database.sql`을 실행했다면 샘플 데이터 10개가 이미 로드되어 있습니다.

데이터가 없는 경우 API로 샘플 데이터 생성:

```bash
curl -X POST http://localhost:8080/api/issues/init-sample
```

## 📊 API 엔드포인트

### SecurityIssueController

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/issues` | 전체 이슈 조회 |
| GET | `/api/issues/{id}` | 특정 이슈 조회 |
| GET | `/api/issues/top3` | Top 3 긴급 이슈 조회 |
| GET | `/api/issues/stats` | 대시보드 통계 조회 |
| PUT | `/api/issues/{id}/status` | 이슈 상태 변경 |
| POST | `/api/issues/init-sample` | 샘플 데이터 초기화 |

### 요청/응답 예시

**이슈 상태 변경**
```bash
curl -X PUT http://localhost:8080/api/issues/1/status \
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

### 1. 대시보드
- 4개의 통계 카드 (전체/수신/발신/긴급 이슈 수)
- Top 3 긴급 이슈 카드 (클릭 시 상세 페이지 이동)
- 상태별 필터링 (전체/대기/검토중/해결/긴급)
- 이슈 목록 테이블 (클릭 시 상세 페이지)
- 드롭다운으로 즉시 상태 변경

### 2. 상세 페이지
- 이슈 전체 정보 표시
- 상태 변경 드롭다운
- 기술 정보 (출발지 IP, 대상 이메일)
- 권장 조치 사항
- 액션 버튼 (검토 시작/해결 완료/긴급 표시)

## 🔐 확장 가능성

프로젝트는 다음 기능으로 확장 가능하도록 설계되었습니다:

- [ ] JWT 인증/인가 시스템
- [ ] 사용자 관리 (역할 기반 접근 제어)
- [ ] 실시간 알림 (WebSocket)
- [ ] 이슈 자동 분류 (AI/ML)
- [ ] 이메일 서버 로그 연동
- [ ] PDF 보고서 생성
- [ ] 차트 및 그래프 시각화

## 📝 데이터 모델

### SecurityIssue Entity

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

### CORS 오류 발생 시
- `backend/src/main/java/com/security/email/config/CorsConfig.java`에서 프론트엔드 URL 확인
- 기본값: `http://localhost:3000`, `http://localhost:5173`

### 데이터베이스 연결 오류
- MSSQL Server 실행 확인
- `application.properties`의 접속 정보 확인
- 방화벽 설정 확인 (포트 1433)

### 샘플 데이터가 없을 때
```bash
curl -X POST http://localhost:8080/api/issues/init-sample
```

## 👨‍💻 개발자

이 프로젝트는 면접 포트폴리오용으로 개발되었습니다.

## 📄 라이선스

This project is for portfolio demonstration purposes.

---

**프로젝트 개발 일자**: 2025년
**발표 준비**: 1일 스프린트로 개발
