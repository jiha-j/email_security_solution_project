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

---

## 2단계: 백엔드 실행

```bash
cd backend
mvn spring-boot:run
```

**확인**: http://localhost:8080/api/issues/stats 접속 시 JSON 데이터 표시

---

## 3단계: 프론트엔드 실행

새 터미널을 열고:

```bash
cd frontend
npm install
npm run dev
```

**확인**: http://localhost:3000 접속

---

## 🎉 완료!

브라우저에서 http://localhost:3000 접속하면 대시보드가 나타납니다.

샘플 데이터 10개가 이미 로드되어 있어야 합니다.

---

## 🔧 트러블슈팅

### 데이터가 안 보일 때

1. 백엔드 터미널에서 에러 확인
2. 데이터베이스 연결 확인:
   ```bash
   sqlcmd -S localhost -U sa -P 1234 -Q "SELECT COUNT(*) FROM EmailSecurityDB.dbo.security_issues"
   ```
3. 결과가 10이 나와야 정상

### 포트 충돌 시

- 백엔드 포트 변경: `backend/src/main/resources/application.properties`에서 `server.port=8080` 수정
- 프론트엔드 포트 변경: `frontend/vite.config.js`에서 `port: 3000` 수정

### CORS 에러 시

`backend/src/main/java/com/security/email/config/CorsConfig.java`에서 프론트엔드 URL 확인

---

## 📊 데이터 확인

### SQL로 데이터 확인

```sql
USE EmailSecurityDB;
SELECT * FROM security_issues;
```

### API로 데이터 확인

```bash
# 전체 이슈
curl http://localhost:8080/api/issues

# 통계
curl http://localhost:8080/api/issues/stats

# Top 3
curl http://localhost:8080/api/issues/top3
```

---

## 🎯 주요 기능 테스트

1. **대시보드**: 통계 카드 4개 확인
2. **Top 3**: 긴급 이슈 3개 표시 확인
3. **필터링**: 상태별 버튼 클릭
4. **상태 변경**: 드롭다운에서 상태 변경
5. **상세 페이지**: 이슈 클릭하여 상세 정보 확인

---

**면접 발표 화이팅! 🚀**
