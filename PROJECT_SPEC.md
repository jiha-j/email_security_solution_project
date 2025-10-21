# 이메일 보안 이슈 모니터링 시스템

## 프로젝트 개요
회사 면접 포트폴리오용 이메일 보안 이슈 모니터링 대시보드 웹 애플리케이션

## 기술 스택

### Frontend
- **React** (Hooks 기반)
- **React Router** (페이지 라우팅)
- **Axios** (API 통신, async/await)
- **CSS Grid Layout** (반응형 디자인)
- **조건부 스타일링** (상태별 색상 구분)

### Backend
- **Spring Boot** (REST API)
- **JPA/Hibernate** (ORM)
- **Maven** (빌드 도구)
- **MSSQL Server** (데이터베이스)
- **CORS** 설정

### 확장성 고려
- JWT 인증 구조 준비

## 보안 이슈 카테고리

### 수신메일 보안이슈 (Inbound)
1. 대량 스팸 메일 공격
2. 불법 릴레이 서버 사용
3. 바이러스, 랜섬웨어 등 악성코드 공격
4. 개인정보 탈취 피싱 사이트 공격
5. 헤더 위·변조 및 유사 도메인 사칭 메일

### 발신메일 보안이슈 (Outbound)
1. 악성 메일 회신
2. 바이러스 URL 공유
3. 기업 내부 정보 유출 및 오발송 사고
4. 대용량 파일 사후관리 문제
5. 망분리 환경에서 대용량 첨부파일 발송 문제

## 주요 기능

### 1. 대시보드 (Dashboard)
- **통계 카드**: 전체/수신/발신 이슈 수
- **상태별 분류**: 대기(Pending), 검토중(Review), 해결(Resolved), 긴급(Critical)
- **Top 3 이슈**: 심각도 기준 상위 3개 표시
- **차트/그래프**: 카테고리별 분포 시각화

### 2. 이슈 목록
- 상태별 필터링
- 카테고리별 분류
- 상태값 변경 기능 (드롭다운)
- 클릭 시 상세 페이지 이동

### 3. 상세 페이지
- 이슈 상세 정보 표시
- 상태 변경 기능
- 메모/코멘트 추가 (옵션)

## 데이터 모델

### SecurityIssue Entity
```java
- id: Long (PK)
- title: String (이슈 제목)
- description: String (상세 설명)
- category: String (카테고리)
- type: String (INBOUND/OUTBOUND)
- status: String (PENDING/REVIEW/RESOLVED/CRITICAL)
- severity: String (LOW/MEDIUM/HIGH/CRITICAL)
- detectedDate: LocalDateTime (탐지 시각)
- resolvedDate: LocalDateTime (해결 시각)
- affectedEmails: Integer (영향받은 이메일 수)
```

## API Endpoints

### SecurityIssueController
- `GET /api/issues` - 전체 이슈 조회
- `GET /api/issues/{id}` - 특정 이슈 조회
- `GET /api/issues/stats` - 통계 정보 조회
- `PUT /api/issues/{id}/status` - 상태 변경
- `GET /api/issues/top3` - Top 3 이슈 조회

### DashboardController (옵션)
- `GET /api/dashboard/summary` - 대시보드 요약 정보

## 프로젝트 구조

```
email-security-monitoring/
├── backend/                        # Spring Boot
│   ├── src/main/java/
│   │   └── com/security/email/
│   │       ├── controller/         # REST Controllers
│   │       ├── service/            # Business Logic
│   │       ├── repository/         # JPA Repositories
│   │       ├── entity/             # JPA Entities
│   │       ├── dto/                # Data Transfer Objects
│   │       └── config/             # Configuration (CORS, etc)
│   ├── src/main/resources/
│   │   └── application.properties  # DB 설정
│   └── pom.xml                     # Maven Dependencies
│
└── frontend/                       # React
    ├── src/
    │   ├── components/             # React Components
    │   │   ├── Dashboard.jsx       # 대시보드
    │   │   ├── IssueList.jsx       # 이슈 목록
    │   │   ├── IssueDetail.jsx     # 상세 페이지
    │   │   ├── StatCard.jsx        # 통계 카드
    │   │   └── StatusBadge.jsx     # 상태 뱃지
    │   ├── services/               # API Services
    │   │   └── api.js              # Axios 설정
    │   ├── styles/                 # CSS Files
    │   ├── App.jsx                 # Main App
    │   └── index.js                # Entry Point
    └── package.json
```

## UI/UX 디자인 가이드

### 색상 팔레트 (상태별)
- **PENDING** (대기): `#FFA726` (주황)
- **REVIEW** (검토중): `#42A5F5` (파랑)
- **RESOLVED** (해결): `#66BB6A` (초록)
- **CRITICAL** (긴급): `#EF5350` (빨강)

### 심각도 색상
- **LOW**: `#AED581` (연한 초록)
- **MEDIUM**: `#FFD54F` (노랑)
- **HIGH**: `#FF8A65` (주황)
- **CRITICAL**: `#E57373` (빨강)

### 타이포그래피
- **제목**: Bold, 적절한 크기
- **본문**: 가독성 중심
- **강조**: Bold 처리

### 레이아웃
- **Grid 레이아웃**: 통계 카드 배치
- **반응형 디자인**: 모바일/태블릿/데스크톱 대응
- **카드 기반 UI**: 정보 블록 구분

## 개발 우선순위

### Phase 1: 백엔드 기본 구조
1. Spring Boot 프로젝트 생성
2. Entity 및 Repository 구현
3. 기본 Controller 및 Service 구현
4. 샘플 데이터 생성

### Phase 2: 프론트엔드 기본 구조
1. React 프로젝트 생성
2. Router 설정
3. API 서비스 구현
4. 기본 컴포넌트 구현

### Phase 3: 통합 및 스타일링
1. API 연동
2. 상태 관리
3. 스타일링 완성
4. 상세 페이지 구현

## 샘플 데이터

### 수신메일 이슈 예시
1. "대량 스팸 메일 탐지 (1,250건)" - CRITICAL
2. "피싱 사이트 링크 포함 메일" - HIGH
3. "의심스러운 첨부파일 (ransomware.exe)" - CRITICAL

### 발신메일 이슈 예시
1. "고객 정보 포함 메일 외부 발송" - HIGH
2. "바이러스 URL 공유 탐지" - CRITICAL
3. "대용량 파일 (500MB) 발송 기록" - MEDIUM

## 다음 단계 확장 가능성

- JWT 인증/인가
- 사용자 관리
- 실시간 알림
- 이슈 자동 분류 (AI/ML)
- 이메일 서버 로그 연동
- 보고서 생성 기능
