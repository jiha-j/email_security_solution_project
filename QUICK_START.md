# 🚀 빠른 시작 가이드

## 1단계: 데이터베이스 초기화 (필수!)

### 방법 1: SQL Server Management Studio (SSMS) 사용

1. **SSMS 실행**
2. **서버 연결** (localhost, sa 계정)
3. **새 쿼리 창 열기** (Ctrl + N)
4. **SQL 파일 열기**: `backend/init_database.sql`
5. **실행** (F5 또는 실행 버튼)

### 방법 2: sqlcmd 커맨드라인 사용

```bash
sqlcmd -S localhost -U sa -P 1234 -i backend/init_database.sql
```

### 방법 3: Azure Data Studio 사용

1. **Azure Data Studio 실행**
2. **서버 연결** (localhost)
3. **파일 열기**: `backend/init_database.sql`
4. **실행** (Ctrl + Shift + E)

**생성되는 내용:**
- EmailSecurityDB 데이터베이스
- security_issues 테이블 (샘플 데이터 14건)
- users 테이블 (테스트 계정 3개)

---

## 2단계: 백엔드 실행

```bash
cd backend
mvn spring-boot:run
```

**확인**: http://localhost:8080/api/issues/stats 접속 시 401 Unauthorized (인증 필요) 응답

---

## 3단계: 프론트엔드 실행

새 터미널을 열고:

```bash
cd frontend
npm install
npm run dev
```

**확인**: http://localhost:3000 접속 시 로그인 페이지로 자동 이동

---

## 4단계: 로그인

**테스트 계정:**

| 역할 | 사용자명 | 비밀번호 |
|------|----------|----------|
| 관리자 | `admin` | `admin123` |
| 매니저 | `manager` | `manager123` |
| 사용자 | `user` | `user123` |

로그인 성공 시 JWT 토큰이 발급되고 대시보드로 자동 이동합니다.

---

## 🎉 완료!

브라우저에서 http://localhost:3000 접속 → 로그인 → 대시보드 확인

샘플 데이터 14개와 차트가 표시됩니다.

---

## 🔧 트러블슈팅

### 로그인이 안 될 때

1. 데이터베이스 초기화 확인:
   ```bash
   sqlcmd -S localhost -U sa -P 1234 -Q "SELECT username FROM EmailSecurityDB.dbo.users"
   ```
   admin, manager, user 3개가 표시되어야 정상

2. 백엔드 터미널에서 에러 확인
3. JWT 설정 확인: `backend/src/main/resources/application.properties`

### JWT 키 관련 오류

`application.properties`의 `jwt.secret` 값이 512비트(64바이트) 이상인지 확인

### 401 Unauthorized 에러

- 로그인 후 토큰이 만료되었을 수 있음 (다시 로그인)
- localStorage에 토큰이 저장되어 있는지 확인 (F12 → Application → Local Storage)

### 데이터가 안 보일 때

1. 백엔드 터미널에서 에러 확인
2. 데이터베이스 데이터 확인:
   ```bash
   sqlcmd -S localhost -U sa -P 1234 -Q "SELECT COUNT(*) FROM EmailSecurityDB.dbo.security_issues"
   ```
3. 결과가 14가 나와야 정상

### 포트 충돌 시

- 백엔드 포트 변경: `backend/src/main/resources/application.properties`에서 `server.port=8080` 수정
- 프론트엔드 포트 변경: `frontend/vite.config.js`에서 `port: 3000` 수정

### CORS 에러 시

`backend/src/main/java/com/security/email/config/CorsConfig.java`에서 프론트엔드 URL 확인

---

## 📊 API 테스트

### 로그인 테스트

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

응답에서 `token` 값 복사

### 인증이 필요한 API 호출

```bash
# 통계 조회
curl http://localhost:8080/api/issues/stats \
  -H "Authorization: Bearer {복사한_토큰}"

# 전체 이슈 조회
curl http://localhost:8080/api/issues \
  -H "Authorization: Bearer {복사한_토큰}"

# Top 3 이슈
curl http://localhost:8080/api/issues/top3 \
  -H "Authorization: Bearer {복사한_토큰}"
```

---

## 🎯 주요 기능 테스트

1. **로그인**: admin/admin123으로 로그인
2. **대시보드**: 통계 카드 4개 (전체/수신/발신/긴급) 확인
3. **차트**: 유형별/심각도별 막대 그래프 확인
4. **Top 3**: 긴급 이슈 3개 표시 확인
5. **필터링**: 상태별/심각도별 필터 테스트
6. **상태 변경**: 드롭다운에서 상태 변경 테스트
7. **상세 페이지**: 이슈 클릭하여 상세 정보 확인
8. **이슈 등록**: "보안 이슈 등록" 버튼으로 새 이슈 추가
9. **로그아웃**: 우측 상단 로그아웃 버튼 클릭

---

**면접 발표 화이팅! 🚀**
